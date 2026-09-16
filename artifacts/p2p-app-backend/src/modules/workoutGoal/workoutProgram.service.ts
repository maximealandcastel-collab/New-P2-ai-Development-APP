import { facilityInventory } from "../enterprise/enterprise.service";
import { runWithProviderBackup } from "../../services/providerFallback";
import { exerciseMatchesEquipment, resolveWorkoutEquipment } from "./workoutEquipment";
import { exerciseMatchesSplitDay, splitDayMuscles, selectSplitDayExercises } from "./workoutSplit";
import { Types } from "mongoose";
import { createHash, randomUUID } from "crypto";
import {
  IAIGeneratedPlan,
  IPlannedExercise,
  ISessionStep,
  IWorkout,
  IWorkoutPreferenceSnapshot,
  IWorkoutProgram,
  IWorkoutSplitOption,
} from "./workoutGoal.interface";
import { WorkoutModel } from "./workoutGoal.model";
import { UserModel } from "../user/user.model";
import { ExerciseBlockModel } from "../exerciseBlock/exerciseBlock.model";
import { ExerciseModel } from "../exercise/exercise.model";
import { ExerciseStepModel } from "../exerciseStep/exerciseStep.model";
import {
  callAI,
  callOpenAIWorkoutPlan,
  parseAIJsonResponse,
  summarizeAIProviderFailure,
} from "../../services/ai.service";
import { resolveWorkoutTrainer } from "./workoutTrainerResolver";
import { EXERCISES } from "../workoutPlan/exercises";

type GenerationContext = {
  workout: IWorkout;
  user: any;
  trainer: any;
  memory: any;
};

type LibraryExercise = {
  _id: any;
  name: string;
  muscleGroup?: string;
  difficulty?: string;
  equipment?: string;
  sets?: number;
  reps?: string;
  restTime?: string;
  rpe?: string;
  tags?: string[];
  steps?: any[];
  substitutions?: Record<string, string>;
  blockId: any;
  blockName: string;
};

const resolveDaysPerWeek = (value: unknown): number => {
  if (value === null || value === undefined || value === "") return 3;
  const parsed = Number(value);
  if (!Number.isInteger(parsed) || parsed < 2 || parsed > 6) {
    throw new Error("daysPerWeek must be a whole number between 2 and 6");
  }
  return parsed;
};

const cleanStrings = (value: unknown): string[] =>
  Array.isArray(value)
    ? value.map((item) => String(item).trim()).filter(Boolean)
    : [];

const nonEmptyString = (value: unknown, fallback = ""): string => {
  const text = String(value ?? "").trim();
  return text || fallback;
};

const logWorkoutEvent = (
  event: string,
  workoutId: string,
  details: Record<string, unknown> = {},
) => {
  console.info(`[${event}]`, { workoutId, ...details });
};

type GenerationStage = "splits" | "program";
const GENERATION_LEASE_STALE_MS = 70_000;
const GENERATION_FOLLOWER_WAIT_MS = 58_000;

const claimGenerationLease = async (
  userId: string,
  workoutId: string,
  stage: GenerationStage,
  selectedSplitId?: string,
): Promise<string | null> => {
  const leaseId = randomUUID();
  const leasePath = `generationLeases.${stage}`;
  const resultAvailableForGeneration =
    stage === "splits"
      ? { "splitOptions.2": { $exists: false } }
      : {
          $or: [
            { weeklyProgram: { $exists: false } },
            { "selectedSplit.id": { $ne: selectedSplitId } },
          ],
        };
  const claimed = await WorkoutModel.findOneAndUpdate(
    {
      $and: [
        { _id: workoutId, userId },
        resultAvailableForGeneration,
        {
          $or: [
            { [`${leasePath}.leaseId`]: { $exists: false } },
            {
              [`${leasePath}.startedAt`]: {
                $lt: new Date(Date.now() - GENERATION_LEASE_STALE_MS),
              },
            },
          ],
        },
      ],
    },
    {
      $set: {
        [`${leasePath}.leaseId`]: leaseId,
        [`${leasePath}.startedAt`]: new Date(),
      },
    },
    { new: true },
  );
  return claimed ? leaseId : null;
};

const releaseGenerationLease = async (
  userId: string,
  workoutId: string,
  stage: GenerationStage,
  leaseId: string,
) => {
  const leasePath = `generationLeases.${stage}`;
  await WorkoutModel.updateOne(
    {
      _id: workoutId,
      userId,
      [`${leasePath}.leaseId`]: leaseId,
    },
    { $unset: { [leasePath]: 1 } },
  );
};

const waitForGenerationResult = async (
  userId: string,
  workoutId: string,
  stage: GenerationStage,
  selectedSplitId?: string,
): Promise<IWorkout> => {
  const deadline = Date.now() + GENERATION_FOLLOWER_WAIT_MS;
  while (Date.now() < deadline) {
    const workout = await WorkoutModel.findOne({ _id: workoutId, userId });
    if (!workout) throw new Error("Workout not found");
    if (stage === "splits" && workout.splitOptions?.length === 3) return workout;
    if (
      stage === "program" &&
      workout.weeklyProgram &&
      workout.selectedSplit?.id === selectedSplitId
    ) {
      return workout;
    }
    if (!workout.generationLeases?.[stage]?.leaseId) break;
    await new Promise((resolve) => setTimeout(resolve, 250));
  }
  throw new Error("Workout generation is already in progress. Please try again.");
};

