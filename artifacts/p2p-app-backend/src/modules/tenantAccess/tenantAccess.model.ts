import { Schema, model } from "mongoose";

export const TENANT_ROLES = [
  "member",
  "trainer",
  "staff",
  "admin",
  "owner",
] as const;

export type TenantRole = (typeof TENANT_ROLES)[number];

const roleCodeSchema = new Schema(
  {
    role: { type: String, enum: TENANT_ROLES, required: true },
    codeHash: { type: String, required: true, select: false },
    active: { type: Boolean, default: true },
    rotatedAt: { type: Date, default: Date.now },
  },
  { _id: false },
);

const tenantAccessSchema = new Schema(
  {
    tenantId: { type: String, required: true, unique: true, index: true },
    displayName: { type: String, required: true },
    accessExpiresAt: { type: Date },
    isLive: { type: Boolean, default: false, index: true },
    roleCodes: { type: [roleCodeSchema], default: [] },
    updatedBy: { type: Schema.Types.ObjectId, ref: "User" },
  },
  { timestamps: true },
);

export const TenantAccessModel = model(
  "TenantAccess",
  tenantAccessSchema,
);