import jwt from "jsonwebtoken";
import { createHash } from "node:crypto";
import axios from "axios";
import { Types } from "mongoose";
import { IAPSubscriptionModel } from "./iap.model";
import { UserModel } from "../user/user.model";
import { resolveStoreProduct, googleSubscriptionDates } from "./store-policy";
import ApiError from "../../errors/ApiError";
import httpStatus from "http-status";
import { verifyAppleTransaction } from "./apple-verifier.service";

// ─────────────────────────────────────────────────────────────
// GOOGLE OAUTH HELPER
// Generates access token using Google Service Account private key
// ─────────────────────────────────────────────────────────────
async function getGoogleAccessToken(): Promise<string> {
  const saJsonStr = process.env.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON;
  if (!saJsonStr) {
    throw new Error("GOOGLE_PLAY_SERVICE_ACCOUNT_JSON env var is missing");
  }

  let sa: any;
  try {
    sa = JSON.parse(saJsonStr);
  } catch (err) {
    // If it's a file path, we can try to read it (optional, usually stringified JSON in env is preferred)
    throw new Error("GOOGLE_PLAY_SERVICE_ACCOUNT_JSON is not a valid JSON string");
  }

  const tokenUri = sa.token_uri || "https://oauth2.googleapis.com/token";
  const now = Math.floor(Date.now() / 1000);

  // Sign JWT claim
  const payload = {
    iss: sa.client_email,
    scope: "https://www.googleapis.com/auth/androidpublisher",
    aud: tokenUri,
    exp: now + 3600,
    iat: now,
  };

  const token = jwt.sign(payload, sa.private_key, { algorithm: "RS256" });

  const res = await axios.post(
    tokenUri,
    new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: token,
    }).toString(),
    {
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      timeout: 10000,
    }
  );

  return res.data.access_token;
}

// ─────────────────────────────────────────────────────────────
// IAP VERIFICATION SERVICE
// ─────────────────────────────────────────────────────────────
export const verifyIAPSubscription = async (
  userId: string,
  platform: "ios" | "android",
  productId: "month_1" | "year_1" | string,
  purchaseId: string,
  verificationData: string
) => {
  const product = resolveStoreProduct(productId);
  if (!product) throw new ApiError(httpStatus.BAD_REQUEST, "Unknown productId");
  if (![userId, productId, purchaseId, verificationData].every(v => typeof v === "string" && v.length > 0)) {
    throw new ApiError(httpStatus.BAD_REQUEST, "Invalid purchase fields");
  }
  const subscriptionTier = product.tier;
  // Always reverify with the store, including restores. Cached active status can
  // outlive a refund or expiry and must never bypass store verification.
  const existingSubscription = await IAPSubscriptionModel.findOne({ purchaseId });
  if (existingSubscription && existingSubscription.userId.toString() !== userId) {
    throw new ApiError(httpStatus.CONFLICT, "This purchase is linked to another account");
  }

  let startDate = new Date();
  let endDate = new Date();
  let originalTransactionId = undefined;

  // 3. STORE VERIFICATION
  if (platform === "ios") {
    let verifiedTransaction;
    try {
      verifiedTransaction = await verifyAppleTransaction(
        verificationData,
        purchaseId,
        productId,
      );
    } catch (err: any) {
      // Never activate from a client-provided or malformed JWS. The details
      // stay in server logs; clients only need a non-successful verification.
      console.error("[iap] Apple transaction verification failed", {
        purchaseId,
        error: err?.message || "unknown error",
      });
      throw new ApiError(httpStatus.PAYMENT_REQUIRED, "Apple purchase could not be verified");
    }

    startDate = verifiedTransaction.purchaseDate;
    endDate = verifiedTransaction.expiresDate;
    originalTransactionId = verifiedTransaction.originalTransactionId;

    if (endDate.getTime() <= Date.now()) {
      throw new ApiError(httpStatus.PAYMENT_REQUIRED, "Purchase invalid or expired");
    }

  } else if (platform === "android") {
    // Verify with Google Play Developer API
    if (process.env.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON) {
      try {
        const accessToken = await getGoogleAccessToken();
        const url = `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/com.p2pfittech.ai/purchases/subscriptionsv2/tokens/${verificationData}`;

        const res = await axios.get(url, {
          headers: { Authorization: `Bearer ${accessToken}` },
          timeout: 10000,
        });

        const data = res.data;

        const dates = googleSubscriptionDates(data, productId, Date.now(), process.env.NODE_ENV === "production");
        startDate = dates.startDate;
        endDate = dates.endDate;
        originalTransactionId = `google:${createHash("sha256").update(verificationData).digest("hex")}`;
      } catch (err: any) {
        console.error("Google Play Verification error:", err.message);
        throw new ApiError(
          httpStatus.INTERNAL_SERVER_ERROR,
          "Google Play store API error: " + err.message
        );
      }
    } else {
      // Do not grant from a development/test fallback. A Google purchase is
      // valid only after the Android Publisher API has verified its token.
      throw new ApiError(httpStatus.PAYMENT_REQUIRED, "purchase could not be verified");
    }
  } else {
    throw new ApiError(httpStatus.BAD_REQUEST, "Invalid platform");
  }

  const identity = originalTransactionId ? { originalTransactionId } : { purchaseId };
  const session = await IAPSubscriptionModel.startSession();
  let result: any;
  try {
    await session.withTransaction(async () => {
      const existing = await IAPSubscriptionModel.findOne(identity).session(session);
      if (existing && existing.userId.toString() !== userId) {
        throw new ApiError(httpStatus.CONFLICT, "This purchase is linked to another account");
      }
      // A restore of an older renewal must not shorten a later verified period.
      const keepLater = existing && existing.endDate > endDate && existing.status === "active";
      const subscription = keepLater ? existing : await IAPSubscriptionModel.findOneAndUpdate(
        { ...identity, userId: new Types.ObjectId(userId) },
        { $set: { platform, productId, subscriptionTier, purchaseId,
          originalTransactionId, status: "active", startDate, endDate },
          $setOnInsert: { userId: new Types.ObjectId(userId) } },
        { upsert: true, new: true, runValidators: true, session },
      );
      if (!subscription) throw new Error("Subscription update failed");
      const effectiveProduct = resolveStoreProduct(subscription.productId)!;
      const user = await UserModel.findByIdAndUpdate(userId, {
        $set: { subscriptionTier: effectiveProduct.accessTier,
          subscriptionStartDate: subscription.startDate,
          subscriptionEndDate: subscription.endDate },
      }, { session, new: true });
      if (!user || user.isDeleted) throw new ApiError(httpStatus.FORBIDDEN, "Account unavailable");
      result = { isSubscribed: subscription.status === "active" && subscription.endDate > new Date(),
        subscriptionTier: effectiveProduct.accessTier, subscriptionStartDate: subscription.startDate,
        subscriptionEndDate: subscription.endDate, status: subscription.status,
        platform: subscription.platform, productId: subscription.productId };
    });
  } catch (error: any) {
    if (error?.code === 11000) throw new ApiError(httpStatus.CONFLICT, "Purchase is already linked; restore on its original account");
    throw error;
  } finally { await session.endSession(); }
  // No financial credit is fabricated from a product's list price. Settlement
  // reconciliation must use the store's actual proceeds and a unique event ID.
  return result;
};
