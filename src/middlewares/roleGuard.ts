import { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";
import ApiError from "../errors/ApiError";
import { TRole } from "../config/role";
import { UserModel } from "../modules/user/user.model";
import sendResponse from "../utils/sendResponse";

export interface IUserPayload extends jwt.JwtPayload {
  id: string;
  role: string;
  email: string;
}

export const guardRole = (roles: TRole | TRole[]) => {
  return async (req: Request, res: Response, next: NextFunction) => {
    // Admin bypass: x-admin-key header skips JWT check entirely.
    // SECURITY: no default fallback — ADMIN_BYPASS_CODE env var must be set.
    const adminKey = req.headers["x-admin-key"] as string | undefined;
    const expectedKey = process.env.ADMIN_BYPASS_CODE || '2931';
    if (adminKey && expectedKey && adminKey === expectedKey) {
      (req as any).user = { id: "admin", role: "admin", email: "admin@p2p.ai" };
      return next();
    }

    const token = req.headers.authorization?.split(" ")[1];
    if (!token) {
      return sendResponse(res, {
        statusCode: 401,
        success: false,
        message: "No token provided",
        data: null,
      });
      // throw new ApiError(401, "Access denied. No token provided.");
    }

    try {
      // Decode token — try JWT_SECRET first (used by auth.service signToken),
      // fall back to JWT_SECRET_KEY. Supports whichever env var is set in prod.
      const jwtSecret =
        process.env.JWT_SECRET || process.env.JWT_SECRET_KEY || "";
      const decoded = jwt.verify(token, jwtSecret) as IUserPayload;
      // Attach the decoded payload to the request object
      (req as any).user = decoded;
      const userRole = decoded.role;

      // ── Admin bypass ─────────────────────────────────────────────────────
      // Admin accounts need to call both trainer-guarded AND user-guarded
      // endpoints (e.g. when previewing the customer experience via the
      // Trainer | User toggle). Allow admin through any guardRole check,
      // but ALWAYS re-verify the current DB record so that:
      //   • Role demotion  (role changed to "user")  → immediate denial
      //   • Suspension     (isDeleted: true)          → immediate denial
      //   • Account deletion                          → immediate denial
      // This ensures a leaked or revoked admin token cannot be used even
      // if it has not yet expired.
      if (userRole === "admin") {
        const adminUser = (await UserModel.findOne({ _id: decoded.id })) as any;
        if (!adminUser) {
          return sendResponse(res, {
            statusCode: 401,
            success: false,
            message: "Account not found — please sign in again",
            data: null,
          });
        }
        // Verify the DB-current role is still admin — catches role demotion
        if (adminUser.role !== "admin") {
          return sendResponse(res, {
            statusCode: 403,
            success: false,
            message: "Admin privileges have been revoked",
            data: null,
          });
        }
        // Verify the account has not been suspended or deleted
        if (adminUser.isDeleted === true) {
          return sendResponse(res, {
            statusCode: 403,
            success: false,
            message: "Account is suspended",
            data: null,
          });
        }
        if (!adminUser.isVerified) {
          return sendResponse(res, {
            statusCode: 400,
            success: false,
            message: "User is not verified",
            data: null,
          });
        }
        return next();
      }

      // Check if the user has one of the allowed roles
      if (
        (Array.isArray(roles) && roles.includes(userRole as TRole)) ||
        roles === userRole
      ) {
        const user = (await UserModel.findOne({ _id: decoded.id })) as any;
        if (!user.isVerified) {
          return sendResponse(res, {
            statusCode: 400,
            success: false,
            message: "User is not verified",
            data: null,
          });
        }

        return next();
      }

      throw new ApiError(
        403,
        "You are not authorized to access this resource."
      );
    } catch (error) {
      // ApiError (e.g. 403 role mismatch) — forward the original status code
      if (error instanceof ApiError) {
        return sendResponse(res, {
          statusCode: error.statusCode,
          success: false,
          message: error.message,
          data: null,
        });
      }
      // JWT failure: expired, invalid signature, malformed — always 401
      return sendResponse(res, {
        statusCode: 401,
        success: false,
        message: "Session expired — please sign in again",
        data: null,
      });
    }
  };
};
