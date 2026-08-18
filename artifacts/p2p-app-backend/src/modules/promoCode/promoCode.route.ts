import { Router, Request, Response, NextFunction } from "express";
import { guardRole } from "../../middlewares/roleGuard";
import {
  validatePromoController,
  redeemPromoController,
  importPromoController,
  listPromoController,
  promoStatsController,
  disablePromoController,
  setDefaultTrainerController,
  issueTrialController,
} from "./promoCode.controller";

const router = Router();

// ── Public route ──────────────────────────────────────────────
// POST /promo/validate  → check code, get plan/price (no consume, no auth needed)
// Safe to call before the user has an account — shown at the paywall.
router.post("/validate", validatePromoController);

// ── Authenticated user route ──────────────────────────────────
// POST /promo/redeem    → consume code + grant subscription (requires login)
router.post("/redeem", guardRole(["user", "trainer", "admin"]), redeemPromoController);

// ── Admin routes ──────────────────────────────────────────────
// POST  /promo/import           → bulk-load pre-generated codes
// GET   /promo                  → list/filter codes (paginated)
// GET   /promo/stats            → affiliate redemption reporting
// PATCH /promo/:code/disable    → disable / re-enable a code
// POST  /promo/default-trainer  → set the default app trainer

router.post("/import", guardRole("admin"), importPromoController);
router.get("/stats", guardRole("admin"), promoStatsController);
router.get("/", guardRole("admin"), listPromoController);
router.patch("/:code/disable", guardRole("admin"), disablePromoController);
router.post(
  "/default-trainer",
  guardRole("admin"),
  setDefaultTrainerController,
);

// ── Service route (admin-key guarded) ────────────────────────
// POST /promo/issue-trial → generate a 7-day trial code (called by API server after $4.99 payment)
const adminKeyGuard = (req: Request, res: Response, next: NextFunction) => {
  const key = req.headers["x-admin-key"] as string;
  const expected = process.env.ADMIN_BYPASS_CODE || "2931";
  if (key !== expected) {
    res.status(401).json({ success: false, message: "Unauthorized" });
    return;
  }
  next();
};

router.post("/issue-trial", adminKeyGuard, issueTrialController);

export const PromoCodeRoutes = router;
