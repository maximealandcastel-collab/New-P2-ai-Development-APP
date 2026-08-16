import { Router } from "express";
import { guardRole } from "../../middlewares/roleGuard";
import {
  getEarningsController,
  getPaymentHistoryController,
  requestWithdrawalController,
  getMyWithdrawalsController,
  getAllWithdrawalsController,
  approveWithdrawalController,
  markPaidController,
  rejectWithdrawalController,
} from "./withdrawal.controller";

const router = Router();

// ── Trainer routes ────────────────────────────────────────────
// GET  /withdrawals/earnings   → full earnings dashboard
// GET  /withdrawals/payments   → payment history per subscriber
// GET  /withdrawals/my         → trainer's withdrawal requests
// POST /withdrawals            → submit withdrawal request

router.get("/earnings", guardRole("trainer"), getEarningsController);
router.get("/payments", guardRole("trainer"), getPaymentHistoryController);
router.get("/my", guardRole("trainer"), getMyWithdrawalsController);
router.post("/", guardRole("trainer"), requestWithdrawalController);

// ── Admin routes ──────────────────────────────────────────────
// All require admin role (JWT with role:"admin" issued by the bypass endpoint,
// or x-admin-key matching ADMIN_BYPASS_CODE env var — no hardcoded default).
// GET   /withdrawals/admin/all        → all withdrawal requests
// PATCH /withdrawals/:id/approve      → approve request
// PATCH /withdrawals/:id/paid         → confirm payment sent
// PATCH /withdrawals/:id/reject       → reject with reason

router.get("/admin/all", guardRole(["admin"]), getAllWithdrawalsController);
router.patch("/:id/approve", guardRole(["admin"]), approveWithdrawalController);
router.patch("/:id/paid", guardRole(["admin"]), markPaidController);
router.patch("/:id/reject", guardRole(["admin"]), rejectWithdrawalController);

export const WithdrawalRoutes = router;
