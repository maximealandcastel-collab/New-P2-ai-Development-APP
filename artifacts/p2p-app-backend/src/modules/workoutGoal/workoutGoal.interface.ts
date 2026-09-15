import { Document, Types } from "mongoose";

// ─────────────────────────────────────────────────────────────
// ENUMS
// ─────────────────────────────────────────────────────────────

export type TWorkoutGoal =
  | "maintain_physique"
  | "muscle_gain"
  | "weight_loss"
  | "boxing"
  | "strength"
  | "endurance"
  | "flexibility";

export type TFocusArea =
  | "upper_body"
  | "lower_body"
  | "chest"
  | "back"
  | "shoulders"
  | "arms"
  | "legs"
  | "glutes"
  | "core"
  | "full_body"
  | "cardio"
  | "boxing";

export type TWorkoutEnvironment =
  | "full_gym"
  | "home"
  | "office"
  | "hotel_gym"
  | "outdoor"
  | "no_equipment";

export type TEquipmentAvailability =
  | "barbell"
  | "dumbbells"
  | "machines"
  | "resistance_bands"
  | "kettlebells"
  | "pull_up_bar"
  | "bench"
  | "cable_machine"
  | "treadmill"
  | "others"
  | "bodyweight_only"
  | "no_equipment"
  | "boxing_bag"
  | "jump_rope";

export type TWorkoutIntensity = "light" | "moderate" | "intense" | "max_effort";

export type TSessionStatus =
  | "pending"
  | "in_progress"
  | "completed"
  | "skipped";

// ─────────────────────────────────────────────────────────────
// EXERCISE STEP (snapshot copied from ExerciseStep collection)
// ─────────────────────────────────────────────────────────────

export interface IPlannedExerciseStep {
  order: number;
  instruction: string;
  tip?: string;
  duration?: string;
}

// ─────────────────────────────────────────────────────────────
// SUBSTITUTIONS (snapshot copied from Exercise collection)
// ─────────────────────────────────────────────────────────────

export interface IPlannedSubstitutions {
  noBarbell?: string;
  noMachine?: string;
  homeOnly?: string;
  hotelGym?: string;
}

// ─────────────────────────────────────────────────────────────
// PLANNED EXERCISE
// AI selects from separate Exercise + ExerciseBlock collections
// Full data snapshotted here so workout is self-contained
// ─────────────────────────────────────────────────────────────

export interface IPlannedExercise {
  // References to separate collections
  exerciseId?: Types.ObjectId; // ref → exercises collection
  blockId?: Types.ObjectId; // ref → exercise_blocks collection
  blockName?: string;
  exerciseName: string;
  muscleGroup?: string;

  // Trainer-defined prescription (snapshotted from Exercise doc)
  sets: number;
  reps: string; // "8-12" or "30 seconds"
  restTime: string; // "60s"
  rpe?: string; // "7-8"

  // Snapshotted from ExerciseStep collection
  steps: IPlannedExerciseStep[];

  // Snapshotted from Exercise collection
  substitutions?: IPlannedSubstitutions;

  // Position in today's session
  order: number;

  // Completion tracking — filled by user during session
  isCompleted: boolean;
  completedSets?: number;
  actualWeight?: string; // "135lb"
  actualRpe?: number;
  notes?: string;
}

// ─────────────────────────────────────────────────────────────
// WARM UP / COOL DOWN STEP
// ─────────────────────────────────────────────────────────────

export interface ISessionStep {
  order: number;
  instruction: string;
  duration: string;
}

// ─────────────────────────────────────────────────────────────
// TWO-STAGE WORKOUT PROGRAM
// Split recommendations are saved before the user chooses one.
// The complete weekly program is saved after that choice.
// ─────────────────────────────────────────────────────────────

export interface IWorkoutPreferenceSnapshot {
  goal: string[];
  focusArea: string[];
  workout_environment: string[];
  equipment_availablity: string[];
  workout_intensity: string[];
  duration: number;
  facilityId?: string;
  facilityEquipment?: string[];
  selectedEquipment?: string[];
  daysPerWeek?: number;
  experienceLevel?: string;
  cardioPreference?: string;
  trainingStyle?: string;
  preferredExercises?: string[];
  excludedExercises?: string[];
  limitations?: string[];
  injuries?: string[];
}

