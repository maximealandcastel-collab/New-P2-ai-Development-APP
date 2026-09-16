import { WebPayment } from "../enterprise/enterprise.model";
import { Types } from "mongoose";
import { randomInt } from "crypto";
import { PromoCodeModel, PromoRedemptionModel } from "./promoCode.model";
import { TPromoType } from "./promoCode.interface";
import { TrainerModel } from "../trainer/trainer.model";
import { UserModel } from "../user/user.model";
import { SubscriptionModel } from "../subscription/subscription.model";
import { autoGenerateWorkoutPlan } from "../workoutPlan/workoutPlan.generator";

// ─────────────────────────────────────────────────────────────
// PLAN DEFAULTS BY TYPE
// Used when importing codes (each code stores its own snapshot,
// so these can be overridden per batch).
// ─────────────────────────────────────────────────────────────

export const PROMO_PLAN_DEFAULTS: Record<
  TPromoType,
  { priceCents: number; durationDays: number; label: string }
> = {
  website: {
    priceCents: 1999, // $19.99
    durationDays: 90, // 3 months
    label: "Website 3-Month Plan",
  },
  affiliate: {
    priceCents: 999, // $9.99
    durationDays: 30, // 1 month
    label: "Affiliate Monthly Plan",
  },
};

// ─────────────────────────────────────────────────────────────
// HELPER — RESOLVE DEFAULT APP TRAINER
// Promo subscriptions grant access to the single "default" trainer.
// Looks for Trainer.isDefault === true, falls back to env id.
// ─────────────────────────────────────────────────────────────

export const getDefaultTrainer = async () => {
  let trainer = await TrainerModel.findOne({ isDefault: true });

  if (!trainer && process.env.DEFAULT_TRAINER_ID) {
    trainer = await TrainerModel.findById(process.env.DEFAULT_TRAINER_ID);
  }

  if (!trainer) {
    throw new Error(
      "No default trainer configured. Set one via POST /promo/default-trainer or DEFAULT_TRAINER_ID env.",
    );
  }
  return trainer;
};

// ─────────────────────────────────────────────────────────────
// HELPER — INIT TRAINER MEMORY FOR USER
// Mirrors payment.service so promo users get the same AI memory seed.
// ─────────────────────────────────────────────────────────────

const initTrainerMemory = async (userId: string, trainerId: string) => {
  const user = await UserModel.findById(userId);
  if (!user) return;

  const memoryExists = user.memory?.find(
    (m: any) => m.trainerId.toString() === trainerId,
  );
  if (memoryExists) return;

  const profileMemory = {
    goal: user.primaryGoal,
    experienceLevel: user.fitnessLevel,
    scheduleDaysPerWeek: user.trainingDaysPerWeek,
    equipment: user.availableEquipment,
    limitations: user.injuries?.join(", ") || "none",
    preferences: "",
    motivationStyle: "balanced",
    updatedAt: new Date(),
  };

  await UserModel.findByIdAndUpdate(userId, {
    $push: {
      memory: {
        trainerId,
        profileMemory,
        rollingMemory: {
          last3Sessions: [],
          lastKnownLoads: {},
          adherenceNotes: "",
          recoveryNotes: "",
          flags: [],
          updatedAt: new Date(),
        },
        lastUpdatedAt: new Date(),
      },
    },
  });
};

// ─────────────────────────────────────────────────────────────
// OWNER BYPASS CODE
// Optional emergency/admin access. It is disabled unless explicitly
// configured as a deployment secret; never use a hard-coded fallback.
// ─────────────────────────────────────────────────────────────

const OWNER_BYPASS_CODE = process.env.OWNER_BYPASS_CODE?.trim().toUpperCase() || null;

const OWNER_BYPASS_PLAN = {
  valid: true,
  isOwnerBypass: true,
  type: "website" as const,
  priceCents: 0,
  durationDays: 365,
  label: "Owner Full Access — 1 Year",
  revenueCatProductId: null,
};

