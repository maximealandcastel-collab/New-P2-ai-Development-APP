import { Request, Response } from "express";

import catchAsync from "../../utils/catchAsync";
import sendError from "../../utils/sendError";
import sendResponse from "../../utils/sendResponse";

import {
  getUserMemory,
  getUserProfile,
  getUserWorkoutHistory,
  updateUserProfile,
  UserService,
  consumePasswordReset,
} from "./user.service";
import { completeOnboarding as completeOnboardingService } from "./user.service";
import { OTPModel, UserModel } from "./user.model";
import { TrainerModel } from "../trainer/trainer.model";
import { SubscriptionModel } from "../subscription/subscription.model";

import { emitNotification } from "../../utils/socket";
import httpStatus from "http-status";
// import RegisterShowerModel from "../RegisterShower/RegisterShower.model";

import argon2 from "argon2";

import {
  findUserByEmail,
  findUserById,
  generateOTP,
  hashPassword,
  saveOTP,
  sendOTPEmailRegister,
  sendOTPEmailVerification,
  isOtpResendAllowed,
} from "./user.utils";

import ApiError from "../../errors/ApiError";
import {
  generateRegisterToken,
  generateToken,
  generateTokenForAdmin,
  verifyToken,
} from "../../utils/JwtToken";

import { sendPushNotification } from "../notifications/pushNotification/pushNotification.controller";
import { IUserPayload } from "../../middlewares/roleGuard";

import { JwtPayloadWithUser } from "../../middlewares/userVerification";
import {
  isPublicSignupRoleAllowed,
  tenantScopeForUser,
} from "../../config/tenants";

import mongoose from "mongoose";
import { number } from "zod";
import {
  normalizeTenantRole,
  normalizeTenantSlug,
  platformRoleForTenantRole,
} from "../tenantAccess/tenantAccess.service";

//  register User

const registerUser = catchAsync(async (req: Request, res: Response) => {
  const { firstName, lastName, password, gender, role } = req.body;
  const email = typeof req.body.email === "string" ? req.body.email.trim().toLowerCase() : req.body.email;
  const suppliedTenantId = req.body.tenantId;
  const tenantId = normalizeTenantSlug(suppliedTenantId);
  if (suppliedTenantId !== undefined && !tenantId) throw new ApiError(400, "Unsupported tenant.");
  req.body.email = email;
  if (tenantId) {
    const tenantRole = normalizeTenantRole(req.body.tenantRole);
    if (!tenantRole) {
      throw new ApiError(400, "Choose a valid Gym role.");
    }
    req.body.tenantId = tenantId;
    req.body.tenantRole = tenantRole;
    req.body.role = platformRoleForTenantRole(tenantRole);
  } else {
    delete req.body.tenantId;
    delete req.body.tenantRole;
  }

  if (!firstName || typeof firstName !== "string" || firstName.trim().length < 2) {
    throw new ApiError(400, "First name is required.");
  }
  if (!lastName || typeof lastName !== "string" || lastName.trim().length < 2) {
    throw new ApiError(400, "Last name is required.");
  }
  if (!email || typeof email !== "string" || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    throw new ApiError(400, "A valid email address is required.");
  }
  if (!password || typeof password !== "string" || password.length < 8) {
    throw new ApiError(400, "Password must be at least 8 characters.");
  }
  if (!["male", "female", "not_prefer_to_say"].includes(gender)) {
    throw new ApiError(
      400,
      "Gender must be male, female, or not_prefer_to_say.",
    );
  }
  const effectiveRole = req.body.role;
  if (!isPublicSignupRoleAllowed(undefined, effectiveRole)) {
    throw new ApiError(400, "Role must be either user or trainer.");
  }
  // Step 1: Register the user and get OTP
  const { data } = await UserService.registerUserService(req);

  const { otp, user } = data; // user already created here

  const token = generateRegisterToken({ email });

  // Complete delivery and persistence before responding. The mobile client
  // relies on this response to begin the verification flow.
  try {
    // Persist the code before delivery so the code being emailed is always
    // backed by the same server-side record.
    await saveOTP(email, String(otp));
    await sendOTPEmailRegister(firstName, email, String(otp));
  } catch (deliveryError) {
    // Do not leave an unverifiable account behind when delivery fails.
    await UserModel.deleteOne({ _id: user._id, isVerified: false });
    await OTPModel.deleteMany({ email, consumedAt: { $exists: false } });
    throw deliveryError;
  }

  // Notifications are auxiliary and must never make a successful signup fail.
  try {
    await emitNotification({
      userId: user._id,
      userMsgTittle: "🎉 Registration Completed",
      adminMsgTittle: "📢 New User Registration",
      userMsg: `Welcome to ${process.env.AppName}, ${user?.firstName}! 🎉`,
      adminMsg: `New user ${user?.firstName} has registered on ${process.env.AppName}.`,
    } as any);
  } catch {
    // Intentionally ignored: signup and verification are already durable.
  }

  return sendResponse(res, {
    statusCode: httpStatus.OK,
    success: true,
    message:
      "OTP sent to your email address. Please verify to continue registration.",
    data: { token, role: user.role, tenantScope: tenantScopeForUser(user as any) },
  });
});

