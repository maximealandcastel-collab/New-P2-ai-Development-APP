import express from "express";
import { verifyIAPController } from "./iap.controller";
import { guardRole } from "../../middlewares/roleGuard";

const router = express.Router();

// Both roles use the universal paid signup flow; identity still comes from JWT.
router.post("/verify", guardRole(["user", "trainer"]), verifyIAPController);

export const IAPRoutes = router;