// ─────────────────────────────────────────────────────────────
// VALIDATE PROMO CODE
// Called when the user enters a code at checkout (before purchase).
// Returns the plan the code unlocks so the app can show the right
// RevenueCat product / price. Does NOT consume the code.
// Only database-issued codes can unlock access.
// ─────────────────────────────────────────────────────────────

export const validatePromoCode = async (rawCode: string) => {
  const code = (rawCode || "").trim().toUpperCase();
  if (!code) throw new Error("Promo code is required");

  // Owner bypass — always valid, no DB lookup needed
  if (OWNER_BYPASS_CODE && code === OWNER_BYPASS_CODE) {
    return { ...OWNER_BYPASS_PLAN, code };
  }

  const promo = await PromoCodeModel.findOne({ code });

  if (!promo) throw new Error("Invalid promo code");

  if (promo.status === "disabled") {
    throw new Error("This promo code has been disabled");
  }
  if (promo.usedCount >= promo.maxUses || promo.status === "redeemed") {
    throw new Error("This promo code has already been used");
  }

  return {
    valid: true,
    isUniversal: false,
    code: promo.code,
    type: promo.type,
    priceCents: promo.priceCents,
    durationDays: promo.durationDays,
    label: promo.label,
    revenueCatProductId: promo.revenueCatProductId,
  };
};

// ─────────────────────────────────────────────────────────────
// REDEEM PROMO CODE
// Called AFTER the RevenueCat purchase completes on the frontend.
// Consumes the code + grants default-trainer access for the plan
// duration. Logs the redemption for affiliate reporting.
// ─────────────────────────────────────────────────────────────