const resendOTP = catchAsync(async (req: Request, res: Response) => {
  const startedAt = Date.now();
  const MIN_RESEND_RESPONSE_MS = 75;
  const email = typeof req.body.email === "string"
    ? req.body.email.trim().toLowerCase()
    : "";

  const isExist: any = await UserModel.findOne({ email });
  const genericResendResponse = async () => {
    const remaining = MIN_RESEND_RESPONSE_MS - (Date.now() - startedAt);
    if (remaining > 0) await new Promise((resolve) => setTimeout(resolve, remaining));
    return sendResponse(res, {
      statusCode: httpStatus.OK,
      success: true,
      message: "If the account is eligible, a verification code will be sent.",
      data: "",
    });
  };
  if (!isExist) {
    return genericResendResponse();
  }

  if (isExist.isVerified) {
    return genericResendResponse();
  }
  const previousOtp: any = await OTPModel.findOne({ email });
  if (!isOtpResendAllowed(
    previousOtp?.sentAt,
    previousOtp?.verifiedAt,
  )) {
    return genericResendResponse();
  }
  const otp = generateOTP();
  // Issue/persist first. A delivery failure invalidates only this challenge.
  const challengeId = await saveOTP(email, String(otp));
  try {
    await sendOTPEmailRegister(isExist.firstName, email, String(otp));
  } catch (error) {
    if (challengeId) {
      await OTPModel.updateOne(
        { _id: challengeId, consumedAt: { $exists: false } },
        { $set: { consumedAt: new Date() } },
      );
    }
  }

  return genericResendResponse();
});

export const loginUser = catchAsync(async (req: Request, res: Response) => {
  const { email: rawEmail, password, fcmToken } = req.body;
  const email = rawEmail?.trim().toLowerCase();

  const user = await UserModel.findOne({ email });
  if (!user) {
    throw new ApiError(401, "This account does not exist.");
  }

  if (user.isDeleted) {
    throw new ApiError(404, "your account is deleted.");
  }

  // ── Brute-force gate ───────────────────────────────────────
  // After 5 wrong passwords the account is locked for 15 minutes.
  const now0 = new Date();
  if (user.loginLockUntil && user.loginLockUntil > now0) {
    const minutesLeft = Math.ceil(
      (user.loginLockUntil.getTime() - now0.getTime()) / 60000,
    );
    throw new ApiError(
      429,
      `Too many failed login attempts. Try again in ${minutesLeft} minute${minutesLeft === 1 ? "" : "s"}.`,
    );
  }

  // Always verify the password BEFORE issuing any token or OTP.
  const passwordOk = await argon2.verify(user.password as string, password);
  if (!passwordOk) {
    const MAX_ATTEMPTS = 5;
    const LOCK_MINUTES = 15;
    // Atomic increment so concurrent wrong attempts cannot undercount
    const updated = await UserModel.findOneAndUpdate(
      { _id: user._id },
      { $inc: { failedLoginAttempts: 1 } },
      { new: true, select: "failedLoginAttempts" },
    );
    const attempts = updated?.failedLoginAttempts || 1;
    if (attempts >= MAX_ATTEMPTS) {
      await UserModel.updateOne(
        { _id: user._id },
        {
          $set: {
            loginLockUntil: new Date(Date.now() + LOCK_MINUTES * 60000),
            failedLoginAttempts: 0,
          },
        },
      );
      throw new ApiError(
        429,
        `Too many failed login attempts. Your account is locked for ${LOCK_MINUTES} minutes.`,
      );
    }
    throw new ApiError(
      401,
      `Wrong password! ${MAX_ATTEMPTS - attempts} attempt${MAX_ATTEMPTS - attempts === 1 ? "" : "s"} remaining before a temporary lock.`,
    );
  }

  // Successful password — reset the failed-attempt counter
  if (user.failedLoginAttempts || user.loginLockUntil) {
    await UserModel.updateOne(
      { _id: user._id },
      { failedLoginAttempts: 0, loginLockUntil: null },
    );
  }

  const userId = user._id.toString();

  const verifyToken = generateToken({
    id: userId,
    email: user.email,
    role: user.role,
  });
  if (!user.isVerified) {
    sendResponse(res, {
      statusCode: 401,
      success: false,
      message: "We've sent an OTP to your email to verify your profile.",
      data: {
        role: user.role,
        token: verifyToken,
        tenantScope: tenantScopeForUser(user as any),
      },
    });
    const name = user.firstName as string;
    const otp = generateOTP();
    sendOTPEmailVerification(name, email, otp)
      .then(() => {})
      .catch((err) => {
        console.error("Error sending OTP email:", err);
      });
    // Also deliver the OTP by SMS when the user has a phone number on file
    if (user.phone) {
      UserService.sendPhoneVerification(user.phone, otp).catch((err: any) => {
        console.error("Error sending OTP SMS:", err?.message || err);
      });
    }
    return await saveOTP(email, otp);
  }

  if (fcmToken) {
    user.fcmToken = fcmToken;
  }

  const token = generateToken({
    id: userId,
    email: user.email,
    role: user.role,
  });

  // Determine if this user currently has an active subscription
  const now = new Date();
  const isSubscribed =
    user.role === "user"
      ? (!!(await SubscriptionModel.exists({
          userId: user._id,
          status: "active",
        })) || !!(user.subscriptionEndDate && user.subscriptionEndDate > now))
      : false;

  // Build the dynamic response payload based on the user's role
  const responseData: any = {
    user: {
      _id: user._id,
      name: user?.firstName + " " + user?.lastName,
      email: user?.email,
      role: user?.role,
      tenantScope: tenantScopeForUser(user as any),
    },
    isSubscribed,
    token,
  };

  if (user.role === "trainer") {
    responseData.isProfile = !!(await TrainerModel.exists({ userId: user._id }));
  } else if (user.role === "user") {
    responseData.onboardingCompleted = !!user.onboardingCompleted;
  }

  sendResponse(res, {
    statusCode: httpStatus.OK,
    success: true,
    message: "Login complete!",
    data: responseData,
  });

  await user.save();
});