export interface IWorkoutSplitOption {
  id: string;
  name: string;
  weeklySchedule: string[];
  primaryGoal: string;
  recommendedFor: string;
  reason: string;
  estimatedSessionMinutes: number;
  difficulty: string;
  recoveryRequirement: string;
  daysPerWeek: number;
}

export interface IWorkoutDay {
  day: number;
  title: string;
  muscleGroups: string[];
  warmUp: ISessionStep[];
  exercises: IPlannedExercise[];
  coolDown: ISessionStep[];
  estimatedDurationMinutes: number;
  cardioGuidance?: string;
}

export interface IWorkoutProgram {
  name: string;
  goal: string;
  experienceLevel: string;
  daysPerWeek: number;
  estimatedSessionMinutes: number;
  weeklySchedule: string[];
  workouts: IWorkoutDay[];
  progression: {
    method: string;
    guidance: string;
  };
  recovery: {
    guidance: string;
    restDays?: string[];
  };
  cardio: {
    guidance: string;
    frequency?: string;
  };
  generatedAt: Date;
}

// ─────────────────────────────────────────────────────────────
// AI GENERATED PLAN
// Attached to workout document after user hits "Generate"
// ─────────────────────────────────────────────────────────────

export interface IAIGeneratedPlan {
  // Coach overview
  coachNote: string;
  thisWeekFocus: string[]; // max 3 bullets
  nutritionTip?: string;

  // Session structure
  warmUp: ISessionStep[];
  mainWork: IPlannedExercise[];
  accessories: IPlannedExercise[];
  finisher: IPlannedExercise[];
  coolDown: ISessionStep[];

  estimatedDurationMinutes: number;
  cardioGuidance?: string;

  // Suggested video matching client preferences
  suggestedVideo?: string;

  // Check-in — filled after session
  checkInQuestion: string;
  checkInResponse?: string;
  checkInRespondedAt?: Date;

  // Generation metadata
  generatedAt: Date;
  trainerPersona: string; // "Gabriel Rowling"
  trainerSpecialty: string; // "maintain_physique"

  // Context snapshot for debugging / memory
  aiContextSnapshot?: {
    userGoal: string;
    fitnessLevel: string;
    memoryFlags: string[];
    exerciseBlocksUsed: string[]; // block names AI picked from
  };
}

// ─────────────────────────────────────────────────────────────
// MAIN WORKOUT INTERFACE
// ─────────────────────────────────────────────────────────────

export interface IWorkout extends Document {
  // ── User input (form fields — unchanged) ──────────────────
  userId: Types.ObjectId;
  goal: string[]; // ["maintain_physique"]
  focusArea: string[]; // ["upper_body", "chest"]
  workout_environment: string[]; // ["full_gym"]
  equipment_availablity: string[]; // ["barbell", "dumbbells"]
  workout_intensity: string[]; // ["moderate"]
  duration: number; // minutes
  date: Date;

  // ── Trainer reference (from new separate collection) ──────
  trainerId?: Types.ObjectId; // ref → trainers collection

  // ── AI generated plan (null until user hits Generate) ─────
  aiPlan?: IAIGeneratedPlan;
  workoutPreferences?: IWorkoutPreferenceSnapshot;
  splitOptions?: IWorkoutSplitOption[];
  selectedSplit?: IWorkoutSplitOption;
  weeklyProgram?: IWorkoutProgram;
  generationLeases?: {
    splits?: { leaseId: string; startedAt: Date };
    program?: { leaseId: string; startedAt: Date };
  };

  // ── Session lifecycle ─────────────────────────────────────
  status: TSessionStatus;
  startedAt?: Date;
  completedAt?: Date;
  actualDurationMinutes?: number;

  // ── Timestamps ────────────────────────────────────────────
  createdAt: Date;
  updatedAt: Date;
}