export const redeemPromoCode = async (
  userId: string,
  rawCode: string,
  opts: {
    revenueCatTransactionId?: string;
    revenueCatProductId?: string;
  } = {},
) => {
  const code = (rawCode || "").trim().toUpperCase();
  if (!code) throw new Error("Promo code is required");

  const webPromo = await PromoCodeModel.findOne({ code, sourcePurchaseId: { $exists: true } });
  if (webPromo) return redeemVerifiedWebPayment(userId, code);

  // ── 0. Owner bypass — skip everything, grant/extend 365-day access ─
  if (OWNER_BYPASS_CODE && code === OWNER_BYPASS_CODE) {
    const actor = await UserModel.findOne({ _id: userId, role: "admin", isVerified: true, isDeleted: { $ne: true } });
    if (!actor) throw new Error("Founder access required");
    const startDate = new Date();
    const endDate = new Date();
    endDate.setDate(endDate.getDate() + 365);

    // Resolve trainer (fall back to first trainer if none marked default)
    let trainer;
    try {
      trainer = await getDefaultTrainer();
    } catch {
      trainer = await TrainerModel.findOne({ isBuiltIn: true }).lean() ||
                await TrainerModel.findOne().lean();
      if (!trainer) throw new Error("No trainer found to grant access");
    }

    // Upsert: extend an existing sub or create a new one
    const existingSub = await SubscriptionModel.findOne({ userId, status: "active" });
    const subscription = existingSub
      ? await SubscriptionModel.findByIdAndUpdate(
          existingSub._id,
          { $set: { endDate, startDate, source: "owner_bypass" } },
          { new: true },
        )
      : await SubscriptionModel.create({
          userId,
          trainerId: trainer._id,
          status: "active",
          startDate,
          endDate,
          source: "owner_bypass",
        });

    await UserModel.findByIdAndUpdate(userId, {
      $set: {
        subscribedTrainer: trainer._id,
        subscriptionTier: "paid",
        subscriptionStartDate: startDate,
        subscriptionEndDate: endDate,
      },
    });

    await initTrainerMemory(userId, String(trainer._id));

    return {
      subscription,
      plan: OWNER_BYPASS_PLAN,
      access: { granted: true, startDate, endDate, trainerId: trainer._id },
    };
  }

  // ── 1. Try to claim a DB-stored code atomically ───────────────
  const promo = await PromoCodeModel.findOneAndUpdate(
    {
      code,
      status: "active",
      $expr: { $lt: ["$usedCount", "$maxUses"] },
    },
    { $inc: { usedCount: 1 } },
    { new: true },
  );

  // ── 2. Reject codes that are missing, disabled, or already used ──
  if (!promo) {
    const existing = await PromoCodeModel.findOne({ code }).lean();
    if (!existing) throw new Error("Invalid promo code");
    if (existing.status === "disabled") {
      throw new Error("This promo code has been disabled");
    }
    throw new Error("This promo code has already been used");
  }

  const planDays = promo.durationDays;
  const planPriceCents = promo.priceCents;
  const planLabel = promo.label;
  const planType = promo.type;

  // ── 3. Block stacking on an already-active subscription ────────
  const activeSub = await SubscriptionModel.findOne({
    userId,
    status: "active",
  });
  if (activeSub) {
    await PromoCodeModel.updateOne(
      { _id: promo._id },
      { $inc: { usedCount: -1 } },
    );
    throw new Error("You already have an active subscription");
  }

  // ── 4. Resolve the default app trainer ─────────────────────────
  let trainer;
  try {
    trainer = await getDefaultTrainer();
  } catch (err) {
    await PromoCodeModel.updateOne(
      { _id: promo._id },
      { $inc: { usedCount: -1 } },
    );
    throw err;
  }

  // ── 5. Grant access — subscription on the default trainer ──────
  const startDate = new Date();
  const endDate = new Date();
  endDate.setDate(endDate.getDate() + planDays);

  const subscription = await SubscriptionModel.create({
    userId,
    trainerId: trainer._id,
    status: "active",
    startDate,
    endDate,
    source: "promo",
    promoCodeId: promo._id,
    reminderSent7Days: false,
    reminderSent3Days: false,
    reminderSent1Day: false,
  });

  // Auto-generate 7-day workout split for the new subscriber (fire-and-forget)
  autoGenerateWorkoutPlan(
    String(trainer._id),
    String(userId),
  );

  // ── 6. Update user access fields ───────────────────────────────
  await UserModel.findByIdAndUpdate(userId, {
    $set: {
      subscribedTrainer: trainer._id,
      subscriptionTier: "paid",
      subscriptionStartDate: startDate,
      subscriptionEndDate: endDate,
    },
  });

  // ── 7. Seed AI memory for the default trainer ──────────────────
  await initTrainerMemory(userId, (trainer._id as Types.ObjectId).toString());

  // ── 8. Stamp the database code redeemed ─────────────────────────
  const fullyUsed = promo.usedCount >= promo.maxUses;
  await PromoCodeModel.updateOne(
    { _id: promo._id },
    {
      $set: {
        redeemedByUserId: userId,
        redeemedAt: new Date(),
        ...(fullyUsed ? { status: "redeemed" } : {}),
      },
    },
  );

  // ── 9. Log redemption for affiliate reporting ───────────────────
  await PromoRedemptionModel.create({
    promoCodeId: promo._id,
    code: promo.code,
    type: promo.type,
    userId,
    subscriptionId: subscription._id,
    priceCents: promo.priceCents,
    durationDays: promo.durationDays,
    revenueCatTransactionId: opts.revenueCatTransactionId,
    revenueCatProductId: opts.revenueCatProductId,
  });

  return {
    subscription,
    plan: {
      type: planType,
      priceCents: planPriceCents,
      durationDays: planDays,
      label: planLabel,
      isUniversal: false,
    },
    access: {
      granted: true,
      startDate,
      endDate,
      trainerId: trainer._id,
      trainerName: (trainer as any).name,
    },
  };
};

// ─────────────────────────────────────────────────────────────
// BULK IMPORT CODES (admin)
// Insert a batch of pre-generated codes for one type.
// ordered:false → duplicates are skipped, the rest still insert.
// NOTE: express.json() limit is 100kb — import in batches
// (~5,000 codes per request) or raise the body limit.
// ─────────────────────────────────────────────────────────────