// //cool down timer
export const forgotPassword = catchAsync(
  async (req: Request, res: Response) => {
    const { email: rawEmail } = req.body;
    const email = rawEmail?.trim().toLowerCase();
    if (!email) {
      throw new ApiError(400, "Please provide your email.");
    }

    // await delCache(email);
    const user = await UserModel.findOne({ email });
    if (!user) {
      throw new ApiError(401, "This account does not exist.");
    }

    const now = new Date();
    // Check if there's a pending OTP request and if the 2-minute cooldown has passed
    // const otpRecord = await OTPModel.findOne({ email });
    // if (otpRecord && otpRecord.expiresAt > now) {
    //   const remainingTime = Math.floor(
    //     (otpRecord.expiresAt.getTime() - now.getTime()) / 1000
    //   );

    //   throw new ApiError(
    //     403,
    //     `You can't request another OTP before ${remainingTime} seconds.`
    //   );
    // }
    const otp = generateOTP();
    const challengeId = await saveOTP(email, otp, "password_reset");
    if (!challengeId) throw new ApiError(500, "Unable to create password reset challenge");
    try {
      // Deliver through every configured channel before claiming success.
      if (user.phone) await UserService.sendPhoneVerification(user.phone, otp);
      await sendOTPEmailRegister(user.firstName, email, otp);
    } catch (deliveryError) {
      await OTPModel.updateOne(
        { _id: challengeId, consumedAt: { $exists: false } },
        { $set: { consumedAt: new Date() } },
      );
      throw deliveryError;
    }
    return sendResponse(res, {
      statusCode: httpStatus.OK,
      success: true,
      message: "OTP sent to your email. Please check!",
      data: { email },
    });
    // await saveOTP(email, otp); // Save OTP with expiration
  },
);

export const resetPassword = catchAsync(async (req: Request, res: Response) => {
  const auth = req.headers.authorization || "";
  const resetToken = auth.startsWith("Bearer ") ? auth.slice(7).trim() : req.body.resetToken;
  const { password } = req.body;
  if (!password) {
    throw new ApiError(400, "Please provide  password ");
  }
  await consumePasswordReset(resetToken, password);
  return sendResponse(res, {
    statusCode: httpStatus.OK,
    success: true,
    message: "Password reset successfully.",
    data: null,
  });
});

export const verifyOTP = catchAsync(async (req: Request, res: Response) => {
  const { otp } = req.body;
  const resetEmail = req.body.purpose === "password_reset" &&
    typeof req.body.email === "string"
    ? req.body.email.trim().toLowerCase()
    : "";
  const result = resetEmail
    ? await UserService.verifyForgotPasswordOTPService(resetEmail, String(otp))
    : await UserService.verifyOTPService(String(otp), req.headers.authorization as string);
  const { token, name, email } = result as any;

  const user = (await UserModel.findOne({ email })) as any;
  if (!user) {
    throw new ApiError(404, "User not found.");
  }
  // Mark user as verified
  if (!resetEmail && !user.isVerified) {
    user.isVerified = true;
    await user.save();
  }
  sendResponse(res, {
    statusCode: httpStatus.CREATED,
    success: true,
    message: "OTP Verified successfully.",
      data: {
        name,
        token,
        role: user.role,
        tenantScope: tenantScopeForUser(user as any),
      },
  });
});

// User Id
export const updateUser = catchAsync(async (req: Request, res: Response) => {
  const { firstName, lastName, dateOfBirth, bio } = req.body;

  const decoded = req.user as IUserPayload;
  const userId = decoded.id;

  const user = await findUserById(userId);
  if (!user) {
    throw new ApiError(404, "User not found.");
  }

  const updateData: any = {};

  if (firstName) updateData.name = firstName;
  if (lastName) updateData.surname = lastName;
  if (dateOfBirth) updateData.contact = dateOfBirth;
  if (bio) updateData.address = bio;

  // // Email update – SAFE way
  // if (email && email !== user.email) {
  //   const emailExists = await UserModel.findOne({
  //     email,
  //     _id: { $ne: userId },
  //   });

  //   if (emailExists) {
  //     throw new ApiError(409, "Email already in use.");
  //   }

  //   updateData.email = email;
  // }

  if (req.file) {
    updateData.image = `/images/${req.file.filename}`;
  }

  const updatedUser = await UserService.updateUserById(userId, updateData);

  return sendResponse(res, {
    statusCode: httpStatus.OK,
    success: true,
    message: "Profile updated.",
    data: {
      _id: updatedUser?._id,
      name: `${updatedUser?.firstName} ${updatedUser?.lastName}`,
      email: updatedUser?.email,
    },
  });
});

export const getSelfInfo = catchAsync(async (req: Request, res: Response) => {
  try {
    const decoded = req.user as IUserPayload;

    const userId = decoded.id as string;

    // Find the user in DB
    const user = await findUserById(userId);
    if (!user) {
      throw new ApiError(404, "User not found.");
    }

    // Prepare base response (common fields)
    const responseData: any = {
      _id: user._id,
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      profilePicture: user.profilePicture || null,
      role: user.role,
      tenantScope: tenantScopeForUser(user as any),
    };

    // Send final response
    return sendResponse(res, {
      statusCode: httpStatus.OK,
      success: true,
      message: "Profile information retrieved successfully",
      data: responseData,
      pagination: undefined,
    });
  } catch (error: any) {
    throw new ApiError(
      error.statusCode || 500,
      error.message ||
        "Unexpected error occurred while retrieving user information.",
    );
  }
});

// ─────────────────────────────────────────────────────────────
// Shared helper: save an uploaded image onto the user's document.
// profilePicture and coverPhoto are common fields on UserModel, so
// both regular users and trainers use the same record.
// Photos are stored in GCS (permanent) — never on local disk (ephemeral).
// ─────────────────────────────────────────────────────────────
import { Storage } from "@google-cloud/storage";

