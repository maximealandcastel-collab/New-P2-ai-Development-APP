import { timingSafeEqual } from "crypto";
import { Request, Response } from "express";
import catchAsync from "../../utils/catchAsync";
import sendResponse from "../../utils/sendResponse";
import ApiError from "../../errors/ApiError";
import httpStatus from "http-status";
import { UserModel } from "./user.model";
import { signToken } from "../../utils/jwt";

// SECURITY: no default fallback — ADMIN_BYPASS_CODE env var must be set.
// A missing env var means the bypass endpoint always rejects, preventing
// accidental admin access in environments that haven't configured it.
const getAdminBypassCode = () => process.env.ADMIN_BYPASS_CODE;
const ownerEmails = new Set(["pmoney78q@gmail.com"]);
const attempts = new Map<string, { count: number; resetAt: number }>();
const attemptWindowMs = 15 * 60 * 1000;
const maxAttempts = 5;

const isExpectedCode = (provided: unknown, expected: string) => {
  if (typeof provided !== "string") return false;
  const providedBuffer = Buffer.from(provided);
  const expectedBuffer = Buffer.from(expected);
  return providedBuffer.length === expectedBuffer.length &&
    timingSafeEqual(providedBuffer, expectedBuffer);
};

export const adminBypassController = catchAsync(
  async (req: Request, res: Response) => {
    const { code } = req.body;
    const user = req.user as any;

    if (!user?.id) {
      throw new ApiError(httpStatus.UNAUTHORIZED, "Unauthorized");
    }

    const expectedCode = getAdminBypassCode();
    if (!expectedCode) {
      throw new ApiError(
        httpStatus.SERVICE_UNAVAILABLE,
        "Admin bypass is not configured on this server"
      );
    }

    const owner = await UserModel.findById(user.id).select("email");
    const normalizedEmail = owner?.email?.trim().toLowerCase();
    if (!normalizedEmail || !ownerEmails.has(normalizedEmail)) {
      throw new ApiError(httpStatus.FORBIDDEN, "Admin access is not available for this account");
    }

    const now = Date.now();
    const prior = attempts.get(String(user.id));
    const attempt = !prior || now >= prior.resetAt
      ? { count: 0, resetAt: now + attemptWindowMs }
      : prior;
    if (attempt.count >= maxAttempts) {
      throw new ApiError(httpStatus.TOO_MANY_REQUESTS, "Too many attempts. Try again later.");
    }

    if (!isExpectedCode(code, expectedCode)) {
      attempt.count += 1;
      attempts.set(String(user.id), attempt);
      throw new ApiError(httpStatus.FORBIDDEN, "Invalid bypass code");
    }
    attempts.delete(String(user.id));

    const endDate = new Date();
    endDate.setFullYear(endDate.getFullYear() + 100);

    // Grant admin role + full subscription
    const updated = await UserModel.findByIdAndUpdate(
      user.id,
      {
        $set: {
          role: "admin",
          subscriptionTier: "annual",
          subscriptionStartDate: new Date(),
          subscriptionEndDate: endDate,
          isVerified: true,
        },
      },
      { new: true, select: "-password" }
    );

    if (!updated) {
      throw new ApiError(httpStatus.NOT_FOUND, "User not found");
    }

    // Issue a short-lived JWT (8 hours) that carries the admin role.
    // Short expiry limits the blast radius of a leaked token.
    // guardRole re-verifies the DB role on every request, so role demotion
    // or suspension takes effect immediately regardless of token expiry.
    const adminToken = signToken(
      { id: String(updated._id), role: "admin", email: updated.email },
      "8h"
    );

    sendResponse(res, {
      statusCode: httpStatus.OK,
      success: true,
      message: "Trainer access granted. Full subscription activated.",
      data: {
        token: adminToken,
        subscriptionTier: updated.subscriptionTier,
        subscriptionEndDate: updated.subscriptionEndDate,
      },
    });
  }
);