export const bulkImportCodes = async (
  type: TPromoType,
  codes: string[],
  overrides: {
    priceCents?: number;
    durationDays?: number;
    label?: string;
    revenueCatProductId?: string;
    maxUses?: number;
    batchId?: string;
  } = {},
) => {
  if (!["website", "affiliate"].includes(type)) {
    throw new Error("type must be 'website' or 'affiliate'");
  }
  if (!Array.isArray(codes) || codes.length === 0) {
    throw new Error("codes must be a non-empty array");
  }

  const defaults = PROMO_PLAN_DEFAULTS[type];

  // Normalize + dedupe within the batch
  const seen = new Set<string>();
  const docs = [];
  for (const raw of codes) {
    const code = String(raw || "").trim().toUpperCase();
    if (!code || seen.has(code)) continue;
    seen.add(code);
    docs.push({
      code,
      type,
      priceCents: overrides.priceCents ?? defaults.priceCents,
      durationDays: overrides.durationDays ?? defaults.durationDays,
      label: overrides.label ?? defaults.label,
      revenueCatProductId: overrides.revenueCatProductId,
      maxUses: overrides.maxUses ?? 1,
      usedCount: 0,
      status: "active",
      batchId: overrides.batchId,
    });
  }

  let inserted = 0;
  try {
    const result = await PromoCodeModel.insertMany(docs, { ordered: false });
    inserted = result.length;
  } catch (err: any) {
    // ordered:false → some inserted before duplicates errored
    inserted = err?.result?.insertedCount ?? err?.insertedDocs?.length ?? 0;
  }

  return {
    requested: codes.length,
    deduplicatedInBatch: docs.length,
    inserted,
    skippedDuplicates: docs.length - inserted,
  };
};

// ─────────────────────────────────────────────────────────────
// LIST CODES (admin) — filter + paginate
// ─────────────────────────────────────────────────────────────

export const listPromoCodes = async (filters: {
  type?: string;
  status?: string;
  batchId?: string;
  page?: number;
  limit?: number;
}) => {
  const query: any = {};
  if (filters.type) query.type = filters.type;
  if (filters.status) query.status = filters.status;
  if (filters.batchId) query.batchId = filters.batchId;

  const page = Math.max(1, filters.page || 1);
  const limit = Math.min(200, filters.limit || 50);
  const skip = (page - 1) * limit;

  const [items, total] = await Promise.all([
    PromoCodeModel.find(query).sort({ createdAt: -1 }).skip(skip).limit(limit).lean(),
    PromoCodeModel.countDocuments(query),
  ]);

  return { page, limit, total, totalPages: Math.ceil(total / limit), items };
};

// ─────────────────────────────────────────────────────────────
// PROMO STATS (admin) — affiliate reporting
// Redemptions grouped by type + code-status totals
// ─────────────────────────────────────────────────────────────

export const getPromoStats = async () => {
  const [byType, statusCounts, topCodes] = await Promise.all([
    PromoRedemptionModel.aggregate([
      {
        $group: {
          _id: "$type",
          redemptions: { $sum: 1 },
          revenueCents: { $sum: "$priceCents" },
        },
      },
    ]),
    PromoCodeModel.aggregate([
      { $group: { _id: "$status", count: { $sum: 1 } } },
    ]),
    PromoRedemptionModel.aggregate([
      { $group: { _id: "$code", redemptions: { $sum: 1 } } },
      { $sort: { redemptions: -1 } },
      { $limit: 20 },
    ]),
  ]);

  return { redemptionsByType: byType, codeStatusCounts: statusCounts, topCodes };
};

// ─────────────────────────────────────────────────────────────
// DISABLE / ENABLE CODE (admin)
// ─────────────────────────────────────────────────────────────