const getGenerationContext = async (
  userId: string,
  workoutId: string,
): Promise<GenerationContext> => {
  if (!Types.ObjectId.isValid(workoutId)) {
    throw new Error("Invalid workout ID");
  }

  const workout = await WorkoutModel.findOne({ _id: workoutId, userId });
  if (!workout) throw new Error("Workout not found");

  const facilityId = (workout.workoutPreferences as any)?.facilityId;
  if (facilityId) {
    const facility = await facilityInventory(userId, facilityId);
    const inventory = new Set<string>([...facility.equipment, "bodyweight_only"]);
    workout.equipment_availablity = workout.equipment_availablity.filter((item: string) => inventory.has(item));
    if (!workout.equipment_availablity.length) throw new Error("Selected equipment is no longer available at this facility");
  }
  const user = await UserModel.findById(userId);
  if (!user) throw new Error("User not found");
  const trainer = await resolveWorkoutTrainer(user, workout.trainerId);
  if (!trainer) throw new Error("Trainer not found");

  const memory = user.getMemoryForTrainer(
    (trainer._id as Types.ObjectId).toString(),
  );

  return { workout, user, trainer, memory };
};

const buildPreferenceSnapshot = ({
  workout,
  user,
  memory,
}: GenerationContext): IWorkoutPreferenceSnapshot => {
  const stored = (workout.workoutPreferences || {}) as Partial<IWorkoutPreferenceSnapshot>;
  const memoryLimitations = memory?.profileMemory?.limitations;
  const limitations = Array.isArray(memoryLimitations)
    ? cleanStrings(memoryLimitations)
    : nonEmptyString(memoryLimitations)
      ? [nonEmptyString(memoryLimitations)]
      : [];

  return {
    goal: cleanStrings(workout.goal),
    focusArea: cleanStrings(workout.focusArea),
    workout_environment: cleanStrings(workout.workout_environment),
    equipment_availablity: resolveWorkoutEquipment(
      workout.equipment_availablity, stored.facilityEquipment,
    ),
    facilityId: stored.facilityId,
    facilityEquipment: stored.facilityEquipment,
    selectedEquipment: stored.selectedEquipment,
    workout_intensity: cleanStrings(workout.workout_intensity),
    duration: Math.min(90, Math.max(20, Number(workout.duration) || 30)),
    daysPerWeek: resolveDaysPerWeek(stored.daysPerWeek),
    experienceLevel:
      nonEmptyString(stored.experienceLevel) ||
      nonEmptyString(memory?.profileMemory?.experienceLevel) ||
      nonEmptyString(user.fitnessLevel, "beginner"),
    cardioPreference: nonEmptyString(stored.cardioPreference, "balanced"),
    trainingStyle: nonEmptyString(stored.trainingStyle, "balanced"),
    preferredExercises: cleanStrings(stored.preferredExercises),
    excludedExercises: cleanStrings(stored.excludedExercises),
    limitations: cleanStrings(stored.limitations).length
      ? cleanStrings(stored.limitations)
      : limitations,
    injuries: cleanStrings(stored.injuries).length
      ? cleanStrings(stored.injuries)
      : cleanStrings(user.injuries),
  };
};

const splitPatterns: Record<number, Array<{ name: string; schedule: string[] }>> = {
  2: [
    { name: "Full Body A / B", schedule: ["Full Body A", "Full Body B"] },
    { name: "Upper / Lower", schedule: ["Upper Body", "Lower Body"] },
    {
      name: "Strength + Conditioning",
      schedule: ["Total-Body Strength", "Strength + Conditioning"],
    },
  ],
  3: [
    {
      name: "Three-Day Full Body",
      schedule: ["Full Body A", "Full Body B", "Full Body C"],
    },
    {
      name: "Upper / Lower / Full Body",
      schedule: ["Upper Body", "Lower Body", "Full Body"],
    },
    {
      name: "Push / Pull / Legs",
      schedule: ["Push", "Pull", "Legs"],
    },
  ],
  4: [
    {
      name: "Upper / Lower Repeat",
      schedule: ["Upper A", "Lower A", "Upper B", "Lower B"],
    },
    {
      name: "Push / Pull / Legs / Full Body",
      schedule: ["Push", "Pull", "Legs", "Full Body"],
    },
    {
      name: "Strength + Hypertrophy",
      schedule: [
        "Upper Strength",
        "Lower Strength",
        "Upper Hypertrophy",
        "Lower Hypertrophy",
      ],
    },
  ],
  5: [
    {
      name: "Push / Pull / Legs / Upper / Lower",
      schedule: ["Push", "Pull", "Legs", "Upper Body", "Lower Body"],
    },
    {
      name: "Upper / Lower / Push / Pull / Legs",
      schedule: ["Upper Body", "Lower Body", "Push", "Pull", "Legs"],
    },
    {
      name: "Balanced Bodybuilding",
      schedule: ["Chest + Back", "Legs", "Shoulders + Arms", "Upper", "Lower"],
    },
  ],
  6: [
    {
      name: "Push / Pull / Legs Repeat",
      schedule: ["Push A", "Pull A", "Legs A", "Push B", "Pull B", "Legs B"],
    },
    {
      name: "Upper / Lower Repeat",
      schedule: ["Upper A", "Lower A", "Upper B", "Lower B", "Upper C", "Lower C"],
    },
    {
      name: "Strength + Performance",
      schedule: [
        "Upper Strength",
        "Lower Strength",
        "Push Hypertrophy",
        "Pull Hypertrophy",
        "Legs Hypertrophy",
        "Conditioning + Core",
      ],
    },
  ],
};

