import { deletePersonalAccount } from "../privacy/accountDeletion.service";
import { IUser, TGoal } from "./user.interface";
import "dotenv/config";

import { Twilio } from "twilio";

import { OTPModel, UserModel } from "./user.model";
import crypto from "crypto";
import ApiError from "../../errors/ApiError";

import {
  findUserByEmail,
  generateOTP,
  hashPassword,
  OTP_EXPIRATION_MS,
  OTP_MAX_FAILED_ATTEMPTS,
} from "./user.utils";

import httpStatus from "http-status";
import { generateToken, verifyToken } from "../../utils/JwtToken";

import { TRole } from "../../config/role";
import paginationBuilder from "../../utils/paginationBuilder";
import mongoose, { Types } from "mongoose";
import {
  twilioAccountSid,
  twilioAuthToken,
  twilioPhoneNumber,
} from "../../config";

import { JwtPayloadWithUser } from "../../middlewares/userVerification";
import { TrainerModel } from "../trainer/trainer.model";
import { assignBuiltInTrainerOnboarding } from "../trainer/trainer.service";
import {
  normalizeTenantRole,
  normalizeTenantSlug,
  platformRoleForTenantRole,
  tenantRoleHasAdminAccess,
  validateTenantRoleCode,
} from "../tenantAccess/tenantAccess.service";

export const registerUserService = async (data: any) => {
  const {
    firstName,
    lastName,
    email,
    dateOfBirth,
    password,
    gender,
    bio,
    role,
    fcmToken,
    tenantId: requestedTenantId,
    tenantRole: requestedTenantRole,
    accessCode,
  } = data.body;

  const emailNormalized = typeof email === "string" ? email.trim().toLowerCase() : email;
  const tenantId = normalizeTenantSlug(requestedTenantId);
  if (requestedTenantId !== undefined && !tenantId) {
    throw new ApiError(httpStatus.BAD_REQUEST, "Unsupported tenant.");
  }
  const tenantRole = tenantId
    ? normalizeTenantRole(requestedTenantRole)
    : undefined;
  if (tenantId && !tenantRole) {
    throw new ApiError(httpStatus.BAD_REQUEST, "Choose a valid Gym role.");
  }
  if (tenantId && tenantRole) {
    await validateTenantRoleCode({ tenantId, tenantRole, accessCode });
  }
  const start = Date.now();
  const session = await mongoose.startSession();
  // Check if user already exists
  const existingUser = await UserModel.findOne({ email: emailNormalized });

  if (existingUser) {
    // If the account exists but was never verified, wipe it so they can start fresh
    if (!existingUser.isVerified) {
      await UserModel.deleteOne({ email: emailNormalized });
      await OTPModel.deleteMany({ email: emailNormalized });
    } else {
      throw new ApiError(400, "User already exist");
    }
  }
  if (!password || typeof password !== "string") {
    throw new ApiError(httpStatus.BAD_REQUEST, "Password is required.");
  }
  const hashedPassword = await hashPassword(password);

  const userPayload: any = {
    firstName,
    lastName,
    email: emailNormalized,
    dateOfBirth,
    gender,
    password: hashedPassword,
    bio,
    role: tenantRole ? platformRoleForTenantRole(tenantRole) : role,
    isVerified: false,
    fcmToken,
  };
  if (tenantId && tenantRole) {
    userPayload.tenantId = tenantId;
    userPayload.tenantRole = tenantRole;
    if (tenantRoleHasAdminAccess(tenantRole)) {
      userPayload.gymAdminTenantIds = [tenantId];
    }
  }

  if (data.file) {
    userPayload.profilePicture = `/images/${data.file.filename}`;
  }
  // Create new user
  const newUser = await UserModel.create(userPayload);

  // Generate and store OTP (optional if you’re using OTP verification)
  const otp = generateOTP();
  await OTPModel.create({
    email: emailNormalized,
    otp,
    expiresAt: new Date(Date.now() + OTP_EXPIRATION_MS),
    sentAt: new Date(),
  });

  const end = Date.now();
    // Keep operational timing free of registration data.

  //  Keep the return identical to your previous version
  return {
    success: true,
    statusCode: 200,
    message: "User registered successfully. Please verify your email address.",
    data: {
      user: newUser,
      otp,
    },
  };
};

