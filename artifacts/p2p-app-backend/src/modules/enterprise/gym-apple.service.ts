import {randomUUID} from 'crypto';
import {GymClaim} from './enterprise.model';
import {UserModel} from '../user/user.model';
import {TenantAccessModel} from '../tenantAccess/tenantAccess.model';
import {verifyAppleTransaction,verifyAppleTransactionById,VerifiedAppleTransaction} from '../iap/apple-verifier.service';
export const GYM_APPLE_PRODUCTS = {starter:'p2p_gym_starter_monthly',pro:'p2p_gym_pro_monthly'} as const;
export function validateGymTransaction(claim:any,tx:VerifiedAppleTransaction) {
  if (tx.productId !== GYM_APPLE_PRODUCTS[claim.tier as keyof typeof GYM_APPLE_PRODUCTS] ||
      !claim.appleAccountToken || tx.appAccountToken?.toLowerCase() !== claim.appleAccountToken.toLowerCase() ||
      (claim.appleOriginalTransactionId && claim.appleOriginalTransactionId !== tx.originalTransactionId) ||
      tx.expiresDate <= new Date()) throw new Error('Apple subscription does not match this gym or is expired');
}
async function ownerClaim(userId:string,id:string) {
  const user:any=await UserModel.findOne({_id:userId,isVerified:true,isDeleted:{$ne:true}}).lean();
  const claim:any=await GymClaim.findOne({_id:id,ownerUserId:userId,ownershipVerifiedAt:{$ne:null},status:{$in:['pending_review','approved']}});
  if(!user||!claim)throw new Error('Verified gym ownership is required before subscribing');
  return claim;
}
export async function prepareGymApplePurchase(userId:string,id:string) {
  if(!process.env.APPLE_IAP_ISSUER_ID||!process.env.APPLE_IAP_KEY_ID||!process.env.APPLE_IAP_PRIVATE_KEY)
    throw new Error('Apple subscriptions are not available yet');
  let claim=await ownerClaim(userId,id);
  if(!claim.appleAccountToken) {
    await GymClaim.updateOne({_id:id,appleAccountToken:{$exists:false}},{$set:{appleAccountToken:randomUUID()}});
    claim=await ownerClaim(userId,id);
  }
  return {productId:GYM_APPLE_PRODUCTS[claim.tier as keyof typeof GYM_APPLE_PRODUCTS],appAccountToken:claim.appleAccountToken};
}
export async function verifyGymApplePurchase(userId:string,id:string,body:any) {
  const claim=await ownerClaim(userId,id);
  if(typeof body.purchaseId!=='string'||typeof body.verificationData!=='string')throw new Error('Missing Apple purchase');
  const expected=GYM_APPLE_PRODUCTS[claim.tier as keyof typeof GYM_APPLE_PRODUCTS];
  const tx=await verifyAppleTransaction(body.verificationData,body.purchaseId,expected);
  validateGymTransaction(claim,tx);
  const session=await GymClaim.startSession();
  try { await session.withTransaction(async()=>{
    const current:any=await GymClaim.findOne({_id:id,ownerUserId:userId,status:{$in:['pending_review','approved']},ownershipVerifiedAt:{$ne:null}}).session(session);
    if(!current)throw new Error('Gym ownership changed');
    validateGymTransaction(current,tx);
    if(current.appleTransactionId && current.paymentExpiresAt > tx.expiresDate)return;
    current.appleOriginalTransactionId=tx.originalTransactionId;
    current.appleTransactionId=tx.transactionId;current.appleProductId=tx.productId;
    current.sourcePurchaseId='apple:'+tx.originalTransactionId;
    current.paymentStatus='paid';current.paymentExpiresAt=tx.expiresDate;
    await current.save({session});
    if(current.status==='approved'&&current.tenantId)await TenantAccessModel.updateOne({tenantId:current.tenantId,isLive:true},{$set:{accessExpiresAt:tx.expiresDate}},{session});
  }); } finally {await session.endSession();}
  return {verified:true,applicationId:id,expiresAt:tx.expiresDate};
}
// Check Apple on protected access: refunds/revocations cannot rely on a stale paid flag.
export async function assertGymAppleEntitlement(tenantId:string) {
  const claim:any=await GymClaim.findOne({tenantId,appleTransactionId:{$exists:true}}).lean();
  if(!claim)return;
  const tx=await verifyAppleTransactionById(claim.appleTransactionId,claim.appleProductId);
  validateGymTransaction(claim,tx);
}
