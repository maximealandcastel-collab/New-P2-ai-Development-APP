export function requireApproval(claim: any, now = new Date()) {
  if (claim.status !== 'pending_review' || !claim.ownershipVerifiedAt || !claim.ownerUserId ||
      claim.paymentStatus !== 'paid' || !claim.paymentExpiresAt || new Date(claim.paymentExpiresAt) <= now) {
    throw new Error('Verified ownership and a current paid license are required before approval');
  }
}
export function canUseFacility(user: any, facility: any) {
  return !!user && user.isDeleted !== true && user.isVerified === true && facility?.active === true &&
    (user.tenantId === facility.tenantId || (user.gymAdminTenantIds || []).includes(facility.tenantId));
}
export function integerCents(value: unknown) {
  if (typeof value !== 'number' || !Number.isSafeInteger(value) || value <= 0) throw new Error('Amount must be positive integer cents');
  return value;
}