/**
 * Creates a new user in the database.
 */

const createUser = async ({
  name,
  hashedPassword,
  phone,
  longitude,
  latitude,
  image,
  fcmToken,
  role,
  touchId,
  faceId,
}: {
  name: string;
  hashedPassword: string | null;
  phone: number;
  longitude: number;
  latitude: number;
  image: string;
  fcmToken: string;
  role: TRole;
  touchId?: string;
  faceId?: string;
}): Promise<{ createdUser: IUser }> => {
  try {
    const createdUser = await UserModel.create({
      name,
      password: hashedPassword,
      phone,
      longitude,
      latitude,
      image,
      fcmToken,
      role,
      touchId,
      faceId,
    });

    return { createdUser };
  } catch (error) {
    console.error("User creation failed:", error);
    throw new ApiError(500, "User creation failed");
  }
};

/**
 * Updates a user by ID.
 */
const updateUserById = async (
  id: string,
  updateData: Partial<IUser>,
): Promise<IUser | null> => {
  return UserModel.findByIdAndUpdate(
    id,
    { $set: updateData },
    {
      new: true,
      runValidators: true,
    },
  );
};

/**
 * Soft-deletes a user and anonymizes their email.
 */
const userDelete = async (id: string, _email: string): Promise<void> => {
  await deletePersonalAccount(id);
};

/**
 * Verifies OTP for forgot password flow and returns a new token if valid.
 */
const recordFailedOtpAttempt = async (email: string, now: Date) => {
  const updated = await OTPModel.findOneAndUpdate(
    {
      email,
      expiresAt: { $gt: now },
      consumedAt: { $exists: false },
      verifiedAt: { $exists: false },
      lockedUntil: { $exists: false },
      failedAttempts: { $lt: OTP_MAX_FAILED_ATTEMPTS },
    },
    { $inc: { failedAttempts: 1 } },
    { new: true },
  );
  if (updated && (updated.failedAttempts || 0) >= OTP_MAX_FAILED_ATTEMPTS) {
    await OTPModel.updateOne(
      { _id: updated._id, lockedUntil: { $exists: false } },
      { $set: { lockedUntil: new Date(now.getTime() + OTP_EXPIRATION_MS) } },
    );
  }
};

const verifyForgotPasswordOTPService = async (email: string, otp: string) => {
  const user = await findUserByEmail(email);
  if (!user) {
    throw new ApiError(httpStatus.NOT_FOUND, "User not found!");
  }
  const now = new Date();
  const otpRecord = await OTPModel.findOneAndUpdate(
    {
      email,
      otp: String(otp).trim(),
      expiresAt: { $gt: now },
      consumedAt: { $exists: false },
      verifiedAt: { $exists: false },
      lockedUntil: { $exists: false },
      purpose: "password_reset",
      failedAttempts: { $lt: OTP_MAX_FAILED_ATTEMPTS },
    },
    { $set: { verifiedAt: now } },
    { new: true },
  );
  if (!otpRecord) {
    await recordFailedOtpAttempt(email, now);
    throw new ApiError(httpStatus.BAD_REQUEST, "Invalid or expired OTP");
  }
  // This is an opaque, purpose-bound reset authorization, not a login token.
  // Store only a digest so a database read cannot be used to reset a password.
  const resetToken = crypto.randomBytes(32).toString("hex");
  const resetTokenHash = crypto.createHash("sha256").update(resetToken).digest("hex");
  const stored = await OTPModel.findOneAndUpdate(
    { _id: otpRecord._id, verifiedAt: { $exists: true }, consumedAt: { $exists: false } },
    { $set: { resetTokenHash, resetTokenExpiresAt: new Date(now.getTime() + 10 * 60 * 1000) } },
    { new: true },
  );
  if (!stored) throw new ApiError(httpStatus.BAD_REQUEST, "Reset challenge is no longer valid");
  return { token: resetToken, name: user.firstName, email: user.email };
};