const _SIDECAR = "http://127.0.0.1:1106";
const _gcs = new Storage({
  credentials: {
    audience: "replit",
    subject_token_type: "access_token",
    token_url: `${_SIDECAR}/token`,
    type: "external_account",
    credential_source: {
      url: `${_SIDECAR}/credential`,
      format: { type: "json", subject_token_field_name: "access_token" },
    },
    universe_domain: "googleapis.com",
  },
  projectId: "",
});
const _GCS_BUCKET   = process.env.DEFAULT_OBJECT_STORAGE_BUCKET_ID || "";
const _BACKEND_URL  = "https://fit-tech-ai.replit.app";

const saveUserImageToGCS = async (
  userId: string,
  file: Express.Multer.File,
  field: "profilePicture" | "coverPhoto",
) => {
  // Derive extension from original filename or mime type
  const ext = file.originalname.includes(".")
    ? file.originalname.split(".").pop()!.toLowerCase().replace(/[^a-z0-9]/g, "")
    : file.mimetype.split("/")[1]?.split("+")[0] || "jpg";

  const gcsPath = `user-photos/${userId}-${field}.${ext}`;
  const bucket  = _gcs.bucket(_GCS_BUCKET);

  // Upload buffer directly to GCS — permanent, survives restarts
  await bucket.file(gcsPath).save(file.buffer, {
    metadata: {
      contentType: file.mimetype,
      cacheControl: "public, max-age=31536000",
    },
  });

  const permanentUrl = `${_BACKEND_URL}/api/v1/content/video-stream/${gcsPath}`;

  const updatedUser = await UserModel.findByIdAndUpdate(
    userId,
    { [field]: permanentUrl },
    { new: true },
  ).select("-password");

  if (!updatedUser) {
    throw new ApiError(404, "User not found.");
  }
  return updatedUser;
};

export const uploadProfilePicture = catchAsync(
  async (req: Request, res: Response) => {
    const user = req.user as JwtPayloadWithUser;

    if (!req.file) {
      throw new ApiError(400, "Please upload a profile picture.");
    }

    const data = await saveUserImageToGCS(user.id, req.file, "profilePicture");

    return sendResponse(res, {
      statusCode: 200,
      success: true,
      message: "Profile picture uploaded successfully",
      data,
    });
  },
);

export const uploadCoverPhoto = catchAsync(
  async (req: Request, res: Response) => {
    const user = req.user as JwtPayloadWithUser;

    if (!req.file) {
      throw new ApiError(400, "Please upload a cover photo.");
    }

    const data = await saveUserImageToGCS(user.id, req.file, "coverPhoto");

    return sendResponse(res, {
      statusCode: 200,
      success: true,
      message: "Cover photo uploaded successfully",
      data,
    });
  },
);

// delete user
export const deleteUser = catchAsync(async (req: Request, res: Response) => {
  try {
    const id = req.query?.id as string;
    const deleteableuser = await findUserById(id);
    if (!deleteableuser) {
      throw new ApiError(404, "User not found.");
    }
    if (deleteableuser.isDeleted) {
      throw new ApiError(404, "This account is already deleted.");
    }
    if ((req.user as IUserPayload)?.id !== id) {
      throw new ApiError(
        403,
        "You cannot delete this account. Please contact support",
      );
    }

    await UserService.userDelete(id, deleteableuser.email);
    return sendResponse(res, {
      statusCode: httpStatus.OK,
      success: true,
      message: "Account deleted successfully",
      data: null,
    });
  } catch (error: any) {
    throw new ApiError(
      error.statusCode || 500,
      error.message || "Unexpected error occurred while deleting the user.",
    );
  }
});

export const changePassword = catchAsync(
  async (req: Request, res: Response) => {
    try {
      const { oldPassword, newPassword } = req.body;
      if (!oldPassword || !newPassword) {
        throw new Error("Please provide both old password and new password.");
      }

      const decoded = req.user as IUserPayload;
      const email = decoded.email as string;
      const user = await findUserByEmail(email);

      if (!user) {
        throw new Error("User not found.");
      }

      const isMatch = await argon2.verify(user.password as string, oldPassword);
      if (!isMatch) {
        throw new ApiError(
          httpStatus.UNAUTHORIZED,
          "Old password is incorrect.",
        );
      }

      const hashedNewPassword = await argon2.hash(newPassword);
      user.password = hashedNewPassword;
      await user.save();

      sendResponse(res, {
        statusCode: httpStatus.OK,
        success: true,
        message: "You have successfully changed your password.",
        data: null,
      });
    } catch (error: any) {
      throw new ApiError(
        error.statusCode || 500,
        error.message || "Failed to change password.",
      );
    }
  },
);

const adminloginUser = catchAsync(async (req: Request, res: Response) => {
  try {
    const { email, password } = req.body;

    const user = await UserModel.findOne(email);
    if (!user) {
      throw new ApiError(401, "This account does not exist.");
    }

    if (user.role !== "admin") {
      throw new ApiError(403, "Only admins can login.");
    }

    // Check password validity
    const isPasswordValid = await argon2.verify(
      user.password as string,
      password,
    );
    if (!isPasswordValid) {
      throw new ApiError(401, "Wrong password!");
    }

    const userId = user._id.toString();

    // Generate new token for the logged-in user
    const token = generateTokenForAdmin({
      id: userId,
      email: user.email,
      role: user.role,
    });

    sendResponse(res, {
      statusCode: httpStatus.OK,
      success: true,
      message: "Login complete!",
      data: {
        user: {
          id: user._id,
          name: user.firstName,
          email: user.email,
          role: user.role,
          tenantScope: tenantScopeForUser(user as any),
        },
        token,
      },
    });
  } catch (error: any) {
    throw new ApiError(
      error.statusCode || 500,
      error.message || "An error occurred during admin login.",
    );
  }
});

