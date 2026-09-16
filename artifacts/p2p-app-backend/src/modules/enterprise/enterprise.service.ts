import { UserModel } from '../user/user.model';
import { TenantAccessModel } from '../tenantAccess/tenantAccess.model';
import { findLiveTenant } from '../tenantAccess/tenantAccess.service';
import { normalizeEquipment } from '../workoutGoal/workoutEquipment';
import { Facility, GymClaim } from './enterprise.model';
import { canUseFacility, requireApproval } from './enterprise.policy';

export async function facilityInventory(userId: string, facilityId: string) {
  const [user, facility] = await Promise.all([
    UserModel.findById(userId).lean(), Facility.findOne({ facilityId }).lean(),
  ]);
  if (!canUseFacility(user, facility) || !await findLiveTenant((facility as any).tenantId)) {
    throw new Error('Facility access denied');
  }
  return facility as any;
}
export async function approveClaim(id: string, actorId: string) {
  const session = await GymClaim.startSession();
  let result: any;
  try {
    await session.withTransaction(async () => {
      const claim = await GymClaim.findById(id).session(session);
      if (!claim) throw new Error('Claim not found');
      if (claim.status === 'approved') { result = claim; return; }
      requireApproval(claim);
      const owner = await UserModel.findOne({ _id: claim.ownerUserId, email: claim.workEmail,
        isVerified: true, isDeleted: { $ne: true } }).session(session);
      if (!owner) throw new Error('Verified owner account is unavailable');
      if (owner.role === 'admin') throw new Error('Use a separate gym-owner account, not a global administrator');
      const tenantId = `gym-${claim._id}`;
      const facilityId = `${tenantId}-main`;
      await TenantAccessModel.updateOne({ tenantId }, { $set: {
        displayName: claim.gymName, isLive: true, accessExpiresAt: claim.paymentExpiresAt, updatedBy: actorId,
      } }, { upsert: true, session });
      await Facility.updateOne({ facilityId }, { $setOnInsert: { facilityId, tenantId, name: claim.gymName, equipment: [] },
        $set: { active: true } }, { upsert: true, session });
      // Keep the platform role unchanged; owner authority is scoped to this tenant.
      await UserModel.updateOne({ _id: owner._id }, { $addToSet: { gymAdminTenantIds: tenantId } }, { session });
      claim.tenantId = tenantId; claim.facilityId = facilityId; claim.status = 'approved';
      claim.approvedBy = actorId; claim.approvedAt = new Date();
      await claim.save({ session }); result = claim;
    });
    return result;
  } finally { await session.endSession(); }
}
export async function deactivateClaim(id: string, status: 'rejected'|'revoked', reason: string) {
  if (typeof reason !== 'string' || !reason.trim() || reason.length > 2000) throw new Error('A reason is required');
  const session = await GymClaim.startSession();
  try {
    await session.withTransaction(async () => {
      const claim = await GymClaim.findById(id).session(session);
      if (!claim) throw new Error('Claim not found');
      if (status === 'rejected' && claim.status !== 'pending_review') throw new Error('Only pending claims can be rejected');
      claim.status = status; claim.reason = reason.trim(); await claim.save({ session });
      if (claim.tenantId) {
        await TenantAccessModel.updateOne({ tenantId: claim.tenantId }, { $set: { isLive: false } }, { session });
        await Facility.updateMany({ tenantId: claim.tenantId }, { $set: { active: false } }, { session });
        await UserModel.updateMany({ gymAdminTenantIds: claim.tenantId }, { $pull: { gymAdminTenantIds: claim.tenantId } }, { session });
      }
    });
  } finally { await session.endSession(); }
}
export async function setInventory(userId: string, facilityId: string, equipment: unknown) {
  const facility = await facilityInventory(userId, facilityId);
  const user: any = await UserModel.findById(userId).lean();
  if (!user.gymAdminTenantIds?.includes(facility.tenantId)) throw new Error('Facility administrator access required');
  return Facility.findOneAndUpdate({ facilityId, active: true }, {
    $set: { equipment: normalizeEquipment(equipment), updatedBy: userId }, $inc: { inventoryVersion: 1 },
  }, { new: true, runValidators: true });
}
