/**
 * Mux Routes
 *
 * POST /api/v1/mux/upload-url   – get a direct-upload URL (auth required)
 * POST /api/v1/mux/webhook      – receive Mux webhook events (signature verified)
 * POST /api/v1/mux/migrate/:id  – trigger legacy→Mux migration for one video (admin only)
 * GET  /api/v1/mux/status/:id   – check processing status of a content item
 */

import express, { Request, Response } from "express";
import crypto from "crypto";
import {
  isMuxConfigured,
  createDirectUpload,
  handleMuxWebhook,
  migrateLegacyVideoToMux,
  runMigrationBackground,
  migrationState,
  startMuxStatusPoller,
} from "./mux.service";
import { ContentModel } from "../content/content.model";

const router = express.Router();

// ── Guard: reject all Mux routes if credentials are missing ──────────────────
router.use((_req, res, next) => {
  if (!isMuxConfigured()) {
    res
      .status(503)
      .json({ success: false, message: "Mux is not configured on this server" });
    return;
  }
  next();
});

// ── POST /upload-url ─────────────────────────────────────────────────────────
// Client sends the contentId of an already-created Content document.
// Backend returns a signed direct-upload URL; client uploads directly to Mux.
// Never expose MUX_TOKEN_SECRET to the client.
router.post("/upload-url", async (req: Request, res: Response) => {
  try {
    const { contentId } = req.body as { contentId?: string };
    if (!contentId) {
      res.status(400).json({ success: false, message: "contentId is required" });
      return;
    }
    const result = await createDirectUpload(contentId);
    res.status(200).json({ success: true, data: result });
  } catch (err: any) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// ── POST /webhook ─────────────────────────────────────────────────────────────
// Mux sends webhook events here. We verify the signature before processing.
router.post(
  "/webhook",
  express.raw({ type: "application/json" }),
  async (req: Request, res: Response) => {
    const webhookSecret = process.env.MUX_WEBHOOK_SECRET;
    if (!webhookSecret) {
      res.status(503).json({ message: "Webhook secret not configured" });
      return;
    }

    // Verify Mux signature
    const signature = req.headers["mux-signature"] as string | undefined;
    if (!signature) {
      res.status(401).json({ message: "Missing Mux-Signature header" });
      return;
    }

    try {
      // Mux signature format: t=<timestamp>,v1=<hmac>
      const parts: Record<string, string> = {};
      signature.split(",").forEach((part) => {
        const [k, v] = part.split("=");
        parts[k] = v;
      });

      const timestamp = parts["t"];
      const expectedSig = parts["v1"];
      if (!timestamp || !expectedSig) throw new Error("Malformed signature");

      const payload = `${timestamp}.${req.body.toString()}`;
      const computed = crypto
        .createHmac("sha256", webhookSecret)
        .update(payload)
        .digest("hex");

      if (
        !crypto.timingSafeEqual(
          Buffer.from(computed, "hex"),
          Buffer.from(expectedSig, "hex")
        )
      ) {
        res.status(401).json({ message: "Signature mismatch" });
        return;
      }

      const event = JSON.parse(req.body.toString());
      await handleMuxWebhook(event);
      res.status(200).json({ received: true });
    } catch (err: any) {
      console.error("[Mux webhook]", err);
      res.status(400).json({ message: err.message });
    }
  }
);

// ── POST /migrate/:id ─────────────────────────────────────────────────────────
// Admin-only: migrate a single legacy GCS video to Mux.
// Protected by the admin key header.
router.post("/migrate/:id", async (req: Request, res: Response) => {
  const adminKey = req.headers["x-admin-key"];
  const validKey = process.env.ADMIN_KEY;
  if (!validKey || adminKey !== validKey) {
    res.status(403).json({ success: false, message: "Forbidden" });
    return;
  }
  try {
    await migrateLegacyVideoToMux(req.params.id);
    res.status(200).json({ success: true, message: "Migration started" });
  } catch (err: any) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// ── POST /run-migration ───────────────────────────────────────────────────────
// Starts the full legacy→Mux migration as a background task inside this process.
// Returns immediately; poll GET /migration-status for progress.
router.post("/run-migration", (req: Request, res: Response) => {
  const adminKey = req.headers["x-admin-key"];
  const validKey = process.env.ADMIN_KEY;
  if (!validKey || adminKey !== validKey) {
    res.status(403).json({ success: false, message: "Forbidden" });
    return;
  }
  if (migrationState.running) {
    res.status(200).json({ success: true, message: "Already running", state: migrationState });
    return;
  }
  // Fire and forget — runs in the background, no await
  runMigrationBackground().catch(err =>
    console.error("[MuxMigrate] Fatal:", err.message)
  );
  // Start the status poller (no-op if already running)
  startMuxStatusPoller();
  res.status(200).json({ success: true, message: "Migration started in background", state: migrationState });
});

// ── GET /migration-status ─────────────────────────────────────────────────────
router.get("/migration-status", (_req: Request, res: Response) => {
  const elapsed = migrationState.startedAt
    ? Math.round((Date.now() - migrationState.startedAt) / 1000)
    : null;
  res.status(200).json({ success: true, state: { ...migrationState, elapsedSeconds: elapsed } });
});

// ── GET /status/:id ───────────────────────────────────────────────────────────
router.get("/status/:id", async (req: Request, res: Response) => {
  try {
    const content = await ContentModel.findById(req.params.id)
      .select("processingStatus muxPlaybackId muxAssetId videoUrl")
      .lean();
    if (!content) {
      res.status(404).json({ success: false, message: "Not found" });
      return;
    }
    res.status(200).json({ success: true, data: content });
  } catch (err: any) {
    res.status(500).json({ success: false, message: err.message });
  }
});

export const MuxRoutes = router;
