import mongoose, { Schema } from 'mongoose';
import { randomUUID } from 'crypto';
import Mux from '@mux/mux-node';

const schema = new Schema({
  userId: { type: Schema.Types.ObjectId, required: true },
  contentId: { type: String, required: true },
  kind: { type: String, enum: ['mux_asset', 'mux_upload'], required: true },
  providerId: { type: String, required: true },
  state: { type: String, enum: ['pending', 'complete'], default: 'pending' },
  attempts: { type: Number, default: 0 },
  nextAttemptAt: { type: Date, default: Date.now },
  leaseUntil: { type: Date, default: () => new Date(0) },
  leaseToken: String,
  lastError: String,
  completedAt: Date,
}, { timestamps: true });
schema.index({ kind: 1, providerId: 1 }, { unique: true });
schema.index({ state: 1, nextAttemptAt: 1, leaseUntil: 1 });
export const MediaCleanup = mongoose.models.MediaCleanup || mongoose.model('MediaCleanup', schema);

type Provider = {
  video: {
    assets: { retrieve(id: string): Promise<{ passthrough?: string }>; delete(id: string): Promise<unknown> };
    uploads: {
      retrieve(id: string): Promise<{ status: string; asset_id?: string; new_asset_settings?: { passthrough?: string } }>;
      cancel(id: string): Promise<unknown>;
    };
  };
};

async function missingIsSuccess<T>(operation: () => Promise<T>): Promise<T | undefined> {
  try { return await operation(); }
  catch (error: any) { if (error?.status === 404) return undefined; throw error; }
}

/** Only server-recorded IDs are accepted, with ownership rechecked at Mux.
 * Never fetch or delete arbitrary URLs supplied in profile fields.
 */
export async function removeMuxMedia(job: { kind: string; providerId: string; contentId: string }, provider: Provider) {
  const deleteAsset = async (id: string) => {
    const asset = await missingIsSuccess(() => provider.video.assets.retrieve(id));
    if (!asset) return;
    if (asset.passthrough !== job.contentId) throw new Error('ownership_mismatch');
    await missingIsSuccess(() => provider.video.assets.delete(id));
  };
  if (job.kind === 'mux_asset') return deleteAsset(job.providerId);
  if (job.kind !== 'mux_upload') throw new Error('unsupported_provider');
  const upload = await missingIsSuccess(() => provider.video.uploads.retrieve(job.providerId));
  if (!upload) return;
  if (upload.new_asset_settings?.passthrough !== job.contentId) throw new Error('ownership_mismatch');
  if (upload.asset_id) return deleteAsset(upload.asset_id);
  if (['cancelled', 'timed_out', 'errored'].includes(upload.status)) return;
  if (upload.status === 'waiting') {
    // A cancellation race is retried: the next read discovers the created asset.
    await provider.video.uploads.cancel(job.providerId);
    return;
  }
  throw new Error('upload_not_terminal');
}

export async function runMediaCleanupBatch(provider: Provider, limit = 20) {
  for (let i = 0; i < limit; i++) {
    const now = new Date();
    const leaseToken = randomUUID();
    const job: any = await MediaCleanup.findOneAndUpdate({
      state: 'pending', nextAttemptAt: { $lte: now }, leaseUntil: { $lte: now },
    }, { $set: { leaseToken, leaseUntil: new Date(now.getTime() + 120000) }, $inc: { attempts: 1 } },
    { new: true, sort: { nextAttemptAt: 1 } }).lean();
    if (!job) return;
    try {
      await removeMuxMedia(job, provider);
      await MediaCleanup.updateOne({ _id: job._id, leaseToken }, {
        $set: { state: 'complete', completedAt: new Date(), leaseUntil: new Date(0) },
        $unset: { leaseToken: 1, lastError: 1 },
      });
    } catch (error: any) {
      // Store categories only: provider errors may contain URLs or credentials.
      const lastError = error?.message === 'ownership_mismatch' ? 'ownership_mismatch' : 'provider_retry_required';
      const delay = Math.min(86400000, 60000 * 2 ** Math.min(job.attempts - 1, 10));
      await MediaCleanup.updateOne({ _id: job._id, leaseToken }, {
        $set: { lastError, nextAttemptAt: new Date(Date.now() + delay), leaseUntil: new Date(0) },
        $unset: { leaseToken: 1 },
      });
    }
  }
}

let timer: ReturnType<typeof setInterval> | undefined;
export function startMediaCleanupWorker() {
  if (timer || !process.env.MUX_TOKEN_ID || !process.env.MUX_TOKEN_SECRET) return;
  const provider = new Mux({ tokenId: process.env.MUX_TOKEN_ID, tokenSecret: process.env.MUX_TOKEN_SECRET,
    timeout: 15000, maxRetries: 0 });
  let running = false;
  const tick = async () => {
    if (running) return;
    running = true;
    try { await runMediaCleanupBatch(provider); }
    catch { console.error('[Privacy] Media cleanup database operation failed; retry scheduled'); }
    finally { running = false; }
  };
  timer = setInterval(() => { void tick(); }, 60000);
  timer.unref();
  void tick();
}
