/**
 * Mux Video Service
 *
 * Wraps the @mux/mux-node SDK. All Mux credentials stay server-side.
 * The Flutter client never sees MUX_TOKEN_ID or MUX_TOKEN_SECRET.
 *
 * Environment variables required:
 *   MUX_TOKEN_ID      – Mux API token ID
 *   MUX_TOKEN_SECRET  – Mux API token secret
 *   MUX_WEBHOOK_SECRET – Mux webhook signing secret
 */

import Mux from "@mux/mux-node";
import { ContentModel } from "../content/content.model";

// Lazy singleton — only constructed when credentials are present
let _mux: Mux | null = null;

function getMux(): Mux {
  if (_mux) return _mux;
  const tokenId     = process.env.MUX_TOKEN_ID;
  const tokenSecret = process.env.MUX_TOKEN_SECRET;
  if (!tokenId || !tokenSecret) {
    throw new Error(
      "MUX_TOKEN_ID and MUX_TOKEN_SECRET environment variables are required"
    );
  }
  _mux = new Mux({ tokenId, tokenSecret });
  return _mux;
}

export function isMuxConfigured(): boolean {
  return !!(process.env.MUX_TOKEN_ID && process.env.MUX_TOKEN_SECRET);
}

// ─────────────────────────────────────────────────────────────────────────────
// Direct Upload — backend creates a signed upload URL; client uploads directly
// to Mux (never through our server).
// ─────────────────────────────────────────────────────────────────────────────
export async function createDirectUpload(contentId: string): Promise<{
  uploadUrl: string;
  uploadId: string;
}> {
  const mux = getMux();
  const upload = await mux.video.uploads.create({
    cors_origin: "*",
    new_asset_settings: {
      playback_policy: ["public"],
      passthrough: contentId, // echoed back in webhooks for easy lookup
    },
  });

  // Store the upload ID on the content document
  await ContentModel.findByIdAndUpdate(contentId, {
    muxUploadId:      upload.id,
    processingStatus: "uploading",
  });

  return { uploadUrl: upload.url ?? "", uploadId: upload.id };
}

