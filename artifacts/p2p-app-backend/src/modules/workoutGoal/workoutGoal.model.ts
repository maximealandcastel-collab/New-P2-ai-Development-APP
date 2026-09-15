import mongoose, { Schema } from "mongoose";
import { IWorkout } from "./workoutGoal.interface";

// ─────────────────────────────────────────────────────────────
// SUB-SCHEMAS
// ─────────────────────────────────────────────────────────────

const plannedExerciseStepSchema = new Schema(
  {
    order: { type: Number, required: true },
    instruction: { type: String, required: true },
    tip: { type: String },
    duration: { type: String },
  },
  { _id: false },
);

const plannedSubstitutionsSchema = new Schema(
  {
    noBarbell: { type: String },
    noMachine: { type: String },
    homeOnly: { type: String },
    hotelGym: { type: String },
  },
  { _id: false },
);

// Single exercise AI picked from Exercise + ExerciseBlock collections
// Full data is snapshotted here — workout stays self-contained
const plannedExerciseSchema = new Schema(
  {
    // References to separate collections
    exerciseId: { type: Schema.Types.ObjectId, ref: "Exercise" },
    blockId: { type: Schema.Types.ObjectId, ref: "ExerciseBlock" },
    blockName: { type: String },
    exerciseName: { type: String, required: true },
    muscleGroup: { type: String },

    // Prescription snapshotted from Exercise doc
    sets: { type: Number, required: true },
    reps: { type: String, required: true },
    restTime: { type: String, default: "60s" },
    rpe: { type: String },

    // Steps snapshotted from ExerciseStep collection
    steps: [plannedExerciseStepSchema],

    // Substitutions snapshotted from Exercise doc
    substitutions: { type: plannedSubstitutionsSchema },

    // Position in today's session
    order: { type: Number, required: true },

    // Completion tracking — filled by user
    isCompleted: { type: Boolean, default: false },
    completedSets: { type: Number },
    actualWeight: { type: String },
    actualRpe: { type: Number, min: 1, max: 10 },
    notes: { type: String },
  },
  { _id: true },
);

// Warm-up / Cool-down step
const sessionStepSchema = new Schema(
  {
    order: { type: Number, required: true },
    instruction: { type: String, required: true },
    duration: { type: String, required: true },
  },
  { _id: false },
);

const workoutPreferenceSnapshotSchema = new Schema(
  {
    goal: [{ type: String }],
    focusArea: [{ type: String }],
    workout_environment: [{ type: String }],
    equipment_availablity: [{ type: String }],
    workout_intensity: [{ type: String }],
    duration: { type: Number },
    facilityId: { type: String },
    facilityEquipment: { type: [String], default: undefined },
    selectedEquipment: { type: [String], default: undefined },
    daysPerWeek: { type: Number, min: 2, max: 6 },
    experienceLevel: { type: String },
    cardioPreference: { type: String },
    trainingStyle: { type: String },
    preferredExercises: [{ type: String }],
    excludedExercises: [{ type: String }],
    limitations: [{ type: String }],
    injuries: [{ type: String }],
  },
  { _id: false },
);

const workoutSplitOptionSchema = new Schema(
  {
    id: { type: String, required: true },
    name: { type: String, required: true },
    weeklySchedule: [{ type: String, required: true }],
    primaryGoal: { type: String, required: true },
    recommendedFor: { type: String, required: true },
    reason: { type: String, required: true },
    estimatedSessionMinutes: { type: Number, required: true },
    difficulty: { type: String, required: true },
    recoveryRequirement: { type: String, required: true },
    daysPerWeek: { type: Number, required: true, min: 2, max: 6 },
  },
  { _id: false },
);

const workoutDaySchema = new Schema(
  {
    day: { type: Number, required: true },
    title: { type: String, required: true },
    muscleGroups: [{ type: String }],
    warmUp: [sessionStepSchema],
    exercises: [plannedExerciseSchema],
    coolDown: [sessionStepSchema],
    estimatedDurationMinutes: { type: Number, required: true },
    cardioGuidance: { type: String },
  },
  { _id: false },
);

const workoutProgramSchema = new Schema(
  {
    name: { type: String, required: true },
    goal: { type: String, required: true },
    experienceLevel: { type: String, required: true },
    daysPerWeek: { type: Number, required: true, min: 2, max: 6 },
    estimatedSessionMinutes: { type: Number, required: true },
    weeklySchedule: [{ type: String }],
    workouts: [workoutDaySchema],
    progression: {
      method: { type: String, required: true },
      guidance: { type: String, required: true },
    },
    recovery: {
      guidance: { type: String, required: true },
      restDays: [{ type: String }],
    },
    cardio: {
      guidance: { type: String, required: true },
      frequency: { type: String },
    },
    generatedAt: { type: Date, default: Date.now },
  },
  { _id: false },
);

