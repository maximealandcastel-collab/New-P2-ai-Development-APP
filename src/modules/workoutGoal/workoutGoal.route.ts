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
// DELETE /workouts/:id          → permanently delete the user's workout

// Trainers can also use the workout generator (e.g. owner testing the feature)
router.post("/", guardRole(["user", "trainer"]), createWorkout);
router.get("/", guardRole(["user", "trainer"]), getUserWorkouts);
router.get("/today", guardRole(["user", "trainer"]), getTodaysWorkout); // ← must stay before /:id
router.get("/today/overview", guardRole(["user", "trainer"]), getTodaysOverview); // ← must stay before /:id
router.get("/progression/monthly", guardRole(["user", "trainer"]), getMonthlyProgression); // ← must stay before /:id
router.get("/:id", guardRole(["user", "trainer"]), getWorkout);
router.delete("/:id", guardRole(["user", "trainer"]), deleteWorkout);

// ── AI Plan generation ────────────────────────────────────────
// POST /workouts/:id/generate → trigger AI to generate plan

router.post("/:id/generate", guardRole(["user", "trainer"]), generatePlan);

// ── Session lifecycle ─────────────────────────────────────────
// PATCH  /workouts/:id/start
// PATCH  /workouts/:id/exercises/:exerciseId/complete
// POST   /workouts/:id/complete
// PATCH  /workouts/:id/skip

router.patch("/:id/start", guardRole(["user", "trainer"]), startSession);
router.patch(
  "/:id/exercises/:exerciseId/complete",
  guardRole(["user", "trainer"]),
  completeExercise,
);
router.post("/:id/complete", guardRole(["user", "trainer"]), completeSession);
router.patch("/:id/skip", guardRole(["user", "trainer"]), skipSession);

export const WorkoutRoutes = router;