//admin dashboard----------------------------------------------------------------------------------------

// add device id

const addDeviceId = catchAsync(async (req: Request, res: Response) => {
  const user = req.user as JwtPayloadWithUser;
  const { deviceId } = req.body;
  await UserModel.findByIdAndUpdate(
    user.id,
    { deviceId: deviceId },
    { new: true },
  );
  return sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Device ID added successfully",
    data: null,
  });
});

const getAllUsers = catchAsync(async (req: Request, res: Response) => {
  let decoded;
  try {
    decoded = verifyToken(req.headers.authorization);
  } catch (error: any) {
    return sendError(res, error); // If token verification fails, send error response.
  }

  const adminId = decoded.id as string;

  // Verify if admin exists
  const user = await findUserById(adminId);
  if (!user) {
    throw new ApiError(404, "This admin account does not exist.");
  }

  // Pagination and filters
  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 10;
  const skip = (page - 1) * limit;

  const { date, name, email, role, requestStatus } = req.query;

  try {
    // Get the user list based on pagination and filters
    const { users, pagination } = await UserService.getUserList(
      skip,
      limit,
      date as string,
      name as string,
      email as string,
      role as string,
      requestStatus as string,
    );

    if (users.length === 0) {
      return sendResponse(res, {
        statusCode: httpStatus.NO_CONTENT,
        success: true,
        message: "No user found based on your search.",
        data: [],
        pagination: {
          ...pagination,
          prevPage: pagination.prevPage ?? 0,
          nextPage: pagination.nextPage ?? 0,
        },
      });
    }

    // Populate manager info for each user
    const usersWithManagerInfo = await UserModel.populate(users, {
      path: "managerInfoId",
      select: "type businessAddress websiteLink governMentImage.publicFileURL",
    });

    // Format response data
    const responseData = usersWithManagerInfo.map((user: any) => ({
      _id: user._id,
      image: user.image?.publicFileURL,
      name: user.name,
      email: user.email,
      role: user.role,
      phone: user.phone,
      address: user.address,
      //isRequest: user.isRequest,
      managerInfo: user.managerInfoId
        ? {
            type: user.managerInfoId.type,
            businessAddress: user.managerInfoId.businessAddress,
            websiteLink: user.managerInfoId.websiteLink,
            governMentImage: user.managerInfoId.governMentImage?.publicFileURL,
            isRequest: user.isRequest,
          }
        : null,
      createdAt: user.createdAt,
    }));

    // Send response with pagination details
    sendResponse(res, {
      statusCode: httpStatus.OK,
      success: true,
      message: "User list retrieved successfully",
      data: responseData,
      pagination: {
        ...pagination,
        prevPage: pagination.prevPage ?? 0,
        nextPage: pagination.nextPage ?? 0,
      },
    });
  } catch (error: any) {
    // Handle any errors during the user fetching or manager population
    throw new ApiError(
      error.statusCode || 500,
      error.message || "Failed to retrieve users.",
    );
  }
});

// make admin delete

// update admin information

const updateAdminInformation = async (req: Request, res: Response) => {
  try {
    const user = req.user as JwtPayloadWithUser;
    const { name, email, phone } = req.body;

    const userPayload: { name: any; email: any; phone: any; image?: string } = {
      name,
      email,
      phone,
    };

    if (req.file) {
      userPayload.image = `/images/${req.file.filename}`;
    }

    const updateAdmin = await UserModel.findByIdAndUpdate(
      { _id: user.id },
      userPayload,
      { new: true },
    );

    return sendResponse(res, {
      statusCode: 200,
      success: true,
      message: "Admin data updated successfully",
      data: updateAdmin,
    });
  } catch (err) {
    return sendResponse(res, {
      statusCode: 404,
      success: false,
      message: "Something went wrong",
      data: null,
    });
  }
};

// update admin password

// const updateAdminPassword = async (req: Request, res: Response) => {
//   const user = req.user as JwtPayloadWithUser;
//   const userId = user.id;

//   const findadmin = await UserModel.findById(userId);
//   const { oldPassword, newPassword, confirmPassword } = req.body;

//   const isPasswordValid = await argon2.verify(
//     findadmin.password as string,
//     oldPassword
//   );

//   if (!isPasswordValid) {
//     return sendResponse(res, {
//       statusCode: 404,
//       success: false,
//       message: "Old password not matched",
//       data: null,
//     });
//   }

//   if (newPassword !== confirmPassword) {
//     return sendResponse(res, {
//       statusCode: 404,
//       success: false,
//       message: "password and confirm password are not matched",
//       data: null,
//     });
//   }

//   const hashedPassword = await hashPassword(newPassword);

//   const updatePass = await UserModel.findByIdAndUpdate(
//     { _id: userId },
//     { password: hashedPassword },
//     { new: true }
//   );

//   return sendResponse(res, {
//     statusCode: 200,
//     success: true,
//     message: "password updated successfully",
//     data: null,
//   });
// };

const getAdminInfo = async (req: Request, res: Response) => {
  res.status(200).json({ user: req.user });
};

