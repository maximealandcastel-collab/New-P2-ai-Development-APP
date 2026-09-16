import { Router, Request, Response, NextFunction } from 'express';
import { createHash, randomBytes, timingSafeEqual } from 'crypto';
import { guardRole } from '../../middlewares/roleGuard';
import { UserModel } from '../user/user.model';
import { TenantAccessModel } from '../tenantAccess/tenantAccess.model';
import { PromoCodeModel } from '../promoCode/promoCode.model';
import { SubscriptionModel } from '../subscription/subscription.model';
import { Facility, GymClaim, WebPayment } from './enterprise.model';
import { approveClaim, deactivateClaim, facilityInventory, setInventory } from './enterprise.service';

export const EnterpriseRoutes = Router();
const route = (fn: (req: Request, res: Response) => Promise<any>) => (req: Request, res: Response, next: NextFunction) => fn(req, res).catch(next);
const send = (res: Response, data: any, status = 200) => res.status(status).json({ success: true, data });
const text = (value: unknown, limit = 200) => typeof value === 'string' && value.trim().length <= limit ? value.trim() : '';
const catalogs: Record<string,{amount:number;days:number;tier?:string}> = {
  trial_access:{amount:499,days:7},three_months:{amount:1999,days:90},annual:{amount:12000,days:365},affiliate:{amount:1000,days:180},
  enterprise_core:{amount:4999,days:30,tier:'starter'},enterprise_elite:{amount:30599,days:30,tier:'pro'},
};
const internal = (req: Request, res: Response, next: NextFunction) => {
  const expected = process.env.APP_BACKEND_SHARED_SECRET;
  const actual = req.get('x-admin-key');
  if (!expected || !actual || !timingSafeEqual(createHash('sha256').update(expected).digest(),createHash('sha256').update(actual).digest())) {
    return res.status(401).json({ success: false, message: 'Unauthorized service' });
  }
  next();
};
EnterpriseRoutes.post('/gym-applications', route(async(req,res) => {
  const b = req.body || {};
  const email = text(b.workEmail,254).toLowerCase();
  if (!text(b.gymName) || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) || !['starter','pro'].includes(b.tier) || b.authorizedRepresentative !== true || b.reviewConsent !== true) {
    return res.status(400).json({ success:false,message:'Gym, representative email, tier and authorization are required' });
  }
  if (b.logoUrl && !/^https:\/\//.test(text(b.logoUrl,2048))) return res.status(400).json({success:false,message:'Logo must use HTTPS'});
  const existing = await GymClaim.findOne({ gymName:text(b.gymName),workEmail:email,status:'pending_review' });
  const claim = existing || await GymClaim.create({ gymName:text(b.gymName),workEmail:email,
    representativeName:text(b.representativeName),tier:b.tier,city:text(b.city),state:text(b.state),logoUrl:text(b.logoUrl,2048),
    primaryColor:/^#[0-9a-f]{6}$/i.test(b.primaryColor || '')?b.primaryColor:undefined,
    secondaryColor:/^#[0-9a-f]{6}$/i.test(b.secondaryColor || '')?b.secondaryColor:undefined,
  });
  return send(res,{applicationId:String(claim._id),status:claim.status},201);
}));
EnterpriseRoutes.get('/admin/gym-applications',guardRole('admin'),route(async(_req,res) => send(res,{items:await GymClaim.find().sort({createdAt:-1}).limit(100).lean()})));
EnterpriseRoutes.post('/admin/gym-applications/:id/verify-ownership',guardRole('admin'),route(async(req,res) => {
  const claim = await GymClaim.findOne({_id:req.params.id,status:'pending_review'});
  if (!claim || !text(req.body.evidence,2000)) return res.status(400).json({success:false,message:'Pending claim and reviewed ownership evidence are required'});
  const owner = await UserModel.findOne({_id:req.body.ownerUserId,email:claim.workEmail,isVerified:true,isDeleted:{$ne:true}});
  if (!owner || owner.role === 'admin') return res.status(400).json({success:false,message:'A verified, non-global-admin owner account matching the claim is required'});
  const updated=await GymClaim.findOneAndUpdate({_id:claim._id,status:'pending_review'},{$set:{ownerUserId:owner._id,
    ownershipVerifiedAt:new Date(),ownershipEvidence:text(req.body.evidence,2000),ownershipVerifiedBy:(req.user as any).id}},{new:true});
  if (!updated) return res.status(409).json({success:false,message:'Claim status changed; reload before reviewing'});
  return send(res,{applicationId:String(claim._id),ownershipVerified:true});
}));
EnterpriseRoutes.post('/admin/gym-applications/:id/approve',guardRole('admin'),route(async(req,res) => send(res,await approveClaim(String(req.params.id),(req.user as any).id))));
for (const action of ['reject','revoke'] as const) EnterpriseRoutes.post(`/admin/gym-applications/:id/${action}`,guardRole('admin'),route(async(req,res) => {
  await deactivateClaim(String(req.params.id),action==='reject'?'rejected':'revoked',req.body.reason);return send(res,{status:action==='reject'?'rejected':'revoked'});
}));
EnterpriseRoutes.get('/facilities',guardRole(['user','trainer']),route(async(req,res) => {
  const user:any=await UserModel.findById((req.user as any).id).lean();
  const tenantIds=[user.tenantId,...(user.gymAdminTenantIds||[])].filter(Boolean);
  const tenants=await TenantAccessModel.find({tenantId:{$in:tenantIds},isLive:true,$or:[{accessExpiresAt:{$exists:false}},{accessExpiresAt:{$gt:new Date()}}]}).lean();
  return send(res,{items:await Facility.find({tenantId:{$in:tenants.map(t=>t.tenantId)},active:true}).lean()});
}));
EnterpriseRoutes.get('/facilities/:id/inventory',guardRole(['user','trainer']),route(async(req,res) => send(res,await facilityInventory((req.user as any).id,String(req.params.id)))));
EnterpriseRoutes.put('/facilities/:id/inventory',guardRole(['user','trainer']),route(async(req,res) => send(res,await setInventory((req.user as any).id,String(req.params.id),req.body.equipment))));
EnterpriseRoutes.post('/internal/validate-payment',internal,route(async(req,res) => {
  const plan=Object.prototype.hasOwnProperty.call(catalogs,req.body.plan) ? catalogs[req.body.plan] : undefined;
  const claim=await GymClaim.findOne({_id:req.body.applicationId,workEmail:text(req.body.email,254).toLowerCase(),tier:plan?.tier,status:{$in:['pending_review','approved']}});
  if (!plan?.tier || !claim) return res.status(409).json({success:false,message:'Payment does not match an eligible gym application'});
  return send(res,{valid:true});
}));
EnterpriseRoutes.post('/internal/payment',internal,route(async(req,res) => {
  const b=req.body, plan=Object.prototype.hasOwnProperty.call(catalogs,b.plan) ? catalogs[b.plan] : undefined;
  if (!['production','sandbox'].includes(b.environment) || (process.env.NODE_ENV === 'production' && b.environment !== 'production')) return res.status(403).json({success:false,message:'Payment environment is not allowed'});
  const email=text(b.email,254).toLowerCase(), purchase=text(b.sourcePurchaseId,200),expires=new Date(b.expiresAt);
  if (!plan || !purchase || !email || b.amountCents!==plan.amount || !['paid','refunded'].includes(b.status) || !Number.isFinite(expires.getTime())) {
    return res.status(400).json({success:false,message:'Invalid verified payment'});
  }
  const session=await WebPayment.startSession();let promoCode:string|undefined;
  try {
    await session.withTransaction(async()=>{
      let payment=await WebPayment.findOne({sourcePurchaseId:purchase}).session(session);
      if (payment && (payment.email!==email || payment.plan!==b.plan || (payment.applicationId||null)!==(b.applicationId||null))) throw new Error('Payment ownership mismatch');
      if (!payment) payment=new WebPayment({sourcePurchaseId:purchase,email,plan:b.plan,amountCents:b.amountCents,applicationId:b.applicationId,expiresAt:expires});
      payment.status=payment.status==='refunded'?'refunded':b.status;await payment.save({session});
      if (plan.tier) {
        const claim=await GymClaim.findOne({_id:b.applicationId,workEmail:email,tier:plan.tier}).session(session);
        if (!claim) throw new Error('Gym claim does not match verified payment');
        const active=await WebPayment.findOne({applicationId:b.applicationId,status:'paid',expiresAt:{$gt:new Date()}}).sort({expiresAt:-1}).session(session);
        claim.paymentStatus=active?'paid':payment.status==='refunded'?'refunded':'expired';
        claim.paymentExpiresAt=active?.expiresAt || expires;
        if (claim.status==='approved') {
          await TenantAccessModel.updateOne({tenantId:claim.tenantId},{$set:{isLive:!!active,accessExpiresAt:claim.paymentExpiresAt}},{session});
          if (!active) {
            claim.status='revoked';claim.reason='License payment refunded or expired';
            await Facility.updateMany({tenantId:claim.tenantId},{$set:{active:false}},{session});
            await UserModel.updateMany({gymAdminTenantIds:claim.tenantId},{$pull:{gymAdminTenantIds:claim.tenantId}},{session});
          }
        }
        await claim.save({session});
      } else {
        let promo=await PromoCodeModel.findOne({sourcePurchaseId:purchase}).session(session);
        if (payment.status==='paid' && expires>new Date()) {
          if (!promo) { const created=await PromoCodeModel.create([{sourcePurchaseId:purchase,code:`WEB-${randomBytes(12).toString('hex').toUpperCase()}`,type:'website',priceCents:plan.amount,durationDays:plan.days,label:`${plan.days}-day web access`,maxUses:1,usedCount:0,status:'active'}],{session});promo=created[0]; }
          promoCode=promo.code;payment.promoCode=promoCode;await payment.save({session});
        } else if (promo) {
          promo.status='disabled';await promo.save({session});
          const subs=await SubscriptionModel.find({promoCodeId:promo._id,status:'active'}).session(session);
          for (const sub of subs) {
            await SubscriptionModel.updateOne({_id:sub._id},{$set:{status:'cancelled',cancelledAt:new Date()}},{session});
            // Do not remove a newer independent store/trainer entitlement.
            await UserModel.updateOne({_id:sub.userId,subscriptionStartDate:sub.startDate,subscriptionEndDate:sub.endDate},
              {$set:{subscriptionTier:'free',subscriptionEndDate:new Date(),subscribedTrainer:null}},{session});
          }
        }
      }
    });
  } finally { await session.endSession(); }
  return send(res,{promoCode:promoCode||null});
}));