export const setPromoCodeDisabled = async (code: string, disabled: boolean) => {
  const normalized = (code || "").trim().toUpperCase();
  const promo = await PromoCodeModel.findOneAndUpdate(
    { code: normalized },
    { $set: { status: disabled ? "disabled" : "active" } },
    { new: true },
  );
  if (!promo) throw new Error("Promo code not found");
  return promo;
};

// ─────────────────────────────────────────────────────────────
// ISSUE TRIAL CODE (service)
// Generates a unique TRIAL- code for the 7-day $4.99 website plan.
// Called by the API server after a successful Clover payment.
// ─────────────────────────────────────────────────────────────

const TRIAL_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";

function genTrialCode(): string {
  const seg = (len: number) =>
    Array.from({ length: len }, () =>
      TRIAL_CHARS[randomInt(TRIAL_CHARS.length)]
    ).join("");
  return `TRIAL-${seg(6)}-${seg(4)}`;
}

export const issueTrialPromoCode = async (opts?: {
  durationDays?: number;
  priceCents?: number;
  label?: string;
}): Promise<string> => {
  const durationDays = opts?.durationDays ?? 7;
  const priceCents   = opts?.priceCents   ?? 499;
  const label        = opts?.label        ?? "7-Day App Trial";
  for (let attempt = 0; attempt < 20; attempt++) {
    const code = genTrialCode();
    const existing = await PromoCodeModel.findOne({ code });
    if (!existing) {
      await PromoCodeModel.create({
        code,
        type: "website" as TPromoType,
        priceCents,
        durationDays,
        label,
        maxUses: 1,
        status: "active",
        batchId: "WEBSITE_TRIAL",
      });
      return code;
    }
  }
  throw new Error("Could not generate a unique trial code. Please try again.");
};

// ─────────────────────────────────────────────────────────────
// ISSUE WEBSITE PURCHASE CODE (service)
// Creates the exact entitlement for a verified Clover purchase.
// sourcePurchaseId makes retries return the original code instead
// of issuing a second entitlement.
// ─────────────────────────────────────────────────────────────

export const WEB_PURCHASE_PLANS = {
  trial_access: { priceCents: 499, durationDays: 7, label: "7-Day App Trial", durationLabel: "7 days" },
  three_months: { priceCents: 1999, durationDays: 90, label: "3-Month App Access", durationLabel: "3 months" },
  annual: { priceCents: 12000, durationDays: 365, label: "Annual App Access", durationLabel: "1 year" },
  affiliate: { priceCents: 1000, durationDays: 180, label: "Affiliate App Access", durationLabel: "6 months" },
} as const;

export type WebPurchasePlan = keyof typeof WEB_PURCHASE_PLANS;

export const issueWebPurchasePromoCode = async (opts: {
  sourcePurchaseId: string;
  plan: WebPurchasePlan;
  amountCents: number;
}): Promise<{ code: string; durationDays: number; durationLabel: string; plan: WebPurchasePlan }> => {
  const sourcePurchaseId = String(opts.sourcePurchaseId || "").trim();
  if (!sourcePurchaseId) throw new Error("sourcePurchaseId is required");

  const plan = WEB_PURCHASE_PLANS[opts.plan];
  if (!plan) throw new Error("Unsupported website purchase plan");
  if (Number(opts.amountCents) !== plan.priceCents) {
    throw new Error("Purchase amount does not match the selected plan");
  }

  const existing = await PromoCodeModel.findOne({ sourcePurchaseId });
  if (existing) {
    return {
      code: existing.code,
      durationDays: existing.durationDays,
      durationLabel: plan.durationLabel,
      plan: opts.plan,
    };
  }

  for (let attempt = 0; attempt < 20; attempt++) {
    const code = genTrialCode();
    try {
      const created = await PromoCodeModel.create({
        code,
        type: "website" as TPromoType,
        priceCents: plan.priceCents,
        durationDays: plan.durationDays,
        label: plan.label,
        maxUses: 1,
        status: "active",
        batchId: "WEBSITE_PURCHASE",
        sourcePurchaseId,
      });
      return {
        code: created.code,
        durationDays: plan.durationDays,
        durationLabel: plan.durationLabel,
        plan: opts.plan,
      };
    } catch (err: any) {
      // A concurrent retry may win the unique purchase reference. Return
      // that code so the buyer sees one stable code either way.
      if (err?.code === 11000) {
        const concurrent = await PromoCodeModel.findOne({ sourcePurchaseId });
        if (concurrent) {
          return {
            code: concurrent.code,
            durationDays: concurrent.durationDays,
            durationLabel: plan.durationLabel,
            plan: opts.plan,
          };
        }
        continue;
      }
      throw err;
    }
  }
  throw new Error("Could not generate a unique website promo code. Please try again.");
};