export const consumePasswordReset = async (resetToken: string, password: string) => {
  if (!resetToken || !password) throw new ApiError(httpStatus.BAD_REQUEST, "Reset token and password are required");
  const hash = crypto.createHash("sha256").update(resetToken).digest("hex");
  const now = new Date();
  // The conditional update is the single-use gate. Concurrent requests can only
  // claim this authorization once.
  const pending = await OTPModel.findOne({
    purpose: "password_reset",
    resetTokenHash: hash,
    resetTokenExpiresAt: { $gt: now },
    verifiedAt: { $exists: true },
    consumedAt: { $exists: false },
  }).select("+resetTokenHash");
  if (!pending) throw new ApiError(httpStatus.UNAUTHORIZED, "Invalid, expired, or already-used reset token");
  const user = await findUserByEmail(pending.email);
  if (!user) throw new ApiError(httpStatus.NOT_FOUND, "User not found");
  const newPassword = await hashPassword(password);
  const challenge = await OTPModel.findOneAndUpdate(
    {
      purpose: "password_reset",
      resetTokenHash: hash,
      resetTokenExpiresAt: { $gt: now },
      verifiedAt: { $exists: true },
      consumedAt: { $exists: false },
    },
    { $set: { consumedAt: now }, $unset: { resetTokenHash: 1 } },
    { new: true },
  );
  if (!challenge) throw new ApiError(httpStatus.UNAUTHORIZED, "Invalid, expired, or already-used reset token");
  user.password = newPassword;
  await user.save();
  return user;
};

/**
 * Gets a paginated list of admin users.
 */
const getAdminList = async (
  skip: number,
  limit: number,
  name?: string,
): Promise<{
  admins: IUser[];
  pagination: ReturnType<typeof paginationBuilder>;
}> => {
  const query: any = {
    isDeleted: { $ne: true },
    role: { $in: ["primary", "secondary", "junior"] },
  };
  if (name) {
    query.name = { $regex: name, $options: "i" };
  }
  const pipeline: any[] = [
    { $match: query },
    { $sort: { createdAt: -1 } },
    { $skip: skip },
    { $limit: limit },
    {
      $project: {
        image: 1,
        name: 1,
        role: 1,
        email: 1,
        createdAt: 1,
        phone: 1,
        address: 1,
        _id: 1,
      },
    },
  ];
  const admins = await UserModel.aggregate(pipeline);
  const totalAdmins = await UserModel.countDocuments(query);
  const currentPage = Math.floor(skip / limit) + 1;
  const pagination = paginationBuilder({
    totalData: totalAdmins,
    currentPage,
    limit,
  });
  return { admins, pagination };
};

/**
 * Gets a paginated list of non-admin users with optional filters.
 */
const getUserList = async (
  skip: number,
  limit: number,
  date?: string,
  name?: string,
  email?: string,
  role?: string,
  requestStatus?: string,
): Promise<{
  users: IUser[];
  pagination: ReturnType<typeof paginationBuilder>;
}> => {
  const query: any = {
    $and: [{ isDeleted: { $ne: true } }, { role: { $nin: ["admin"] } }],
  };
  if (date) {
    const [year, month, day] = date.split("-").map(Number);
    const startDate = new Date(Date.UTC(year, month - 1, day, 0, 0, 0, 0));
    const endDate = new Date(Date.UTC(year, month - 1, day, 23, 59, 59, 999));
    query.createdAt = { $gte: startDate, $lte: endDate };
  }
  if (name) query.name = { $regex: name, $options: "i" };
  if (role) query.role = { $regex: role, $options: "i" };
  if (requestStatus) {
    query.isRequest = { $regex: requestStatus, $options: "i" };
  }
  const pipeline: any[] = [
    { $match: query },
    { $sort: { createdAt: -1 } },
    { $skip: skip },
    { $limit: limit },
    {
      $project: {
        image: 1,
        name: 1,
        email: 1,
        role: 1,
        createdAt: 1,
        phone: 1,
        address: 1,
        isRequest: 1,
        managerInfoId: 1,
        _id: 1,
      },
    },
  ];
  const users = (await UserModel.aggregate(pipeline)) as IUser[];
  const totalUsers = await UserModel.countDocuments(query);
  const currentPage = Math.floor(skip / limit) + 1;
  const pagination = paginationBuilder({
    totalData: totalUsers,
    currentPage,
    limit,
  });
  return { users, pagination };
};

