/**
 * workoutPlan.route.ts
 * Mounted at /api/v1/workout-plan
 *
 * Trainer creates/manages custom plans for subscribed clients.
 * Client views their plans.
 */

import { Router, Request, Response } from "express";
import { guardRole } from "../../middlewares/roleGuard";
import { WorkoutPlanModel } from "./workoutPlan.model";
import { SubscriptionModel } from "../subscription/subscription.model";
import { TrainerModel } from "../trainer/trainer.model";

const router = Router();

// ─────────────────────────────────────────────────────────────
// CLIENT — view my plans
// GET /api/v1/workout-plan/my-plans
// ─────────────────────────────────────────────────────────────
router.get(
  "/my-plans",
  guardRole(["user"]),
  async (req: Request, res: Response): Promise<void> => {
    try {
      const clientId = (req as any).user?.id;
      const plans = await WorkoutPlanModel.find({ clientId, isActive: true })
        .populate("trainerId", "name profileImage specialty")
        .sort({ createdAt: -1 })
        .lean();

      res.json({ success: true, data: { plans } });
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  },
);

// ─────────────────────────────────────────────────────────────
// TRAINER — list plans I've created (optionally filter by client)
// GET /api/v1/workout-plan/trainer/my-plans
// NOTE: must be registered BEFORE /:planId or Express matches "trainer" as a planId
// ─────────────────────────────────────────────────────────────
router.get(
  "/trainer/my-plans",
  guardRole(["trainer"]),
  async (req: Request, res: Response): Promise<void> => {
    try {
      const userId    = (req as any).user?.id;
      const trainerDoc = await TrainerModel.findOne({ userId }).select("_id").lean();
      if (!trainerDoc) {
        res.status(404).json({ success: false, message: "Trainer profile not found" });
        return;
      }

      const clientId = req.query.clientId as string | undefined;
      const query: any = { trainerId: trainerDoc._id };
      if (clientId) query.clientId = clientId;

      const plans = await WorkoutPlanModel.find(query)
        .populate("clientId", "firstName lastName email profilePicture")
        .sort({ createdAt: -1 })
        .lean();

      res.json({ success: true, data: { plans } });
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  },
);

// ─────────────────────────────────────────────────────────────
// CLIENT — view single plan
// GET /api/v1/workout-plan/:planId
// ─────────────────────────────────────────────────────────────
router.get(
  "/:planId",
  guardRole(["user", "trainer"]),
  async (req: Request, res: Response): Promise<void> => {
    try {
      const userId = (req as any).user?.id;
      const role   = (req as any).user?.role;

      const plan = await WorkoutPlanModel.findById(req.params.planId)
        .populate("trainerId", "name profileImage specialty")
        .populate("clientId",  "firstName lastName email profilePicture")
        .lean();

      if (!plan) {
        res.status(404).json({ success: false, message: "Plan not found" });
        return;
      }

      // Trainers can only see plans they created; clients can only see their own
      const trainerDoc = role === "trainer"
        ? await TrainerModel.findOne({ userId }).select("_id").lean()
        : null;

      const authorized =
        role === "admin" ||
        String(plan.clientId) === userId ||
        (trainerDoc && String(plan.trainerId) === String(trainerDoc._id));

      if (!authorized) {
        res.status(403).json({ success: false, message: "Not authorized" });
        return;
      }

      res.json({ success: true, data: { plan } });
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  },
);

// ─────────────────────────────────────────────────────────────
// TRAINER — create a plan for a subscribed client
// POST /api/v1/workout-plan
// ─────────────────────────────────────────────────────────────
router.post(
  "/",
  guardRole(["trainer"]),
  async (req: Request, res: Response): Promise<void> => {
    try {
      const userId     = (req as any).user?.id;
      const trainerDoc = await TrainerModel.findOne({ userId }).select("_id").lean();
      if (!trainerDoc) {
        res.status(404).json({ success: false, message: "Trainer profile not found" });
        return;
      }

      const {
        clientId, title, description,
        durationWeeks, daysPerWeek, goal, difficulty,
        weeks, nutritionNotes, recoveryNotes,
        startDate, endDate,
      } = req.body;

      if (!clientId) {
        res.status(400).json({ success: false, message: "clientId required" });
        return;
      }
      if (!title) {
        res.status(400).json({ success: false, message: "title required" });
        return;
      }
      if (!goal) {
        res.status(400).json({ success: false, message: "goal required" });
        return;
      }

      // Confirm the client is subscribed to this trainer
      const sub = await SubscriptionModel.findOne({
        userId: clientId,
        trainerId: trainerDoc._id,
        status: "active",
      });
      if (!sub) {
        res.status(403).json({
          success: false,
          message: "Client does not have an active subscription to this trainer",
        });
        return;
      }

      const plan = await WorkoutPlanModel.create({
        trainerId: trainerDoc._id,
        clientId,
        title,
        description,
        durationWeeks: durationWeeks || 4,
        daysPerWeek:   daysPerWeek   || 3,
        goal,
        difficulty: difficulty || "beginner",
        weeks: weeks || [],
        nutritionNotes,
        recoveryNotes,
        isActive: true,
        startDate: startDate ? new Date(startDate) : undefined,
        endDate:   endDate   ? new Date(endDate)   : undefined,
      });

      res.status(201).json({ success: true, data: { plan } });
    } catch (err: any) {
      res.status(400).json({ success: false, message: err.message });
    }
  },
);

// ─────────────────────────────────────────────────────────────
// TRAINER — update a plan
// PUT /api/v1/workout-plan/:planId
// ─────────────────────────────────────────────────────────────
router.put(
  "/:planId",
  guardRole(["trainer"]),
  async (req: Request, res: Response): Promise<void> => {
    try {
      const userId     = (req as any).user?.id;
      const trainerDoc = await TrainerModel.findOne({ userId }).select("_id").lean();
      if (!trainerDoc) {
        res.status(404).json({ success: false, message: "Trainer profile not found" });
        return;
      }

      const plan = await WorkoutPlanModel.findOne({
        _id:       req.params.planId,
        trainerId: trainerDoc._id,
      });
      if (!plan) {
        res.status(404).json({ success: false, message: "Plan not found or not yours" });
        return;
      }

      const allowed = [
        "title","description","durationWeeks","daysPerWeek",
        "goal","difficulty","weeks","nutritionNotes","recoveryNotes",
        "isActive","startDate","endDate",
      ];
      allowed.forEach(key => {
        if (req.body[key] !== undefined) (plan as any)[key] = req.body[key];
      });

      await plan.save();
      res.json({ success: true, data: { plan } });
    } catch (err: any) {
      res.status(400).json({ success: false, message: err.message });
    }
  },
);

// ─────────────────────────────────────────────────────────────
// TRAINER — delete a plan
// DELETE /api/v1/workout-plan/:planId
// ─────────────────────────────────────────────────────────────
router.delete(
  "/:planId",
  guardRole(["trainer"]),
  async (req: Request, res: Response): Promise<void> => {
    try {
      const userId     = (req as any).user?.id;
      const trainerDoc = await TrainerModel.findOne({ userId }).select("_id").lean();
      if (!trainerDoc) {
        res.status(404).json({ success: false, message: "Trainer profile not found" });
        return;
      }

      await WorkoutPlanModel.findOneAndDelete({
        _id:       req.params.planId,
        trainerId: trainerDoc._id,
      });

      res.json({ success: true, message: "Plan deleted" });
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  },
);

export const WorkoutPlanRoutes = router;
