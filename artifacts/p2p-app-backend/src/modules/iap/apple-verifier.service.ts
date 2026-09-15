import axios from "axios";
import jwt from "jsonwebtoken";

const APPLE_BUNDLE_ID = "com.p2pfittech.ai";
const APPLE_PRODUCTION_API = "https://api.storekit.itunes.apple.com";
const APPLE_SANDBOX_API = "https://api.storekit-sandbox.itunes.apple.com";

export interface VerifiedAppleTransaction {
  transactionId: string;
  originalTransactionId: string;
  productId: string;
  bundleId: string;
  purchaseDate: Date;
  expiresDate: Date;
}

/**
 * Verify a StoreKit 2 transaction with Apple's App Store Server API.
 *
 * The JWS supplied by a client is deliberately never used as an entitlement
 * source. A client can base64-decode and modify a JWS without changing its
 * shape, so the only transaction data consumed below is the signed response
 * returned by Apple's authenticated server API.
 */
export const verifyAppleTransaction = async (
  verificationData: string,
  purchaseId: string,
  expectedProductId: string,
): Promise<VerifiedAppleTransaction> => {
  const clientJws = typeof verificationData === "string" ? verificationData.trim() : "";
  if (!isJwsShape(clientJws)) {
    throw new Error("Apple verification data is not a JWS");
  }

  const issuerId = process.env.APPLE_IAP_ISSUER_ID;
  const keyId = process.env.APPLE_IAP_KEY_ID;
  const privateKey = process.env.APPLE_IAP_PRIVATE_KEY?.replace(/\\n/g, "\n");

  // There is intentionally no local/mock fallback. Until this server
  // verifier is configured, an iOS receipt cannot activate an entitlement.
  if (!issuerId || !keyId || !privateKey) {
    throw new Error("Apple App Store Server API verification is not configured");
  }

  const apiToken = jwt.sign(
    {
      iss: issuerId,
      iat: Math.floor(Date.now() / 1000),
      exp: Math.floor(Date.now() / 1000) + 300,
      aud: "appstoreconnect-v1",
      bid: process.env.APPLE_IAP_BUNDLE_ID || APPLE_BUNDLE_ID,
    },
    privateKey,
    {
      algorithm: "ES256",
      header: { alg: "ES256", kid: keyId, typ: "JWT" },
    },
  );

  if (process.env.NODE_ENV === "production" && process.env.APPLE_IAP_ENVIRONMENT?.toLowerCase() === "sandbox") {
    throw new Error("Sandbox verification is disabled for production entitlements");
  }

  const baseUrl =
    process.env.APPLE_IAP_ENVIRONMENT?.toLowerCase() === "sandbox"
      ? APPLE_SANDBOX_API
      : APPLE_PRODUCTION_API;

  const response = await axios.get(
    `${baseUrl}/inApps/v1/transactions/${encodeURIComponent(purchaseId)}`,
    {
      headers: { Authorization: `Bearer ${apiToken}` },
      timeout: 10000,
    },
  );

  const signedTransactionInfo = response.data?.signedTransactionInfo;
  if (typeof signedTransactionInfo !== "string" || !isJwsShape(signedTransactionInfo)) {
    throw new Error("Apple returned no verifiable transaction");
  }

  // This payload is decoded only after the authenticated Apple API has
  // accepted the transaction and returned its signed transaction object.
  // Never replace this with decoding the client-provided JWS above.
  const transaction = decodeServerVerifiedPayload(signedTransactionInfo);
  const bundleId = transaction.bundleId;
  const productId = transaction.productId;
  const transactionId = transaction.transactionId;
  const originalTransactionId = transaction.originalTransactionId;
  const purchaseDate = dateFromAppleMilliseconds(transaction.purchaseDate);
  const expiresDate = dateFromAppleMilliseconds(transaction.expiresDate);

  if (
    typeof bundleId !== "string" ||
    typeof productId !== "string" ||
    typeof transactionId !== "string" ||
    typeof originalTransactionId !== "string" ||
    bundleId !== (process.env.APPLE_IAP_BUNDLE_ID || APPLE_BUNDLE_ID) ||
    productId !== expectedProductId ||
    transactionId !== purchaseId ||
    !originalTransactionId ||
    !purchaseDate ||
    !expiresDate ||
    (process.env.NODE_ENV === "production" && transaction.environment !== "Production") ||
    transaction.revocationDate !== undefined
  ) {
    throw new Error("Apple transaction does not match the requested purchase");
  }

  return {
    transactionId,
    originalTransactionId,
    productId,
    bundleId,
    purchaseDate,
    expiresDate,
  };
};

const isJwsShape = (value: string): boolean =>
  /^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$/.test(value);

const dateFromAppleMilliseconds = (value: unknown): Date | null => {
  if (typeof value !== "number" || !Number.isFinite(value) || value <= 0) {
    return null;
  }

  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? null : date;
};

const decodeServerVerifiedPayload = (jws: string): Record<string, unknown> => {
  const payloadPart = jws.split(".")[1];
  const base64 = payloadPart.replace(/-/g, "+").replace(/_/g, "/");
  const padded = base64 + "=".repeat((4 - (base64.length % 4)) % 4);

  try {
    const payload = JSON.parse(Buffer.from(padded, "base64").toString("utf8"));
    if (!payload || typeof payload !== "object" || Array.isArray(payload)) {
      throw new Error("Apple transaction payload is not an object");
    }
    return payload as Record<string, unknown>;
  } catch {
    throw new Error("Apple returned malformed transaction data");
  }
};