export const getAllCustomers = async (req: Request, res: Response) => {
  try {
    // Get query params
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;
    const skip = (page - 1) * limit;

    // Get optional search filter
    const search = (req.query.search as string) || "";

    // Build search condition
    const searchCondition = {
      role: "customer",
      ...(search
        ? {
            $or: [
              { name: { $regex: search, $options: "i" } },
              { email: { $regex: search, $options: "i" } },
              { phone: { $regex: search, $options: "i" } },
            ],
          }
        : {}),
    };

    // Get total count
    const totalCustomers = await UserModel.countDocuments(searchCondition);

    // Fetch paginated data
    const allCustomers = await UserModel.find(searchCondition)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    // Calculate pagination info
    const totalPage = Math.ceil(totalCustomers / limit);
    const pagination = {
      totalPage,
      currentPage: page,
      prevPage: page > 1 ? page - 1 : null,
      nextPage: page < totalPage ? page + 1 : null,
      totalData: totalCustomers,
    };

    return res.status(200).json({
      success: true,
      message: "Customers fetched successfully",
      data: allCustomers,
      pagination,
    });

    // return sendResponse(res, {
    //   statusCode: 200,
    //   success: true,
    //   message: "Customers fetched successfully",
    //   data: allCustomers,
    //   pagination,
    // });
  } catch (error: any) {
    console.error("Error fetching customers:", error);
    return sendResponse(res, {
      statusCode: 500,
      success: false,
      message: "Failed to fetch customers",
      data: error.message,
    });
  }
};

export const searchSubadmin = async (req: Request, res: Response) => {
  try {
    const { search } = req.query;

    if (!search || typeof search !== "string") {
      return res.status(400).json({ message: "Search query is required" });
    }

    // Case-insensitive search using regex
    const users = await UserModel.find({
      $or: [
        { email: { $regex: search, $options: "i" }, role: "subadmin" },
        { name: { $regex: search, $options: "i" }, role: "subadmin" },
      ],
    }).select("-password");

    res.status(200).json({
      success: true,
      count: users.length,
      data: users,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || "Something went wrong",
    });
  }
};

const getAllSubadmin = async (req: Request, res: Response) => {
  const allSubadmins = await UserModel.find({ role: "subadmin" });

  return sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Customer fetched successfully",
    data: allSubadmins,
  });
};

const updateUserStatus = async (req: Request, res: Response) => {
  const userId = req.params.userId;
  const status = req.params.status;

  const findUser = await UserModel.findById(userId);

  if (!["active", "blocked"].includes(status)) {
    return sendResponse(res, {
      statusCode: 404,
      success: false,
      message: "Status is not valid",
      data: null,
    });
  }

  const findBarber = await UserModel.findById(userId);

  if (!findBarber) {
    return sendResponse(res, {
      statusCode: 404,
      success: false,
      message: "User not registered",
      data: null,
    });
  }

  const updateUserStatus = await UserModel.findByIdAndUpdate(
    { _id: userId },
    { status },
    { new: true },
  );

  // send Notification
  // // --------> Emit notification <----------------
  // Convert the created user's id to a mongoose ObjectId type.
  const user: any = findUser;
  // Create a payload for notifications with messages for both the user and the admin.
  const notificationPayload: any = {
    userId: user?._id,
    userMsgTittle: "User Status updated successfully",
    adminMsgTittle: `Profile status updated to ${status}`,
    userMsg: `Your profile status have been updated to ${status}`,
    adminMsg: `${user.name} satatus successfully changed to ${status}`,
  };

  // Emit the notification.
  await emitNotification(notificationPayload);
  // --------> End Emit notification <----------------
  // --------> Send push notification via FCM (if fcmToken is provided) <----------------
  if (user.fcmToken) {
    try {
      // Define the base push message.
      const pushMessage = {
        title: `Your status have been changed to ${status}`,
        body: `Your status have been changed to ${status}`,
      };

      // Send the push notification.
      await sendPushNotification(user.fcmToken, pushMessage);
    } catch (pushError) {
      // Log any push notification errors without affecting the client response.
      console.error("Error sending push notification:", pushError);
    }
  }
  // send notification
  // --------> End push notification <----------------
  return sendResponse(res, {
    statusCode: 200,
    success: false,
    message: "Barber status updated successfully",
    data: updateUserStatus,
  });
};

// get admin profile

const getAdminProfile = async (req: Request, res: Response) => {
  const getAdmin = await UserModel.findOne({ role: "admin" });

  return sendResponse(res, {
    statusCode: 200,
    success: false,
    message: "Admin found successfully",
    data: getAdmin,
  });
};

export const searchCustomer = async (req: Request, res: Response) => {
  try {
    const { search } = req.query;

    if (!search || typeof search !== "string") {
      return res.status(400).json({ message: "Search query is required" });
    }

    // Case-insensitive search using regex
    const users = await UserModel.find({
      $or: [
        { email: { $regex: search, $options: "i" }, role: "customer" },
        { name: { $regex: search, $options: "i" }, role: "customer" },
      ],
    }).select("-password");

    res.status(200).json({
      success: true,
      count: users.length,
      data: users,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || "Something went wrong",
    });
  }
};

// reset admin password

export const resetAdminPassword = catchAsync(
  async (req: Request, res: Response) => {
    const { phone, otp, password } = req.body;

    if (!phone) throw new ApiError(400, "Phone number is required.");
    if (!otp) throw new ApiError(400, "OTP is required.");
    if (!password) throw new ApiError(400, "Password is required.");

    // 1️⃣ Verify OTP
    const otpRecord = await OTPModel.findOne({ phone, otp });
    if (!otpRecord) {
      throw new ApiError(400, "Invalid or expired OTP.");
    }

    // Optional: check if OTP is expired
    const now = new Date();
    if (otpRecord.expiresAt && otpRecord.expiresAt < now) {
      throw new ApiError(400, "OTP has expired.");
    }

    // 2️⃣ Find user
    const user = await UserModel.findOne({ phone });
    if (!user) {
      throw new ApiError(404, "User not found.");
    }

    // 3️⃣ Hash and update password
    user.password = await hashPassword(password);

    // Mark as verified if needed
    if (!user.isVerified) user.isVerified = true;

    await user.save();

    // 4️⃣ Delete OTP after successful reset
    await OTPModel.deleteOne({ _id: otpRecord._id });

    // 5️⃣ Send response
    sendResponse(res, {
      statusCode: httpStatus.OK,
      success: true,
      message: "Password reset successfully.",
      data: {
        email: user.email,
        name: user.firstName,
      },
    });
  },
);

