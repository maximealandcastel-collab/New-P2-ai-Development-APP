import { spawn } from "child_process";
import fs from "fs";
import path from "path";
import { logger } from "../logger/logger";

/**
 * Remux an uploaded video so its moov atom (index) is at the front of the
 * file ("faststart"). Without this, iPhone .mov/.mp4 uploads force players
 * to download the ENTIRE file before playback can begin — the main cause of
 * slow video loading.
 *
 * - Runs in the background (fire-and-forget) so uploads stay fast.
 * - Remux only (`-c copy`), no re-encode — takes seconds, not minutes.
 * - Fail-safe: if ffmpeg is missing or errors, the original file is kept.
 */
export const faststartInBackground = (filePath: string): void => {
  const ext = path.extname(filePath).toLowerCase();
  // Only container formats where faststart applies
  if (![".mp4", ".mov", ".m4v"].includes(ext)) return;

  const tmpPath = `${filePath}.faststart.mp4`;

  const ffmpeg = spawn(
    "ffmpeg",
    [
      "-y",
      "-i",
      filePath,
      "-c",
      "copy",
      "-movflags",
      "+faststart",
      tmpPath,
    ],
    { stdio: "ignore" },
  );

  ffmpeg.on("error", () => {
    // ffmpeg not installed — keep the original file untouched
    fs.promises.unlink(tmpPath).catch(() => undefined);
  });

  ffmpeg.on("close", async (code) => {
    try {
      if (code === 0) {
        const [orig, remuxed] = await Promise.all([
          fs.promises.stat(filePath),
          fs.promises.stat(tmpPath),
        ]);
        // Sanity check: remuxed file must be roughly the same size
        if (remuxed.size > 0 && remuxed.size >= orig.size * 0.5) {
          await fs.promises.rename(tmpPath, filePath);
          logger?.info?.(`faststart applied: ${path.basename(filePath)}`);
          return;
        }
      }
      await fs.promises.unlink(tmpPath).catch(() => undefined);
    } catch {
      await fs.promises.unlink(tmpPath).catch(() => undefined);
    }
  });
};