const buildFallbackSplits = (
  preferences: IWorkoutPreferenceSnapshot,
): IWorkoutSplitOption[] => {
  const days = resolveDaysPerWeek(preferences.daysPerWeek);
  const goal = preferences.goal.join(", ") || "general fitness";
  const difficulty = preferences.experienceLevel || "beginner";
  const patterns = splitPatterns[days] || splitPatterns[3];

  return patterns.map((pattern, index) => ({
    id: `split_${index + 1}`,
    name: pattern.name,
    weeklySchedule: pattern.schedule,
    primaryGoal: goal,
    recommendedFor:
      index === 0
        ? `${goal} with balanced weekly frequency`
        : index === 1
          ? `${goal} with varied training emphasis`
          : `${goal} with additional specialization`,
    reason: `${pattern.name} fits ${days} available training days, the selected ${preferences.duration}-minute session length, and a ${difficulty} training level while leaving room for recovery.`,
    estimatedSessionMinutes: preferences.duration,
    difficulty,
    recoveryRequirement:
      days >= 5
        ? "High: prioritize sleep and at least one full rest day."
        : "Moderate: separate demanding sessions with rest or light activity.",
    daysPerWeek: days,
  }));
};

const validateSplitOptions = (
  raw: any,
  preferences: IWorkoutPreferenceSnapshot,
): IWorkoutSplitOption[] => {
  const options = Array.isArray(raw?.splitOptions) ? raw.splitOptions : [];
  const days = resolveDaysPerWeek(preferences.daysPerWeek);
  if (options.length < 3) {
    throw new Error("Workout split response must contain three options");
  }

  const normalized = options.slice(0, 3).map((option: any, index: number) => {
    const schedule = cleanStrings(option.weeklySchedule);
    if (schedule.length !== days) {
      throw new Error(`Split option ${index + 1} does not match ${days} days`);
    }

    const name = nonEmptyString(option.name);
    const reason = nonEmptyString(option.reason);
    if (!name || !reason) {
      throw new Error(`Split option ${index + 1} is incomplete`);
    }

    return {
      id: `split_${index + 1}`,
      name,
      weeklySchedule: schedule,
      primaryGoal: nonEmptyString(
        option.primaryGoal,
        preferences.goal.join(", "),
      ),
      recommendedFor: nonEmptyString(option.recommendedFor, reason),
      reason,
      estimatedSessionMinutes: preferences.duration,
      difficulty: nonEmptyString(
        option.difficulty,
        preferences.experienceLevel || "beginner",
      ),
      recoveryRequirement: nonEmptyString(
        option.recoveryRequirement,
        "Use at least one full recovery day each week.",
      ),
      daysPerWeek: days,
    };
  });

  if (
    new Set(
      normalized.map((option: IWorkoutSplitOption) => option.name.toLowerCase()),
    ).size !== 3
  ) {
    throw new Error("Workout split options are not materially different");
  }

  return normalized;
};

const callStructuredWorkoutAI = async <T>({
  workoutId,
  stage,
  systemPrompt,
  userMessage,
  maxTokens,
  validate,
  fallback,
}: {
  workoutId: string;
  stage: "splits" | "program";
  systemPrompt: string;
  userMessage: string;
  maxTokens: number;
  validate: (_raw: any) => T;
  fallback: () => T;
}): Promise<{ value: T; provider: "openai" | "claude" | "library" }> => {
  const totalStartedAt = Date.now();
  type Provider = "claude" | "openai";
  type Attempt =
    | { ok: true; value: T; provider: Provider }
    | { ok: false; reason: string; provider: Provider };

  const attemptProvider = async (
    provider: Provider,
    timeoutMs: number,
    signal: AbortSignal,
  ): Promise<Attempt> => {
    const providerStartedAt = Date.now();
    logWorkoutEvent("WORKOUT_PROVIDER_STARTED", workoutId, {
      stage,
      provider,
      timeoutMs,
    });

    try {
      const response =
        provider === "claude"
          ? await callAI({
              systemPrompt,
              userMessage,
              maxTokens,
              timeoutMs,
              signal,
            })
          : await callOpenAIWorkoutPlan({
              systemPrompt,
              userMessage,
              maxTokens,
              timeoutMs,
              signal,
            });
      const providerDurationMs = Date.now() - providerStartedAt;
      const validationStartedAt = Date.now();
      const value = validate(parseAIJsonResponse(response));
      const validationDurationMs = Date.now() - validationStartedAt;

      logWorkoutEvent("WORKOUT_PROVIDER_SUCCEEDED", workoutId, {
        stage,
        provider,
        providerDurationMs,
        validationDurationMs,
        totalDurationMs: Date.now() - totalStartedAt,
        fallbackUsed: provider !== "claude",
        finalFallbackUsed: false,
      });
      return { ok: true, value, provider };
    } catch (error) {
      const reason = summarizeAIProviderFailure(error);
      logWorkoutEvent("WORKOUT_PROVIDER_FAILED", workoutId, {
        stage,
        provider,
        providerDurationMs: Date.now() - providerStartedAt,
        totalDurationMs: Date.now() - totalStartedAt,
        reason,
      });
      return { ok: false, reason, provider };
    }
  };

  // The client has a 60-second HTTP deadline. Overlap a slow primary with
  // its backup and leave time for database reads, validation and persistence.
  const deadlineMs = stage === "splits" ? 32_000 : 42_000;
  const failures: Partial<Record<Provider, string>> = {};
  const run = async (provider: Provider, signal: AbortSignal) => {
    const result = await attemptProvider(provider, deadlineMs, signal);
    if (!result.ok) {
      failures[provider] = result.reason;
      throw new Error(result.reason);
    }
    return { value: result.value, provider: result.provider };
  };
  try {
    return await runWithProviderBackup({
      primary: signal => run("claude", signal),
      backup: signal => run("openai", signal),
      backupDelayMs: stage === "splits" ? 6_000 : 8_000,
      deadlineMs,
    });
  } catch (error) {
    logWorkoutEvent("WORKOUT_PROVIDER_FALLBACK", workoutId, {
      stage, toProvider: "library", reason: summarizeAIProviderFailure(error),
    });
  }
  const libraryStartedAt = Date.now();
  const value = fallback();
  logWorkoutEvent("WORKOUT_LIBRARY_FALLBACK_SUCCEEDED", workoutId, {
    stage,
    provider: "library",
    providerDurationMs: Date.now() - libraryStartedAt,
    validationDurationMs: 0,
    totalDurationMs: Date.now() - totalStartedAt,
    fallbackUsed: true,
    finalFallbackUsed: true,
    fallbackReason: {
      ...failures,
    },
  });
  return { value, provider: "library" };
};