const verifyOTPService = async (otp: string, authorizationHeader: string) => {
  let decoded: JwtPayloadWithUser;

  try {
    decoded = verifyToken(authorizationHeader) as JwtPayloadWithUser;

  } catch (error: any) {
    throw new ApiError(httpStatus.UNAUTHORIZED, "Invalid token");
  }

  const email = decoded.email as string;

  const now = new Date();
  const dbOTP = await OTPModel.findOneAndUpdate(
    {
      email,
      otp: String(otp).trim(),
      expiresAt: { $gt: now },
      consumedAt: { $exists: false },
      verifiedAt: { $exists: false },
      lockedUntil: { $exists: false },
      failedAttempts: { $lt: OTP_MAX_FAILED_ATTEMPTS },
    },
    { $set: { consumedAt: now, verifiedAt: now } },
    { new: true },
  );
  if (!dbOTP) {
    await recordFailedOtpAttempt(email, now);
    throw new ApiError(httpStatus.BAD_REQUEST, "Invalid or expired OTP");
  }

  const user = await UserModel.findOne({ email });
  if (!user) {
    throw new ApiError(httpStatus.NOT_FOUND, "User not found!");
  }

  const token = generateToken({
    id: user._id,
    role: user.role,
    email: user.email,
  });
  return {
    token,
    name: user.firstName,
    email: user.email,
  };
};

// OTP Verification

// Ensure config is properly typed
interface Config {
  twilioAccountSid: string;
  twilioAuthToken: string;
  twilioPhoneNumber: string;
}

const client = new Twilio(twilioAccountSid, twilioAuthToken);

const sendSMS = async (to: string, body: string): Promise<void> => {
  try {
    await client.messages.create({
      body,
      from: twilioPhoneNumber,
      to,
    });
    // logger.info(`SMS sent to ${to}`);
  } catch (error: any) {
    throw error;
  }
};

const sendPhoneVerification = async (
  to: string,
  otp: string,
): Promise<void> => {
  const message = `Your verification code is ${otp}`;
  // Delivery errors must reach the controller; claiming an OTP was sent when
  // Twilio rejected it leaves the user with an unusable challenge.
  await sendSMS(to, message);
};

const sendResetPasswordSMS = async (to: string, otp: number): Promise<void> => {
  const message = `Your password reset code is ${otp}`;
  await sendSMS(to, message);
};

const UserService = {
  registerUserService,
  createUser,
  updateUserById,
  userDelete,
  verifyForgotPasswordOTPService,
  consumePasswordReset,
  getAdminList,
  getUserList,
  verifyOTPService,
  sendPhoneVerification,
  sendResetPasswordSMS,
  sendSMS,
};

// ─────────────────────────────────────────────────────────────
// GET USER PROFILE
// ─────────────────────────────────────────────────────────────

export const getUserProfile = async (userId: string) => {
  return await UserModel.findById(userId)
    .populate(
      "subscribedTrainer",
      "name specialty certifications profileImage trainingStyleTags",
    )
    .select("-password")
    .lean();
};

// ─────────────────────────────────────────────────────────────
// UPDATE USER PROFILE
// ─────────────────────────────────────────────────────────────

const PROFILE_UPDATE_FIELDS = [
  "firstName",
  "lastName",
  "dateOfBirth",
  "gender",
  "profilePicture",
  "coverPhoto",
  "bio",
  "fcmToken",
  "phone",
  "height",
  "weight",
  "fitnessLevel",
  "injuries",
  "availableEquipment",
  "trainingDaysPerWeek",
  "primaryGoal",
] as const;

export const sanitizeUserProfileUpdates = (
  updates: Partial<IUser>,
): Partial<IUser> =>
  Object.fromEntries(
    PROFILE_UPDATE_FIELDS
      .filter((field) => Object.prototype.hasOwnProperty.call(updates, field))
      .map((field) => [field, updates[field]]),
  ) as Partial<IUser>;

export const updateUserProfile = async (
  userId: string,
  updates: Partial<IUser>,
) => {
  const safeUpdates = sanitizeUserProfileUpdates(updates);

  return await UserModel.findByIdAndUpdate(
    userId,
    { $set: safeUpdates },
    { new: true },
  ).select("-password");
};

// ─────────────────────────────────────────────────────────────
// COMPLETE ONBOARDING
// Auto-assigns trainer based on user's primary goal
// ─────────────────────────────────────────────────────────────