// ─────────────────────────────────────────────────────────────
// SET DEFAULT TRAINER (admin)
// Marks one trainer as the default app trainer (unsets others).
// ─────────────────────────────────────────────────────────────

export const setDefaultTrainer = async (trainerId: string) => {
  const trainer = await TrainerModel.findById(trainerId);
  if (!trainer) throw new Error("Trainer not found");

  await TrainerModel.updateMany(
    { _id: { $ne: trainer._id } },
    { $set: { isDefault: false } },
  );
  trainer.isDefault = true;
  await trainer.save();

  return trainer;
};

// Web payments are bound to their verified purchaser and exact paid period.
async function redeemVerifiedWebPayment(userId: string, code: string) {
  const trainer = await getDefaultTrainer();
  const session = await PromoCodeModel.startSession();
  let result: any;
  try {
    await session.withTransaction(async () => {
      const promo = await PromoCodeModel.findOne({ code }).session(session);
      const user = await UserModel.findOne({ _id: userId, isVerified: true, isDeleted: { $ne: true } }).session(session);
      if (!promo || !user || promo.status === "disabled") throw new Error("Purchase access unavailable");
      const payment = await WebPayment.findOne({ sourcePurchaseId: promo.sourcePurchaseId,
        email: user.email.toLowerCase(), status: "paid", expiresAt: { $gt: new Date() } }).session(session);
      if (!payment) throw new Error("This purchase is expired, refunded, or belongs to another account");
      // Touch the payment document so concurrent refund and redemption conflict and retry.
      payment.markModified("status"); await payment.save({ session });
      const existing = await SubscriptionModel.findOne({ promoCodeId: promo._id }).session(session);
      if (existing) {
        if (String(existing.userId) !== userId || existing.status !== "active") throw new Error("Purchase already redeemed or revoked");
        result = { subscription: existing, access: { granted: true, startDate: existing.startDate, endDate: existing.endDate, trainerId: existing.trainerId } };
        return;
      }
      if (promo.usedCount >= promo.maxUses || promo.status !== "active") throw new Error("Purchase already redeemed");
      const startDate = new Date(), endDate = payment.expiresAt;
      const [subscription] = await SubscriptionModel.create([{ userId, trainerId: trainer._id, status: "active",
        startDate, endDate, source: "promo", promoCodeId: promo._id }], { session });
      promo.usedCount++; promo.status = "redeemed"; promo.redeemedByUserId = user._id; promo.redeemedAt = startDate;
      await promo.save({ session });
      // Never overwrite a longer, independent paid entitlement.
      if (!user.subscriptionEndDate || user.subscriptionEndDate < endDate) {
        user.subscriptionTier = "paid"; user.subscriptionStartDate = startDate; user.subscriptionEndDate = endDate;
        user.subscribedTrainer = trainer._id as any; await user.save({ session });
      }
      await PromoRedemptionModel.create([{ promoCodeId: promo._id, code, type: promo.type, userId,
        subscriptionId: subscription._id, priceCents: promo.priceCents, durationDays: promo.durationDays }], { session });
      result = { subscription, access: { granted: true, startDate, endDate, trainerId: trainer._id } };
    });
    return result;
  } finally { await session.endSession(); }
}