const buildSplitPrompt = (
  preferences: IWorkoutPreferenceSnapshot,
  trainer: any,
): { systemPrompt: string; userMessage: string } => ({
  systemPrompt: `
You are the workout programming engine for P2P FitTech AI, working with coach ${trainer.name}.
Return one valid JSON object only. Never use markdown or explanatory text.
Create exactly three materially different, physiologically rational split options.
Every option must use exactly the requested number of training days.
Account for goal, experience, focus, equipment, environment, intensity, duration, injuries, limitations, and recovery.
Do not create the exercise program yet.
`.trim(),
  userMessage: `
WORKOUT PREFERENCES:
${JSON.stringify(preferences)}

Return exactly:
{
  "splitOptions": [
    {
      "name": "Split name",
      "weeklySchedule": ["Day title"],
      "primaryGoal": "Primary objective",
      "recommendedFor": "Who this option best serves",
      "reason": "Why it fits these exact selections and recovery needs",
      "estimatedSessionMinutes": ${preferences.duration},
      "difficulty": "${preferences.experienceLevel}",
      "recoveryRequirement": "Specific recovery requirement",
      "daysPerWeek": ${preferences.daysPerWeek}
    }
  ]
}
`.trim(),
});

const platformLibraryObjectId = (scope: string, value: string) =>
  new Types.ObjectId(
    createHash("sha256")
      .update(`${scope}:${value}`)
      .digest("hex")
      .slice(0, 24),
  );

const loadPlatformApprovedLibrary = (): LibraryExercise[] =>
  EXERCISES.filter((exercise) => !exercise.is_warmup).map((exercise) => ({
    _id: platformLibraryObjectId("platform-workout-exercise", exercise.name),
    name: exercise.name,
    muscleGroup: exercise.muscle_group,
    equipment: exercise.equipment,
    difficulty: exercise.intensity.join(", "),
    sets: 3,
    reps: "8-12",
    restTime: "60s",
    rpe: "7-8",
    tags: [
      exercise.muscle_group,
      exercise.equipment,
      ...exercise.location,
      ...exercise.intensity,
    ],
    steps: [],
    substitutions: {},
    blockId: platformLibraryObjectId(
      "platform-workout-block",
      exercise.muscle_group,
    ),
    blockName: `${exercise.muscle_group} — Platform Approved`,
  }));

const loadApprovedLibrary = async (
  trainerId: Types.ObjectId,
  allowPlatformFallback = false,
) => {
  const approvedBlocks = await ExerciseBlockModel.find({
    trainerId,
    isApproved: true,
  }).lean();

  const blocks = await Promise.all(
    approvedBlocks.map(async (block: any) => {
      const exercises = await ExerciseModel.find({
        blockId: block._id,
        isApproved: true,
      }).lean();
      const allSteps = await ExerciseStepModel.find({
        exerciseId: { $in: exercises.map((exercise: any) => exercise._id) },
      }).sort({ order: 1 }).lean();
      const stepsByExercise = new Map<string, any[]>();
      for (const step of allSteps) {
        const id = String(step.exerciseId);
        stepsByExercise.set(id, [...(stepsByExercise.get(id) || []), step]);
      }
      const withSteps = exercises.map((exercise: any) => ({
        ...exercise,
        steps: stepsByExercise.get(String(exercise._id)) || [],
        blockId: block._id,
        blockName: block.name,
      }));
      return { ...block, exercises: withSteps };
    }),
  );

  let exercises: LibraryExercise[] = blocks.flatMap((block: any) =>
    block.exercises.map((exercise: any) => ({
      ...exercise,
      blockId: block._id,
      blockName: block.name,
    })),
  );

  // Older built-in trainer seeds created approved exercises with a valid
  // blockId but did not persist the parent ExerciseBlock document. Preserve
  // exercise-level approval while excluding exercises from an explicitly
  // unapproved parent block.
  if (!exercises.length) {
    const [trainerBlocks, directlyApproved] = await Promise.all([
      ExerciseBlockModel.find({ trainerId }).lean(),
      ExerciseModel.find({ trainerId, isApproved: true }).lean(),
    ]);
    const blockById = new Map(
      trainerBlocks.map((block: any) => [String(block._id), block]),
    );
    const eligibleDirect = directlyApproved.filter((exercise: any) => {
      const parent = blockById.get(String(exercise.blockId));
      return !parent || parent.isApproved === true;
    });

    exercises = await Promise.all(
      eligibleDirect.map(async (exercise: any) => ({
        ...exercise,
        steps: await ExerciseStepModel.find({ exerciseId: exercise._id })
          .sort({ order: 1 })
          .lean(),
        blockName:
          blockById.get(String(exercise.blockId))?.name || "Approved Exercises",
      })),
    );

    if (exercises.length) {
      console.info("[Workout Library Compatibility]", {
        trainerId: String(trainerId),
        approvedExercisesLoaded: exercises.length,
        source: "exercise_level_approval",
      });
    }
  }

  if (!exercises.length) {
    if (allowPlatformFallback) {
      const platformLibrary = loadPlatformApprovedLibrary();
      console.info("[Workout Library Compatibility]", {
        trainerId: String(trainerId),
        approvedExercisesLoaded: platformLibrary.length,
        source: "platform_approved_owner_test_fallback",
      });
      return platformLibrary;
    }
    throw new Error(
      "Trainer has no approved exercises yet. Ask your trainer to approve exercises in their library.",
    );
  }
  return exercises;
};