export const completeOnboarding = async (
  userId: string,
  data: {
    primaryGoal: TGoal;
    gender?: string;
    dateOfBirth?: string;
    height?: number;
    weight?: number;
    fitnessLevel?: string;
    availableEquipment?: string;
    trainingDaysPerWeek?: number;
    injuries?: string[];
    preferredName?: string;
    motivationStyle?: string;
    preferences?: string;
    preferredTrainerId?: string;
  },
) => {
  const user = await UserModel.findByIdAndUpdate(
    userId,
    {
      $set: {
        primaryGoal: data.primaryGoal,
        gender: data.gender,
        dateOfBirth: data.dateOfBirth,
        height: data.height,
        weight: data.weight,
        fitnessLevel: data.fitnessLevel,
        availableEquipment: data.availableEquipment,
        trainingDaysPerWeek: data.trainingDaysPerWeek,
        injuries: data.injuries || [],
        onboardingCompleted: true,
      },
    },
    { new: true },
  ).select("-password");

  if (!user) throw new Error("User not found");

  const assignedTrainer = await assignBuiltInTrainerOnboarding(
    userId,
    data.primaryGoal,
    {
      preferredTrainerId: data.preferredTrainerId,
      preferredName: data.preferredName,
      motivationStyle: data.motivationStyle,
      fitnessLevel: data.fitnessLevel,
      availableEquipment: data.availableEquipment,
      trainingDaysPerWeek: data.trainingDaysPerWeek,
      injuries: data.injuries,
    },
  );

  const populatedUser = await UserModel.findById(userId)
    .populate(
      "subscribedTrainer",
      "name specialty certifications profileImage trainingStyleTags slug personaKey",
    )
    .select("-password")
    .lean();

  return { user: populatedUser, assignedTrainer };
};

// ─────────────────────────────────────────────────────────────
// SUBSCRIBE TO TRAINER
// ─────────────────────────────────────────────────────────────

export const subscribeToTrainer = async (
  userId: string,
  trainerId: string,
  tier: "free" | "paid" | "premium" = "free",
) => {
  const trainer = await TrainerModel.findById(trainerId);
  if (!trainer) throw new Error("Trainer not found");
  if (!trainer.isActive)
    throw new Error("This trainer is not currently active");

  const user = await UserModel.findById(userId);
  if (!user) throw new Error("User not found");

  // Check if memory for this trainer already exists
  const existingMemory = user.getMemoryForTrainer(trainerId);

  const updateData: any = {
    $set: {
      subscribedTrainer: trainerId,
      subscriptionTier: tier,
      subscriptionStartDate: new Date(),
    },
  };

  // Only add new memory entry if one doesn't exist for this trainer
  if (!existingMemory) {
    updateData.$push = {
      memory: {
        trainerId,
        profileMemory: {
          goal: user.primaryGoal,
          experienceLevel: user.fitnessLevel,
          equipment: user.availableEquipment,
          updatedAt: new Date(),
        },
        rollingMemory: {
          last3Sessions: [],
          lastKnownLoads: {},
          flags: [],
          updatedAt: new Date(),
        },
        lastUpdatedAt: new Date(),
      },
    };
  }

  // Increment trainer subscriber count
  await TrainerModel.findByIdAndUpdate(trainerId, {
    $inc: { subscriberCount: 1 },
  });

  return await UserModel.findByIdAndUpdate(userId, updateData, { new: true })
    .select("-password")
    .populate(
      "subscribedTrainer",
      "name specialty certifications profileImage",
    );
};

// ─────────────────────────────────────────────────────────────
// GET USER WORKOUT HISTORY
// ─────────────────────────────────────────────────────────────

export const getUserWorkoutHistory = async (userId: string, limit = 10) => {
  const user = await UserModel.findById(userId).select("workoutHistory").lean();
  if (!user) throw new Error("User not found");
  return user.workoutHistory.slice(-limit).reverse();
};

// ─────────────────────────────────────────────────────────────
// GET USER MEMORY FOR TRAINER
// ─────────────────────────────────────────────────────────────

export const getUserMemory = async (userId: string, trainerId: string) => {
  const user = await UserModel.findById(userId).select("memory").lean();
  if (!user) throw new Error("User not found");

  const memory = user.memory.find(
    (m: any) => m.trainerId.toString() === trainerId,
  );

  if (!memory) throw new Error("No memory found for this trainer");
  return memory;
};

export { UserService };
