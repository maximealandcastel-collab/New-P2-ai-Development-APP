import { Router } from "express";
import { guardRole } from "../../middlewares/roleGuard";
import { AdminController } from "./admin.controller";

const router = Router();

// All admin routes require admin role (verified JWT with role:"admin" OR valid
// x-admin-key from ADMIN_BYPASS_CODE env var — no hardcoded default).
router
  .route("/change-user/status/:userId")
  .get(guardRole(["admin"]), AdminController.changeUserStatus);

router.get("/metrics",  guardRole(["admin"]), AdminController.getMetrics);
router.get("/users",    guardRole(["admin"]), AdminController.getUsersByFilter);
router.patch("/users/:userId/verify",   guardRole(["admin"]), AdminController.setVerified);
router.patch("/users/:userId/role",     guardRole(["admin"]), AdminController.setRole);
router.patch("/users/:userId/suspend",  guardRole(["admin"]), AdminController.suspendUser);
router.patch("/users/:userId/grant-access", guardRole(["admin"]), AdminController.grantAccess);
router.patch("/fix-role",               guardRole(["admin"]), AdminController.fixRoleByEmail);

export const AdminRoutes = router;
