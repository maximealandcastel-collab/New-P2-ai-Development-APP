import { createServer, Server as HttpServer } from "http";
import { initSocketIO } from "./utils/socket";
import mongoose from "mongoose";
import app from "./app"; // Express app
import { DATABASE_URL, PORT } from "./config";
import seedSuperAdmin, {
  seedAbout,
  seedAffiliates,
  seedCommitionRate,
  seedPrivacy,
  seedTerms,
} from "./DB"; // Seeding function
import { seedBuiltInTrainers } from "./DB/seedBuiltInTrainers";
import { OTPModel } from "./modules/user/user.model";
import { markReady } from "./config/readiness";
import { startCronJobs } from "./utils/corn";
import { startMuxStatusPoller } from "./modules/mux/mux.service";
import { applyFeedContentPolicy } from "./modules/content/contentEligibility";

import { startMediaCleanupWorker, MediaCleanup } from "./modules/privacy/mediaCleanup.service";

let server: HttpServer;
import dns from "dns";
// Cloudflare DNS
dns.setServers(["1.1.1.1", "1.0.0.1"]);

async function connectAndSeed() {
  const dbStartTime = Date.now();
  const loadingFrames = ["🌍", "🌎", "🌏"];
  let frameIndex = 0;

  const loader = setInterval(() => {
    process.stdout.write(
      `\rMongoDB connecting ${loadingFrames[frameIndex]} Please wait 😢`,
    );
    frameIndex = (frameIndex + 1) % loadingFrames.length;
  }, 300);

  try {
    await mongoose.connect(DATABASE_URL as string, {
      connectTimeoutMS: 30000,
      serverSelectionTimeoutMS: 10000, // fail fast, don't hang 30s per query
      socketTimeoutMS: 45000,
      maxPoolSize: 5,                  // stay under Atlas M0 connection limit
      heartbeatFrequencyMS: 10000,     // detect dropped connections quickly
    });
    // Reconcile the legacy expiresAt TTL index (previously 60 seconds) with
    // the schema's expire-at-date semantics. syncIndexes is idempotent.
    await OTPModel.syncIndexes();
    await MediaCleanup.init();
    clearInterval(loader);
    console.log(
      `\r✅ Mongodb connected successfully in ${Date.now() - dbStartTime}ms`,
    );

    // Seed in parallel. Readiness is not published until this succeeds.
    await Promise.all([
      seedSuperAdmin(),
      seedPrivacy(),
      seedTerms(),
      seedAbout(),
      seedCommitionRate(),
      seedBuiltInTrainers(),
      seedAffiliates(),
      applyFeedContentPolicy(),
    ]);
    // initSocketIO dynamically imports socket.io, so await its Promise before
    // publishing readiness.
    await initSocketIO(server);
    startCronJobs();
    // Webhooks are the primary update path; the idempotent poller repairs
    // missed webhooks after every normal process startup.
    startMuxStatusPoller();
    startMediaCleanupWorker();
    markReady();
    console.log("✅ Startup database reconciliation and initialization complete");
  } catch (error) {
    clearInterval(loader);
    console.error("Fatal database startup failure; terminating");
    server?.close(() => process.exit(1));
    setTimeout(() => process.exit(1), 1000).unref();
    throw error;
  }
}

async function main() {
  try {
    // Start HTTP server immediately so the port opens and health checks pass
    server = createServer(app);
    const serverStartTime = Date.now();
    server.listen(PORT, () => {
      console.log(
        `🚀 Server is running on port ${PORT} and took ${Date.now() - serverStartTime}ms to start`,
      );
    });

    await connectAndSeed();
  } catch (error) {
    console.error("Error in main function:", error);
    process.exit(1);
  }
}

main().catch((error) => {
  console.error("☠️ Unhandled error in main:", error);
  process.exit(1);
});

process.on("unhandledRejection", (err) => {
  console.error("☠️ Unhandled promise rejection; terminating process");
  process.exit(1);
});

process.on("uncaughtException", (error) => {
  console.error("☠️ Uncaught exception; terminating process");
  process.exit(1);
});