// ─────────────────────────────────────────────────────────────────────────────
// Webhook handler — called from mux.routes.ts after signature verification
// ─────────────────────────────────────────────────────────────────────────────
export async function handleMuxWebhook(event: any): Promise<void> {
  const type = event.type as string;
  const data = event.data;

  // The contentId we stored in new_asset_settings.passthrough
  const contentId: string | undefined =
    data?.passthrough || data?.new_asset_settings?.passthrough;

  switch (type) {
    // Asset is ready → store playback ID, mark ready
    case "video.asset.ready": {
      const playbackId = data?.playback_ids?.[0]?.id;
      if (contentId && playbackId) {
        await ContentModel.findByIdAndUpdate(contentId, {
          muxAssetId:       data.id,
          muxPlaybackId:    playbackId,
          processingStatus: "ready",
          // Update thumbnailUrl to Mux's auto-generated thumbnail
          thumbnailUrl: `https://image.mux.com/${playbackId}/thumbnail.jpg`,
          // Duration comes back in seconds as a float
          ...(data.duration ? { durationSeconds: Math.round(data.duration) } : {}),
        });
        console.log(`[Mux] Asset ready: contentId=${contentId} playbackId=${playbackId}`);
      }
      break;
    }

    // Processing failed
    case "video.asset.errored": {
      if (contentId) {
        await ContentModel.findByIdAndUpdate(contentId, {
          processingStatus: "failed",
        });
        console.error(`[Mux] Asset errored: contentId=${contentId}`, data?.errors);
      }
      break;
    }

    // Upload completed (asset creation starts next)
    case "video.upload.asset_created": {
      if (contentId) {
        await ContentModel.findByIdAndUpdate(contentId, {
          muxAssetId:       data?.asset_id,
          processingStatus: "processing",
        });
      }
      break;
    }

    // Asset deleted externally
    case "video.asset.deleted": {
      if (contentId) {
        await ContentModel.findByIdAndUpdate(contentId, {
          muxAssetId:       null,
          muxPlaybackId:    null,
          processingStatus: "failed",
        });
      }
      break;
    }

    default:
      // Unhandled event types — safe to ignore
      break;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// In-process background migration — runs inside the Express process so there
// is no shell timeout.  Triggered via POST /api/v1/mux/run-migration.
// ─────────────────────────────────────────────────────────────────────────────
export const migrationState = {
  running: false,
  total: 0,
  done: 0,
  submitted: 0,
  failed: 0,
  startedAt: null as number | null,
  completedAt: null as number | null,
  failedIds: [] as string[],
};

const CONCURRENCY = 20;

export async function runMigrationBackground(): Promise<void> {
  if (migrationState.running) return;

  const mux = getMux();
  const { ContentModel } = await import("../content/content.model");
  const BACKEND_BASE = process.env.BACKEND_URL || "https://p2pfitechai.com";

  migrationState.running    = true;
  migrationState.done       = 0;
  migrationState.submitted  = 0;
  migrationState.failed     = 0;
  migrationState.failedIds  = [];
  migrationState.startedAt  = Date.now();
  migrationState.completedAt = null;

  const total = await ContentModel.countDocuments({
    isActive: true,
    videoUrl: { $exists: true, $nin: [null, ""] },
    muxAssetId: { $exists: false },
  });
  migrationState.total = total;
  console.log(`[MuxMigrate] Starting background migration of ${total} videos`);

  // Sliding-window semaphore
  let slots = CONCURRENCY;
  const waiting: Array<() => void> = [];
  const acquire = () => {
    if (slots > 0) { slots--; return Promise.resolve(); }
    return new Promise<void>(r => waiting.push(r));
  };
  const release = () => { if (waiting.length) waiting.shift()!(); else slots++; };

  const cursor = ContentModel.find({
    isActive: true,
    videoUrl: { $exists: true, $nin: [null, ""] },
    muxAssetId: { $exists: false },
  }).select("_id videoUrl").lean().cursor();

  const promises: Promise<void>[] = [];

  for await (const doc of cursor) {
    const id = (doc._id as any).toString();
    const videoUrl = (doc as any).videoUrl as string;

    promises.push(
      (async () => {
        await acquire();
        try {
          const absoluteUrl = videoUrl.startsWith("http")
            ? videoUrl
            : `${BACKEND_BASE}${videoUrl}`;
          const asset = await mux.video.assets.create({
            inputs: [{ url: absoluteUrl }],
            playback_policy: ["public"],
            passthrough: id,
          });
          await ContentModel.updateOne(
            { _id: doc._id },
            { $set: { muxAssetId: asset.id, processingStatus: "processing" } }
          );
          migrationState.submitted++;
        } catch {
          migrationState.failed++;
          migrationState.failedIds.push(id);
        } finally {
          migrationState.done++;
          release();
          if (migrationState.done % 100 === 0 || migrationState.done === total) {
            const pct = ((migrationState.done / total) * 100).toFixed(1);
            console.log(`[MuxMigrate] ${migrationState.done}/${total} (${pct}%) — ✅ ${migrationState.submitted} submitted ❌ ${migrationState.failed} failed`);
          }
        }
      })()
    );
  }

  await Promise.all(promises);
  migrationState.running     = false;
  migrationState.completedAt = Date.now();
  const elapsed = ((migrationState.completedAt - migrationState.startedAt!) / 1000).toFixed(0);
  console.log(`[MuxMigrate] Done in ${elapsed}s — submitted: ${migrationState.submitted}, failed: ${migrationState.failed}`);
}

// ─────────────────────────────────────────────────────────────────────────────
// Migration worker — migrates legacy GCS videos to Mux one at a time.
// Call via a management script or admin endpoint. Idempotent — skips any
// content that already has a muxAssetId.
// ─────────────────────────────────────────────────────────────────────────────
export async function migrateLegacyVideoToMux(contentId: string): Promise<void> {
  const mux = getMux();

  const content = await ContentModel.findById(contentId).lean();
  if (!content) throw new Error(`Content ${contentId} not found`);
  if ((content as any).muxAssetId) {
    console.log(`[MuxMigrate] ${contentId} already migrated — skipping`);
    return;
  }

  const videoUrl = (content as any).videoUrl;
  if (!videoUrl) throw new Error(`Content ${contentId} has no videoUrl to migrate`);

  // Build absolute URL (legacy URLs may be relative backend paths)
  const backendBase = process.env.BACKEND_URL || "https://p2pfitechai.com";
  const absoluteUrl = videoUrl.startsWith("http")
    ? videoUrl
    : `${backendBase}${videoUrl}`;

  // Create Mux asset from source URL
  const asset = await mux.video.assets.create({
    inputs: [{ url: absoluteUrl }],
    playback_policy: ["public"],
    passthrough: contentId,
  });

  await ContentModel.findByIdAndUpdate(contentId, {
    muxAssetId:       asset.id,
    processingStatus: "processing",
  });

  console.log(`[MuxMigrate] Started: contentId=${contentId} assetId=${asset.id}`);
}
