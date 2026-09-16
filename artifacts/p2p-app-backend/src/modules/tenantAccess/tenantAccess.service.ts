import bcrypt from "bcryptjs";
import crypto from "crypto";
import httpStatus from "http-status";
import ApiError from "../../errors/ApiError";
import {
  TenantAccessModel,
  TENANT_ROLES,
  TenantRole,
} from "./tenantAccess.model";

export const INITIAL_LIVE_TENANTS = [
  { tenantId: "kmf-fitness", displayName: "KMF Fitness" },
  { tenantId: "ymca-yonkers", displayName: "YMCA Yonkers" },
] as const;

export const normalizeTenantSlug = (value: unknown): string | undefined => {
  if (typeof value !== "string") return undefined;
  const normalized = value.trim().toLowerCase();
  return /^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(normalized) ? normalized : undefined;
};

/**
 * TenantAccess is the source of truth for which syntactically valid tenant
 * identifiers may be used.  Keeping this lookup here prevents callers from
 * accidentally treating the historical signup list as the tenant registry.
 */
export const findLiveTenant = async (value: unknown) => {
  const tenantId = normalizeTenantSlug(value);
  if (!tenantId) return null;
  await ensureInitialTenants();
  return TenantAccessModel.findOne({ tenantId, isLive: true, $or: [{ accessExpiresAt: { $exists: false } }, { accessExpiresAt: { $gt: new Date() } }] })
    .select("_id tenantId displayName isLive")
    .lean();
};

export const requireLiveTenant = async (value: unknown) => {
  const tenantId = normalizeTenantSlug(value);
  if (!tenantId) {
    throw new ApiError(httpStatus.BAD_REQUEST, "Invalid Gym identifier.");
  }
  const tenant = await findLiveTenant(tenantId);
  if (!tenant) {
    throw new ApiError(httpStatus.BAD_REQUEST, "This Gym is not live.");
  }
  return tenant;
};

export const normalizeTenantRole = (value: unknown): TenantRole | undefined => {
  if (typeof value !== "string") return undefined;
  const normalized = value
    .trim()
    .toLowerCase()
    .replace(/[\s/_-]+/g, "");
  const aliases: Record<string, TenantRole> = {
    member: "member",
    user: "member",
    trainer: "trainer",
    staff: "staff",
    gymstaff: "staff",
    admin: "admin",
    gymadmin: "admin",
    owner: "owner",
    partner: "owner",
    gympartner: "owner",
  };
  return aliases[normalized];
};

export const platformRoleForTenantRole = (
  role: TenantRole,
): "user" | "trainer" => (role === "trainer" ? "trainer" : "user");

export const tenantRoleHasAdminAccess = (role: TenantRole): boolean =>
  role === "staff" || role === "admin" || role === "owner";

const ensureInitialTenants = async () => {
  await Promise.all(
    INITIAL_LIVE_TENANTS.map((tenant) =>
      TenantAccessModel.updateOne(
        { tenantId: tenant.tenantId },
        { $setOnInsert: { ...tenant, isLive: true } },
        { upsert: true },
      ),
    ),
  );
};

export const listLiveTenants = async () => {
  await ensureInitialTenants();
  return TenantAccessModel.find(
    { isLive: true },
    { _id: 0, tenantId: 1, displayName: 1 },
  )
    .sort({ displayName: 1 })
    .lean();
};

export const validateTenantRoleCode = async ({
  tenantId,
  tenantRole,
  accessCode,
}: {
  tenantId: string;
  tenantRole: TenantRole;
  accessCode: unknown;
}) => {
  await ensureInitialTenants();
  const normalizedTenantId = normalizeTenantSlug(tenantId);
  if (!normalizedTenantId) {
    throw new ApiError(httpStatus.FORBIDDEN, "Unsupported tenant.");
  }
  if (typeof accessCode !== "string" || accessCode.trim().length < 6) {
    throw new ApiError(
      httpStatus.FORBIDDEN,
      "A valid professional access code is required.",
    );
  }
  const tenant = await TenantAccessModel.findOne({
    tenantId: normalizedTenantId,
    isLive: true,
    "roleCodes.role": tenantRole,
    "roleCodes.active": true,
  }).select("+roleCodes.codeHash");
  const roleCode = tenant?.roleCodes.find(
    (entry: any) => entry.role === tenantRole && entry.active,
  );
  if (!tenant || !roleCode) {
    throw new ApiError(
      httpStatus.FORBIDDEN,
      "This Gym role is not open for onboarding yet.",
    );
  }
  const valid = await bcrypt.compare(accessCode.trim(), roleCode.codeHash);
  if (!valid) {
    throw new ApiError(
      httpStatus.FORBIDDEN,
      "The professional access code does not match this Gym and role.",
    );
  }
};

export const rotateTenantRoleCode = async ({
  tenantId,
  displayName,
  tenantRole,
  actorId,
}: {
  tenantId: string;
  displayName?: string;
  tenantRole: TenantRole;
  actorId?: string;
}) => {
  const normalizedTenantId = normalizeTenantSlug(tenantId);
  if (!normalizedTenantId) {
    throw new ApiError(httpStatus.BAD_REQUEST, "Invalid Gym identifier.");
  }
  const code = `P2P-${tenantRole.toUpperCase()}-${crypto
    .randomBytes(6)
    .toString("base64url")
    .toUpperCase()}`;
  const codeHash = await bcrypt.hash(code, 12);
  const tenant = await TenantAccessModel.findOneAndUpdate(
    { tenantId: normalizedTenantId },
    {
      $set: {
        displayName: displayName?.trim() || normalizedTenantId,
        isLive: true,
        updatedBy: actorId,
      },
      $pull: { roleCodes: { role: tenantRole } },
    },
    { upsert: true, new: true },
  );
  tenant.roleCodes.push({
    role: tenantRole,
    codeHash,
    active: true,
    rotatedAt: new Date(),
  } as any);
  await tenant.save();
  return { tenantId: normalizedTenantId, tenantRole, code };
};

export const getTenantRoleCodeStatus = async (tenantId: string) => {
  const tenant = await TenantAccessModel.findOne({ tenantId }).lean();
  if (!tenant) throw new ApiError(httpStatus.NOT_FOUND, "Gym not found.");
  return {
    tenantId: tenant.tenantId,
    displayName: tenant.displayName,
    isLive: tenant.isLive,
    roles: TENANT_ROLES.map((role) => ({
      role,
      configured: tenant.roleCodes.some(
        (entry: any) => entry.role === role && entry.active,
      ),
    })),
  };
};
