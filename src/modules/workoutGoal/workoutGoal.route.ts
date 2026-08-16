import { Router } from "express";
import { protect } from "../../middlewares/auth";
import {
  completeExercise,
  completeSession,
  createWorkout,
  deleteWorkout,
  generatePlan,
  getTodaysWorkout,
  getTodaysOverview,
  getMonthlyProgression,
  getUserWorkouts,
  getWorkout,
  skipSession,
  startSession, // ← imported from controller, NOT from mongoose
} from "./workoutGoal.controller";
import { guardRole } from "../../middlewares/roleGuard";

const router = Router();

// All workout routes require authentication

// ── Workout preferences ───────────────────────────────────────
// POST   /workouts              → save preferences (no AI yet)
// GET    /workouts              → get all user workouts
// GET    /workouts/today        → get today's workout (before /:id)
// GET    /workouts/today/overview → get today's workout overview with completion percentage (before /:id)
// GET    /workouts/progression/monthly → get 30 days progression report (before /:id)
// GET    /workouts/:id          → get single workout
// DELETE /workouts/:id          → delete pending workout

// Trainers can also use the workout generator (e.g. owner testing the feature)
const workoutRoles = ["user", "trainer"];

router.post("/", guardRole(workoutRoles), createWorkout);
router.get("/", guardRole(workoutRoles), getUserWorkouts);
router.get("/today", guardRole(workoutRoles), getTodaysWorkout); // ← must stay before /:id
router.get("/today/overview", guardRole(workoutRoles), getTodaysOverview); // ← must stay before /:id
router.get("/progression/monthly", guardRole(workoutRoles), getMonthlyProgression); // ← must stay before /:id
router.get("/:id", guardRole(workoutRoles), getWorkout);
router.delete("/:id", guardRole(workoutRoles), deleteWorkout);

// ── AI Plan generation ────────────────────────────────────────
// POST /workouts/:id/generate → trigger AI to generate plan

router.post("/:id/generate", guardRole(workoutRoles), generatePlan);

// ── Session lifecycle ─────────────────────────────────────────
// PATCH  /workouts/:id/start
// PATCH  /workouts/:id/exercises/:exerciseId/complete
// POST   /workouts/:id/complete
// PATCH  /workouts/:id/skip

router.patch("/:id/start", guardRole(workoutRoles), startSession);
router.patch(
  "/:id/exercises/:exerciseId/complete",
  guardRole(workoutRoles),
  completeExercise,
);
router.post("/:id/complete", guardRole(workoutRoles), completeSession);
router.patch("/:id/skip", guardRole(workoutRoles), skipSession);

export const WorkoutRoutes = router;
