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

    if (!code || code !== expectedCode) {
      throw new ApiError(httpStatus.FORBIDDEN, "Invalid bypass code");
    }

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
      message: "Admin access granted. Full subscription activated.",
      data: {
        token: adminToken,
        subscriptionTier: updated.subscriptionTier,
        subscriptionEndDate: updated.subscriptionEndDate,
      },
    });
  }
);