// Full AI generated plan — null until user hits "Generate"
const aiGeneratedPlanSchema = new Schema(
  {
    coachNote: { type: String },
    thisWeekFocus: [{ type: String }],
    nutritionTip: { type: String },

    warmUp: [sessionStepSchema],
    mainWork: [plannedExerciseSchema],
    accessories: [plannedExerciseSchema],
    finisher: [plannedExerciseSchema],
    coolDown: [sessionStepSchema],

    estimatedDurationMinutes: { type: Number },
    cardioGuidance: { type: String },
    suggestedVideo: { type: String },

    checkInQuestion: { type: String },
    checkInResponse: { type: String },
    checkInRespondedAt: { type: Date },

    generatedAt: { type: Date, default: Date.now },
    trainerPersona: { type: String },
    trainerSpecialty: { type: String },

    aiContextSnapshot: {
      userGoal: { type: String },
      fitnessLevel: { type: String },
      memoryFlags: [{ type: String }],
      exerciseBlocksUsed: [{ type: String }],
    },
  },
  { _id: false },
);

// ─────────────────────────────────────────────────────────────
// MAIN WORKOUT SCHEMA
// ─────────────────────────────────────────────────────────────

const WorkoutSchema: Schema<IWorkout> = new Schema(
  {
    // ── User input (unchanged) ────────────────────────────────
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    goal: {
      type: [{ type: String, enum: ["maintain_physique", "muscle_gain", "weight_loss", "boxing", "strength", "endurance", "flexibility"] }],
      required: true,
    },
    focusArea: {
      type: [{ type: String, enum: ["upper_body", "lower_body", "chest", "back", "shoulders", "arms", "legs", "glutes", "core", "full_body", "cardio", "boxing"] }],
      required: true,
    },
    workout_environment: {
      type: [{ type: String, enum: ["full_gym", "home", "office", "hotel_gym", "outdoor", "no_equipment"] }],
      required: true,
    },
    equipment_availablity: {
      type: [{ type: String, enum: ["barbell", "dumbbells", "machines", "resistance_bands", "kettlebells", "pull_up_bar", "bench", "cable_machine", "treadmill", "others", "bodyweight_only", "no_equipment", "boxing_bag", "jump_rope"] }],
      required: true,
    },
    workout_intensity: {
      type: [{ type: String, enum: ["light", "moderate", "intense", "max_effort"] }],
      required: true,
    },
    duration: { type: Number, required: true },
    date: { type: Date, required: true },

    // ── Trainer reference (separate collection) ───────────────
    trainerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Trainer",
      required: false,
    },

    // ── AI generated plan ─────────────────────────────────────
    aiPlan: {
      type: aiGeneratedPlanSchema,
      required: false,
      default: null,
    },
    workoutPreferences: {
      type: workoutPreferenceSnapshotSchema,
      required: false,
    },
    splitOptions: {
      type: [workoutSplitOptionSchema],
      required: false,
      default: [],
    },
    selectedSplit: {
      type: workoutSplitOptionSchema,
      required: false,
    },
    weeklyProgram: {
      type: workoutProgramSchema,
      required: false,
    },
    generationLeases: {
      splits: {
        type: new Schema(
          {
            leaseId: { type: String, required: true },
            startedAt: { type: Date, required: true },
          },
          { _id: false },
        ),
        required: false,
      },
      program: {
        type: new Schema(
          {
            leaseId: { type: String, required: true },
            startedAt: { type: Date, required: true },
          },
          { _id: false },
        ),
        required: false,
      },
    },

    // ── Session lifecycle ─────────────────────────────────────
    status: {
      type: String,
      enum: ["pending", "in_progress", "completed", "skipped"],
      default: "pending",
    },
    startedAt: { type: Date },
    completedAt: { type: Date },
    actualDurationMinutes: { type: Number },
  },
  { timestamps: true },
);

// ─────────────────────────────────────────────────────────────
// INDEXES
// ─────────────────────────────────────────────────────────────

WorkoutSchema.index({ userId: 1, date: -1 });
WorkoutSchema.index({ userId: 1, status: 1 });
WorkoutSchema.index({ trainerId: 1 });

// ─────────────────────────────────────────────────────────────
// MODEL — guard prevents OverwriteModelError
// ─────────────────────────────────────────────────────────────

export const WorkoutModel =
  (mongoose.models.Workout as mongoose.Model<IWorkout>) ||
  mongoose.model<IWorkout>("Workout", WorkoutSchema);