const normalizedToken = (value: unknown) =>
  String(value ?? "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_|_$/g, "");

const filterLibraryForPreferences = (
  exercises: LibraryExercise[],
  preferences: IWorkoutPreferenceSnapshot,
): LibraryExercise[] => {
  const selected = resolveWorkoutEquipment(
    preferences.equipment_availablity, preferences.facilityEquipment,
  );
  const excluded = new Set(
    (preferences.excludedExercises || []).map(name => normalizedToken(name)),
  );
  const allowed = exercises.filter(exercise =>
    !excluded.has(normalizedToken(exercise.name)) &&
    exerciseMatchesEquipment(exercise.equipment, selected),
  );

  if (allowed.length < 2) {
    throw new Error(
      "Trainer library does not contain enough approved exercises for the selected equipment.",
    );
  }
  return allowed;
};

const defaultWarmUp = (): ISessionStep[] => [
  { order: 1, instruction: "Easy movement to raise body temperature", duration: "3 minutes" },
  { order: 2, instruction: "Dynamic mobility for today's primary joints", duration: "2 minutes" },
  { order: 3, instruction: "Light rehearsal sets for the first exercise", duration: "2 minutes" },
];

const defaultCoolDown = (): ISessionStep[] => [
  { order: 1, instruction: "Easy walking and controlled breathing", duration: "2 minutes" },
  { order: 2, instruction: "Gentle mobility for the trained muscles", duration: "3 minutes" },
];

const snapshotExercise = (
  raw: any,
  source: LibraryExercise,
  order: number,
): IPlannedExercise => ({
  exerciseId: new Types.ObjectId(String(source._id)),
  blockId: new Types.ObjectId(String(source.blockId)),
  blockName: source.blockName,
  exerciseName: source.name,
  muscleGroup: source.muscleGroup,
  sets: Math.min(6, Math.max(1, Math.round(Number(raw.sets) || source.sets || 3))),
  reps: nonEmptyString(raw.reps, source.reps || "8-12"),
  restTime: nonEmptyString(raw.restTime, source.restTime || "60s"),
  rpe: nonEmptyString(raw.rpe, source.rpe || "7-8"),
  steps: source.steps || [],
  substitutions: source.substitutions || {},
  order,
  isCompleted: false,
});

const validateSessionSteps = (raw: any, label: string): ISessionStep[] => {
  if (!Array.isArray(raw) || raw.length < 2) {
    throw new Error(`${label} must contain at least two steps`);
  }
  return raw.slice(0, 4).map((step: any, index: number) => {
    const instruction = nonEmptyString(step.instruction);
    const duration = nonEmptyString(step.duration);
    if (!instruction || !duration) throw new Error(`${label} step is incomplete`);
    return { order: index + 1, instruction, duration };
  });
};

const validateWorkoutProgram = (
  raw: any,
  preferences: IWorkoutPreferenceSnapshot,
  split: IWorkoutSplitOption,
  library: LibraryExercise[],
): IWorkoutProgram => {
  const workouts = Array.isArray(raw?.workouts) ? raw.workouts : [];
  if (workouts.length !== split.daysPerWeek) {
    throw new Error("Program does not contain the selected number of workout days");
  }

  const byId = new Map(library.map((exercise) => [String(exercise._id), exercise]));
  const byName = new Map(
    library.map((exercise) => [exercise.name.toLowerCase(), exercise]),
  );
  const excluded = new Set(
    (preferences.excludedExercises || []).map((name) => name.toLowerCase()),
  );

  const normalizedWorkouts = workouts.map((day: any, dayIndex: number) => {
    const rawExercises = Array.isArray(day.exercises) ? day.exercises : [];
    if (rawExercises.length < 2 || rawExercises.length > 8) {
      throw new Error(`Workout day ${dayIndex + 1} has an unrealistic exercise count`);
    }

    const seen = new Set<string>();
    const exercises = rawExercises.map((exercise: any, index: number) => {
      const source =
        byId.get(String(exercise.exerciseId || "")) ||
        byName.get(nonEmptyString(exercise.exerciseName).toLowerCase());
      if (!source) {
        throw new Error(`Workout day ${dayIndex + 1} contains an unapproved exercise`);
      }
      if (excluded.has(source.name.toLowerCase())) {
        throw new Error(`Workout day ${dayIndex + 1} contains an excluded exercise`);
      }
      if (splitDayMuscles(split.weeklySchedule[dayIndex]) &&
          !exerciseMatchesSplitDay(source.muscleGroup, split.weeklySchedule[dayIndex])) {
        throw new Error(`Workout day ${dayIndex + 1} contains an exercise outside its split focus`);
      }
      const key = String(source._id);
      if (seen.has(key)) {
        throw new Error(`Workout day ${dayIndex + 1} contains a duplicate exercise`);
      }
      seen.add(key);
      if (!nonEmptyString(exercise.reps) || !nonEmptyString(exercise.restTime)) {
        throw new Error(`Workout day ${dayIndex + 1} has an incomplete prescription`);
      }
      return snapshotExercise(exercise, source, index + 1);
    });

    return {
      day: dayIndex + 1,
      title: split.weeklySchedule[dayIndex],
      muscleGroups: cleanStrings(day.muscleGroups),
      warmUp: validateSessionSteps(day.warmUp, "Warm-up"),
      exercises,
      coolDown: validateSessionSteps(day.coolDown, "Cool-down"),
      estimatedDurationMinutes: preferences.duration,
      cardioGuidance: nonEmptyString(day.cardioGuidance),
    };
  });

  const progressionMethod = nonEmptyString(raw?.progression?.method);
  const progressionGuidance = nonEmptyString(raw?.progression?.guidance);
  const recoveryGuidance = nonEmptyString(raw?.recovery?.guidance);
  const cardioGuidance = nonEmptyString(raw?.cardio?.guidance);
  if (
    !progressionMethod ||
    !progressionGuidance ||
    !recoveryGuidance ||
    !cardioGuidance
  ) {
    throw new Error("Program is missing progression, recovery, or cardio guidance");
  }

  return {
    name: nonEmptyString(raw.name, split.name),
    goal: preferences.goal.join(", ") || "general fitness",
    experienceLevel: preferences.experienceLevel || "beginner",
    daysPerWeek: split.daysPerWeek,
    estimatedSessionMinutes: preferences.duration,
    weeklySchedule: split.weeklySchedule,
    workouts: normalizedWorkouts,
    progression: {
      method: progressionMethod,
      guidance: progressionGuidance,
    },
    recovery: {
      guidance: recoveryGuidance,
      restDays: cleanStrings(raw?.recovery?.restDays),
    },
    cardio: {
      guidance: cardioGuidance,
      frequency: nonEmptyString(raw?.cardio?.frequency),
    },
    generatedAt: new Date(),
  };
};

const buildFallbackProgram = (
  preferences: IWorkoutPreferenceSnapshot,
  split: IWorkoutSplitOption,
  library: LibraryExercise[],
): IWorkoutProgram => {
  if (
    (preferences.injuries || []).length > 0 ||
    (preferences.limitations || []).length > 0
  ) {
    throw new Error(
      "A safe fallback program cannot be generated for the stored injuries or limitations.",
    );
  }

  const focus = new Set(preferences.focusArea.map(normalizedToken));
  const rankedLibrary = [...library].sort((left, right) => {
    const score = (exercise: LibraryExercise) => {
      const muscle = normalizedToken(exercise.muscleGroup);
      const tags = (exercise.tags || []).map(normalizedToken);
      let value = focus.has(muscle) ? 4 : 0;
      if (focus.has("full_body")) value += 1;
      if (tags.some((tag) => focus.has(tag))) value += 2;
      return value;
    };
    return score(right) - score(left);
  });
  const exercisesPerDay = preferences.duration <= 30 ? 3 : preferences.duration <= 50 ? 4 : 5;
  const workouts = split.weeklySchedule.map((title, dayIndex) => {
    const selected = selectSplitDayExercises(rankedLibrary, title, dayIndex, exercisesPerDay);
    return {
      day: dayIndex + 1,
      title,
      muscleGroups: [...new Set(selected.map(exercise => exercise.muscleGroup).filter(Boolean))] as string[],
      warmUp: defaultWarmUp(),
      exercises: selected.map((exercise, index) =>
        snapshotExercise({}, exercise, index + 1),
      ),
      coolDown: defaultCoolDown(),
      estimatedDurationMinutes: preferences.duration,
      cardioGuidance:
        preferences.cardioPreference === "none"
          ? ""
          : "Add brief low-to-moderate conditioning only if recovery is good.",
    };
  });

  return {
    name: split.name,
    goal: preferences.goal.join(", ") || "general fitness",
    experienceLevel: preferences.experienceLevel || "beginner",
    daysPerWeek: split.daysPerWeek,
    estimatedSessionMinutes: preferences.duration,
    weeklySchedule: split.weeklySchedule,
    workouts,
    progression: {
      method: "Double progression",
      guidance:
        "When every set reaches the top of the prescribed rep range with good form and the target RPE, increase resistance slightly and restart at the lower end.",
    },
    recovery: {
      guidance:
        "Keep at least one full rest day each week, prioritize sleep, and reduce load or volume if pain or unusual fatigue appears.",
      restDays: ["Place rest days between the most demanding sessions when possible."],
    },
    cardio: {
      guidance:
        "Use low-to-moderate cardio that does not interfere with strength recovery.",
      frequency: "1-3 short sessions per week as recovery allows.",
    },
    generatedAt: new Date(),
  };
};

const buildProgramPrompt = (
  preferences: IWorkoutPreferenceSnapshot,
  split: IWorkoutSplitOption,
  trainer: any,
  memory: any,
  library: LibraryExercise[],
): { systemPrompt: string; userMessage: string } => {
  const compactLibrary = library.map((exercise) => ({
    exerciseId: String(exercise._id),
    exerciseName: exercise.name,
    blockId: String(exercise.blockId),
    blockName: exercise.blockName,
    muscleGroup: exercise.muscleGroup,
    difficulty: exercise.difficulty,
    equipment: exercise.equipment,
    defaultSets: exercise.sets,
    defaultReps: exercise.reps,
    defaultRestTime: exercise.restTime,
    tags: exercise.tags || [],
  }));

  return {
    systemPrompt: `
You are the production workout programming engine for P2P FitTech AI, working with coach ${trainer.name}.
Return one valid JSON object only, with no markdown or extra text.
Build the complete weekly program for the exact selected split.
Select only exercises from the supplied approved library and copy their exact IDs and names.
Respect all selected equipment, duration, focus areas, experience, injuries, limitations, exclusions, intensity, and recovery constraints.
Order compound movements before accessory and isolation work unless there is a stated programming reason.
Use realistic volume, sets, reps, rest, RPE, warm-ups, cool-downs, recovery, cardio, and double-progression guidance.
Every training day must fit the requested session duration and contain 2-8 unique exercises.
`.trim(),
    userMessage: `
WORKOUT PREFERENCES:
${JSON.stringify(preferences)}

SELECTED SPLIT:
${JSON.stringify(split)}

RECENT CONTEXT:
${JSON.stringify({
  flags: memory?.rollingMemory?.flags || [],
  lastSessions: (memory?.rollingMemory?.last3Sessions || []).map((session: any) => ({
    workoutSummary: session.workoutSummary,
    adherence: session.adherence,
    painNotes: session.painNotes,
    flags: session.flags,
  })),
})}

APPROVED EXERCISE LIBRARY:
${JSON.stringify(compactLibrary)}

Return exactly:
{
  "name": "${split.name}",
  "weeklySchedule": ${JSON.stringify(split.weeklySchedule)},
  "workouts": [
    {
      "day": 1,
      "title": "Exact selected schedule title",
      "muscleGroups": ["Primary muscle"],
      "warmUp": [
        { "order": 1, "instruction": "Specific warm-up", "duration": "3 minutes" }
      ],
      "exercises": [
        {
          "exerciseId": "Exact library ID",
          "exerciseName": "Exact library name",
          "sets": 3,
          "reps": "8-12",
          "restTime": "90s",
          "rpe": "7-8",
          "order": 1
        }
      ],
      "coolDown": [
        { "order": 1, "instruction": "Specific cool-down", "duration": "3 minutes" }
      ],
      "estimatedDurationMinutes": ${preferences.duration},
      "cardioGuidance": "Optional day-specific guidance"
    }
  ],
  "progression": {
    "method": "Double progression",
    "guidance": "Specific progression rule"
  },
  "recovery": {
    "guidance": "Specific recovery guidance",
    "restDays": ["Placement guidance"]
  },
  "cardio": {
    "guidance": "Goal-appropriate cardio guidance",
    "frequency": "Weekly frequency"
  }
}
`.trim(),
  };
};

export const generateWorkoutSplits = async (
  userId: string,
  workoutId: string,
  traceId?: string,
) => {
  const requestStartedAt = Date.now();
  let leaseId: string | null = null;
  logWorkoutEvent("WORKOUT_GENERATION_STARTED", workoutId, {
    stage: "splits",
    traceId,
  });
  try {
    const context = await getGenerationContext(userId, workoutId);
    const preferences = buildPreferenceSnapshot(context);

    if (context.workout.splitOptions?.length === 3) {
      logWorkoutEvent("WORKOUT_GENERATION_COMPLETED", workoutId, {
        stage: "splits",
        traceId,
        provider: "cached",
        totalDurationMs: Date.now() - requestStartedAt,
        fallbackUsed: false,
        finalFallbackUsed: false,
      });
      return {
        workoutId,
        userPreferences: preferences,
        splitOptions: context.workout.splitOptions,
      };
    }

    leaseId = await claimGenerationLease(userId, workoutId, "splits");
    if (!leaseId) {
      logWorkoutEvent("WORKOUT_GENERATION_FOLLOWER_WAITING", workoutId, {
        stage: "splits",
      });
      const completed = await waitForGenerationResult(
        userId,
        workoutId,
        "splits",
      );
      return {
        workoutId,
        userPreferences: preferences,
        splitOptions: completed.splitOptions,
      };
    }

    const prompts = buildSplitPrompt(preferences, context.trainer);
    const generated = await callStructuredWorkoutAI({
      workoutId,
      stage: "splits",
      ...prompts,
      maxTokens: 2600,
      validate: (raw) => validateSplitOptions(raw, preferences),
      fallback: () => buildFallbackSplits(preferences),
    });

    context.workout.workoutPreferences = preferences;
    context.workout.splitOptions = generated.value;
    await context.workout.save();
    await releaseGenerationLease(userId, workoutId, "splits", leaseId);
    leaseId = null;
    logWorkoutEvent("WORKOUT_SPLITS_GENERATED", workoutId, {
      provider: generated.provider,
      count: generated.value.length,
    });
    logWorkoutEvent("WORKOUT_SAVED", workoutId, { stage: "splits" });
    logWorkoutEvent("WORKOUT_GENERATION_COMPLETED", workoutId, {
      stage: "splits",
      traceId,
      provider: generated.provider,
      totalDurationMs: Date.now() - requestStartedAt,
      fallbackUsed: generated.provider !== "claude",
      finalFallbackUsed: generated.provider === "library",
    });

    return {
      workoutId,
      userPreferences: preferences,
      splitOptions: generated.value,
    };
  } catch (error) {
    if (leaseId) {
      await releaseGenerationLease(userId, workoutId, "splits", leaseId).catch(
        () => undefined,
      );
    }
    logWorkoutEvent("WORKOUT_GENERATION_FAILED", workoutId, {
      stage: "splits",
      traceId,
      reason: error instanceof Error ? error.message : "unknown",
      totalDurationMs: Date.now() - requestStartedAt,
    });
    throw error;
  }
};

export const generateSelectedWorkoutProgram = async (
  userId: string,
  workoutId: string,
  selectedSplitId: string,
  traceId?: string,
) => {
  const requestStartedAt = Date.now();
  let leaseId: string | null = null;
  logWorkoutEvent("WORKOUT_GENERATION_STARTED", workoutId, {
    stage: "program",
    traceId,
  });
  try {
    const context = await getGenerationContext(userId, workoutId);
    const preferences = buildPreferenceSnapshot(context);
    const selectedSplit = (context.workout.splitOptions || []).find(
      (option) => option.id === selectedSplitId,
    );
    if (!selectedSplit) {
      throw new Error("Choose one of the generated workout split options");
    }
    if (
      (preferences.injuries || []).length > 0 ||
      (preferences.limitations || []).length > 0
    ) {
      throw new Error(
        "This workout requires trainer review because an injury or limitation is on file.",
      );
    }
    logWorkoutEvent("WORKOUT_SPLIT_SELECTED", workoutId, {
      splitId: selectedSplit.id,
    });

    if (
      context.workout.weeklyProgram &&
      context.workout.selectedSplit?.id === selectedSplit.id
    ) {
      logWorkoutEvent("WORKOUT_GENERATION_COMPLETED", workoutId, {
        stage: "program",
        traceId,
        provider: "cached",
        totalDurationMs: Date.now() - requestStartedAt,
        fallbackUsed: false,
        finalFallbackUsed: false,
      });
      return {
        workoutId,
        selectedSplit,
        program: context.workout.weeklyProgram,
        aiPlan: context.workout.aiPlan,
      };
    }

    leaseId = await claimGenerationLease(
      userId,
      workoutId,
      "program",
      selectedSplit.id,
    );
    if (!leaseId) {
      logWorkoutEvent("WORKOUT_GENERATION_FOLLOWER_WAITING", workoutId, {
        stage: "program",
      });
      const completed = await waitForGenerationResult(
        userId,
        workoutId,
        "program",
        selectedSplit.id,
      );
      return {
        workoutId,
        selectedSplit: completed.selectedSplit,
        program: completed.weeklyProgram,
        aiPlan: completed.aiPlan,
      };
    }

    const approvedLibrary = await loadApprovedLibrary(
      context.trainer._id as Types.ObjectId,
      !context.user.subscribedTrainer &&
        (context.user.role === "trainer" || context.user.role === "admin"),
    );
    const eligibleLibrary = filterLibraryForPreferences(
      approvedLibrary,
      preferences,
    );
    const prompts = buildProgramPrompt(
      preferences,
      selectedSplit,
      context.trainer,
      context.memory,
      eligibleLibrary,
    );
    const generated = await callStructuredWorkoutAI({
      workoutId,
      stage: "program",
      ...prompts,
      maxTokens: 6500,
      validate: (raw) =>
        validateWorkoutProgram(raw, preferences, selectedSplit, eligibleLibrary),
      fallback: () =>
        buildFallbackProgram(preferences, selectedSplit, eligibleLibrary),
    });

    const firstDay = generated.value.workouts[0];
    const aiPlan: IAIGeneratedPlan = {
      coachNote: `${context.trainer.name} built this ${selectedSplit.daysPerWeek}-day ${selectedSplit.name} program around your selections.`,
      thisWeekFocus: preferences.focusArea.slice(0, 3),
      nutritionTip:
        "Hydrate consistently and spread protein across meals to support training and recovery.",
      warmUp: firstDay.warmUp,
      mainWork: firstDay.exercises,
      accessories: [],
      finisher: [],
      coolDown: firstDay.coolDown,
      estimatedDurationMinutes: preferences.duration,
      cardioGuidance: firstDay.cardioGuidance || generated.value.cardio.guidance,
      checkInQuestion:
        "Did you complete today's session? What loads did you use and how hard was it (RPE 1-10)? Any pain or equipment issues?",
      generatedAt: new Date(),
      trainerPersona: context.trainer.name,
      trainerSpecialty: context.trainer.specialty,
      aiContextSnapshot: {
        userGoal: preferences.goal.join(", "),
        fitnessLevel: preferences.experienceLevel || "unknown",
        memoryFlags: context.memory?.rollingMemory?.flags || [],
        exerciseBlocksUsed: [
          ...new Set(firstDay.exercises.map((exercise) => exercise.blockName).filter(Boolean)),
        ] as string[],
      },
    };

    context.workout.workoutPreferences = preferences;
    context.workout.selectedSplit = selectedSplit;
    context.workout.weeklyProgram = generated.value;
    context.workout.aiPlan = aiPlan;
    context.workout.status = "pending";
    await context.workout.save();
    await releaseGenerationLease(userId, workoutId, "program", leaseId);
    leaseId = null;

    logWorkoutEvent("WORKOUT_PROGRAM_GENERATED", workoutId, {
      provider: generated.provider,
      days: generated.value.workouts.length,
    });
    logWorkoutEvent("WORKOUT_SAVED", workoutId, { stage: "program" });
    logWorkoutEvent("WORKOUT_GENERATION_COMPLETED", workoutId, {
      stage: "program",
      traceId,
      provider: generated.provider,
      totalDurationMs: Date.now() - requestStartedAt,
      fallbackUsed: generated.provider !== "claude",
      finalFallbackUsed: generated.provider === "library",
    });

    return {
      workoutId,
      selectedSplit,
      program: generated.value,
      aiPlan,
    };
  } catch (error) {
    if (leaseId) {
      await releaseGenerationLease(userId, workoutId, "program", leaseId).catch(
        () => undefined,
      );
    }
    logWorkoutEvent("WORKOUT_GENERATION_FAILED", workoutId, {
      stage: "program",
      traceId,
      reason: error instanceof Error ? error.message : "unknown",
      totalDurationMs: Date.now() - requestStartedAt,
    });
    throw error;
  }
};