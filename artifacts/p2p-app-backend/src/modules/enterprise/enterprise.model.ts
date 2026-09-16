import mongoose, { Schema } from 'mongoose';
const claim = new Schema({
  gymName: { type: String, required: true }, workEmail: { type: String, required: true, lowercase: true },
  representativeName: String, tier: { type: String, enum: ['starter','pro'], required: true },
  city: String, state: String, logoUrl: String, primaryColor: String, secondaryColor: String,
  status: { type: String, enum: ['pending_review','approved','rejected','revoked'], default: 'pending_review', index: true },
  ownershipVerifiedAt: Date, ownershipEvidence: String, ownershipVerifiedBy: Schema.Types.ObjectId,
  ownerUserId: { type: Schema.Types.ObjectId, ref: 'User' },
  paymentStatus: String, paymentExpiresAt: Date,
  appleAccountToken: {type:String,unique:true,sparse:true},
  appleOriginalTransactionId: {type:String,unique:true,sparse:true},
  appleTransactionId: String, appleProductId: String,
  sourcePurchaseId: { type: String, unique: true, sparse: true },
  tenantId: { type: String, unique: true, sparse: true }, facilityId: String,
  provisioningState: {type:String,enum:['pending','provisioning','active','failed'],default:'pending'}, provisioningFailure:String,
  approvedBy: Schema.Types.ObjectId, approvedAt: Date, reason: String,
}, { timestamps: true });
claim.index({ workEmail: 1, gymName: 1, status: 1 });
claim.index({ workEmail: 1, gymName: 1 }, { unique: true, partialFilterExpression: { status: "pending_review" } });
const facility = new Schema({
  facilityId: { type: String, required: true, unique: true }, tenantId: { type: String, required: true, index: true },
  name: String, active: { type: Boolean, default: false }, equipment: { type: [String], default: [] },
  inventoryVersion: { type: Number, default: 0 }, updatedBy: Schema.Types.ObjectId,
}, { timestamps: true });
const payment = new Schema({
  sourcePurchaseId: { type: String, required: true, unique: true },
  plan: String, amountCents: Number, email: String, applicationId: String,
  status: { type: String, enum: ['paid','refunded'] }, expiresAt: Date,
  promoCode: String,
}, { timestamps: true });
export const GymClaim = mongoose.models.GymClaim || mongoose.model('GymClaim', claim);
export const Facility = mongoose.models.Facility || mongoose.model('Facility', facility);
export const WebPayment = mongoose.models.WebPayment || mongoose.model('WebPayment', payment);