// count total customer

export const dashboardStats = async (req: Request, res: Response) => {
  try {
    const totalCustomer = await UserModel.find({
      role: "customer",
    }).countDocuments();
    const totalBarber = await UserModel.find({
      role: "barber",
    }).countDocuments();

    const dashboardStats = {
      totalCustomer,
      totalBarber,
    };

    return sendResponse(res, {
      statusCode: 200,
      success: true,
      message: "Total customer retrived successfully",
      data: dashboardStats,
    });
  } catch (err) {
    console.error("Failed to load dashboard statistics");
  }
};

// add superadmin

// export const addSuperadmin = catchAsync(async (req: Request, res: Response) => {
//   const { name, password, phone, email } = req.body;

//   (async () => {
//     try {
//       const hashedPassword = await hashPassword(password);
//       let image: any = {
//         path: "",
//         publicFileURL: "",
//       };
//       if (req.file) {
//         const imagePath = `public\\images\\${req.file.filename}`;
//         const publicFileURL = `/images/${req.file.filename}`;
//         image = {
//           path: imagePath,
//           publicFileURL: publicFileURL,
//         };
//       }
//       // Pass role to createUser
//       const createdUser: any = await UserModel.create({
//         name,
//         password: hashedPassword,
//         phone,
//         email,
//         image: image.publicFileURL,
//         role: "subadmin",
//         status: "active",
//         isVerified: true,
//       });

//       return sendResponse(res, {
//         statusCode: 200,
//         success: true,
//         message: "Super admin created successfully",
//         data: createdUser,
//       });
//     } catch (backgroundError: any) {
//       console.error("Error in background tasks:", backgroundError?.message);
//       return sendResponse(res, {
//         statusCode: 400,
//         success: false,
//         message: "Something went wrong",
//         data: null,
//       });
//     }
//   })();
// });

// export const logoutUser = async (req: Request, res: Response) => {
//   try {
//     const user = req.user as JwtPayloadWithUser;
//     const userId = user.id;
//     const updateLoginStatus = await UserModel.findByIdAndUpdate(
//       userId,
//       { isLogin: false },
//       { new: true, upsert: true }
//     ).select("name phone email  role isLogin");

//     const token = generateToken({
//       id: userId,
//       email: updateLoginStatus.email,
//       role: updateLoginStatus.role,
//     });

//     return sendResponse(res, {
//       statusCode: 200,
//       success: true,
//       message: "User logout successfully",
//       data: { user: updateLoginStatus, token },
//     });
//   } catch (err) {
//     return sendResponse(res, {
//       statusCode: 400,
//       success: false,
//       message: "Your login failed",
//       data: null,
//     });
//   }
// };

// ─────────────────────────────────────────────────────────────
// GET /users/me
// ─────────────────────────────────────────────────────────────

export const getProfile = async (
  req: Request,
  res: Response,
): Promise<void> => {
  try {
    const userId = (req.user as JwtPayloadWithUser).id;

    const user = await getUserProfile(userId);
    if (!user) {
      res.status(404).json({ success: false, message: "User not found" });
      return;
    }
    const { tenantId, gymAdminTenantIds, ...profile } = user as any;
    res.json({
      success: true,
      data: {
        ...profile,
        tenantScope: tenantScopeForUser({ tenantId, gymAdminTenantIds, role: profile.role }),
      },
    });
  } catch (err: any) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// ─────────────────────────────────────────────────────────────
// PUT /users/me
// ─────────────────────────────────────────────────────────────

export const updateProfile = async (
  req: Request,
  res: Response,
): Promise<void> => {
  try {
    const userId = (req.user as JwtPayloadWithUser).id;
    const user = await updateUserProfile(userId, req.body);
    res.json({ success: true, data: user });
  } catch (err: any) {
    res.status(400).json({ success: false, message: err.message });
  }
};

// ─────────────────────────────────────────────────────────────
// POST /users/me/onboarding
// ─────────────────────────────────────────────────────────────

export const completeOnboarding = async (
  req: Request,
  res: Response,
): Promise<void> => {
  try {
    const userId = (req.user as JwtPayloadWithUser).id;
    const result = await completeOnboardingService(userId, req.body);

    res.json({
      success: true,
      message: "Onboarding complete! Your AI trainer has been assigned.",
      data: result,
    });
  } catch (err: any) {
    res.status(400).json({ success: false, message: err.message });
  }
};

// ─────────────────────────────────────────────────────────────
// POST /users/me/subscribe/:trainerId
// ─────────────────────────────────────────────────────────────

import { subscribeToTrainer as subscribeToTrainerService } from "./user.service";

export const subscribeToTrainer = async (
  req: Request,
  res: Response,
): Promise<void> => {
  try {
    const userId = (req.user as JwtPayloadWithUser).id;
    const user = await subscribeToTrainerService(userId, req.params.trainerId);
    res.json({ success: true, message: "Subscribed successfully", data: user });
  } catch (err: any) {
    res.status(400).json({ success: false, message: err.message });
  }
};

// ─────────────────────────────────────────────────────────────
// GET /users/me/history
// ─────────────────────────────────────────────────────────────

export const getHistory = async (
  req: Request,
  res: Response,
): Promise<void> => {
  try {
    const userId = (req.user as JwtPayloadWithUser).id;
    const limit = parseInt(req.query.limit as string) || 10;
    const history = await getUserWorkoutHistory(userId, limit);
    res.json({ success: true, data: history });
  } catch (err: any) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// ─────────────────────────────────────────────────────────────
// GET /users/me/memory/:trainerId
// ─────────────────────────────────────────────────────────────

export const getMemory = async (req: Request, res: Response): Promise<void> => {
  try {
    const user = req.user as JwtPayloadWithUser;
    const userId = user.id;

    const memory = await getUserMemory(userId, req.params.trainerId);
    res.json({ success: true, data: memory });
  } catch (err: any) {
    res.status(404).json({ success: false, message: err.message });
  }
};

export const getProfileInfo = async (req: Request, res: Response) => {
  const user = req.user as JwtPayloadWithUser;
  const userId = user.id;

  if (user.role === "customer") {
    const getCustomerInfo = await UserModel.findOne({ _id: userId });

    return sendResponse(res, {
      statusCode: 200,
      success: true,
      message: "User information retrieved successfully",
      data: getCustomerInfo,
    });
  } else if (user.role === "barber") {
    const getBarberInfo = await UserModel.aggregate([
      {
        $match: {
          _id: new mongoose.Types.ObjectId(userId),
        },
      },
      {
        $lookup: {
          from: "barbers",
          localField: "_id",
          foreignField: "userId",
          as: "barberInfo",
        },
      },
      { $unwind: { path: "$barberInfo", preserveNullAndEmptyArrays: true } },

      // Merge both documents (barber first so it overwrites user fields)
      {
        $replaceRoot: {
          newRoot: { $mergeObjects: ["$barberInfo", "$$ROOT"] },
        },
      },

      // Rename _id (barber's) → barberId and rename original userId
      {
        $addFields: {
          barberId: "$barberInfo._id",
          userId: "$barberInfo.userId",
        },
      },

      // Remove unnecessary fields
      {
        $project: {
          _id: 0,
          barberInfo: 0,
          password: 0,
          __v: 0,
        },
      },
    ]);

    return sendResponse(res, {
      statusCode: 200,
      success: true,
      message: "User information retrieved successfully",
      data: getBarberInfo[0],
    });
  }
};

// export const deviceLoginUser = catchAsync(
//   async (req: Request, res: Response) => {
//     const { deviceId, fcmToken } = req.body;
//     const user = await UserModel.findOne({ deviceId });
//     if (!user) {
//       throw new ApiError(401, "This account does not exist.");
//     }
//     const userId = user._id as string;

//     // If user is not verified, send OTP and return a verification token
//     const verifyToken = generateToken({
//       id: userId,
//       phone: user.phone,
//       role: user.role,
//       isLogin: user.isLogin,
//     });

//     // if (!user.isVerified) {
//     //   const name = user.name as string;
//     //   const otp = generateOTP();
//     //   // Fire-and-forget email/phone OTP send, but persist OTP
//     //   sendOTPEmailVerification(name, user.phone, otp).catch((err) =>
//     //     console.error("Error sending OTP email:", err)
//     //   );
//     //   await saveOTP(user.phone, otp);

//     //   return sendResponse(res, {
//     //     statusCode: 401,
//     //     success: false,
//     //     message: "We've sent an OTP to your phone to verify your profile.",
//     //     data: {
//     //       role: user.role,
//     //       token: verifyToken,
//     //     },
//     //   });
//     // }

//     // Mark user as logged in
//     const updateLogin = await UserModel.findByIdAndUpdate(
//       user._id,
//       { isLogin: true },
//       { new: true, upsert: true }
//     );

//     const token = generateToken({
//       id: userId,
//       phone: user.phone,
//       role: user.role,
//       isLogin: updateLogin.isLogin,
//     });

//     // Update fcmToken if provided
//     if (fcmToken) {
//       user.fcmToken = fcmToken;
//       await user.save();
//     }

//     return sendResponse(res, {
//       statusCode: httpStatus.OK,
//       success: true,
//       message: "Login complete!",
//       data: {
//         user: {
//           _id: user._id,
//           name: user?.name,
//           email: user?.email,
//           phone: user?.phone,
//           image: user?.image || "",
//           role: user?.role,
//           isLogin: updateLogin.isLogin,
//         },
//         token,
//       },
//     });
//   }
// );

const updateFcmToken = async (req: any, res: any) => {
  try {
    const userId = req.user?.id || req.user?._id;
    const { fcmToken, previousFcmToken } = req.body;
    if (fcmToken === null && typeof previousFcmToken === "string" && previousFcmToken.length <= 4096) {
      await UserModel.updateOne({ _id: userId, fcmToken: previousFcmToken }, { $unset: { fcmToken: 1 } });
    } else if (typeof fcmToken === "string" && fcmToken.length > 0 && fcmToken.length <= 4096) {
      // A device reused by another account must not retain the previous recipient.
      await UserModel.updateMany({ _id: { $ne: userId }, fcmToken }, { $unset: { fcmToken: 1 } });
      await UserModel.findByIdAndUpdate(userId, { fcmToken });
    } else {
      res.status(400).json({ success: false, message: "Valid fcmToken required" });
      return;
    }
    res.json({ success: true, message: "FCM token updated" });
  } catch (err: any) {
    res.status(500).json({ success: false, message: err.message });
  }
};

const UserController = {
  registerUser,
  resendOTP,
  verifyOTP,
  getAllUsers,
  updateFcmToken,

  // updateAdminInformation,
  // // updateAdminPassword,
  // getAdminInfo,
  // updateUserStatus,
  // searchCustomer,
  // getAdminProfile,
  // getAllSubadmin,
  // addDeviceId,
  // // deviceLoginUser,
};

export { UserController };
