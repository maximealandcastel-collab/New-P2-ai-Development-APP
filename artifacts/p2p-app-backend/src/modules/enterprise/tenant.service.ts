import {assertGymAppleEntitlement} from './gym-apple.service';
import {UserModel} from '../user/user.model';
import {TenantAccessModel} from '../tenantAccess/tenantAccess.model';
import {Facility,GymClaim} from './enterprise.model';
import {TenantMembership,TenantBranding,TenantSelection} from './tenant.model';
export const brandingDefaults={logoUrl:'',primaryColor:'#B83B12',secondaryColor:'#202020',accentColor:'#B83B12'};
export function validateBranding(body:any) {
  const result:any={};
  for(const key of ['primaryColor','secondaryColor','accentColor']) if(body[key]!==undefined) {
    if(typeof body[key]!=='string'||!/^#[0-9a-f]{6}$/i.test(body[key])) throw new Error('Colors must use #RRGGBB');
    result[key]=body[key].toUpperCase();
  }
  if(body.gymName!==undefined) {
    if(typeof body.gymName!=='string'||!body.gymName.trim()||body.gymName.length>200)throw new Error('Gym name is required');
    result.gymName=body.gymName.trim();
  }
  if(body.logoUrl!==undefined) {
    if(typeof body.logoUrl!=='string'||body.logoUrl.length>2048)throw new Error('Invalid logo');
    if(body.logoUrl) {
      const url=new URL(body.logoUrl);
      if(url.protocol!=='https:'||url.username||url.password||url.hash||url.port||!url.hostname.includes('.')||/^[0-9.]+$/.test(url.hostname)||url.hostname.endsWith('.localhost')||url.hostname.endsWith('.local'))throw new Error('Logo must be a public HTTPS image URL');
    }
    result.logoUrl=body.logoUrl;
  }
  return result;
}
export async function authorizeTenant(userId:string,tenantId:string,manage=false,oversight=false) {
  const user:any=await UserModel.findById(userId).lean();
  if(!user||!user.isVerified||user.isDeleted)throw new Error('Tenant access denied');
  if(oversight&&user.role==='admin')return {role:'global_admin',user};
  const membership:any=await TenantMembership.findOne({userId,tenantId,status:'active'}).lean();
  const tenant:any=await TenantAccessModel.findOne({tenantId}).lean();
  if(!membership||!tenant?.isLive||!tenant.accessExpiresAt||tenant.accessExpiresAt<=new Date()||(manage&&!['owner','admin'].includes(membership.role)))throw new Error('Tenant access denied');
  await assertGymAppleEntitlement(tenantId);
  return {...membership,user};
}
export function entitlement(tenant:any) {
  if(!tenant?.isLive)return 'revoked';
  if(!tenant.accessExpiresAt||tenant.accessExpiresAt<=new Date())return 'expired';
  return 'active';
}
export async function bootstrap(userId:string) {
  const user:any=await UserModel.findById(userId).lean();
  if(!user||!user.isVerified||user.isDeleted)throw new Error('Authentication required');
  const memberships:any[]=await TenantMembership.find({userId}).lean();
  const tenants:any[]=await TenantAccessModel.find({tenantId:{$in:memberships.map(m=>m.tenantId)}}).lean();
  const choices=memberships.map(m=>{const t=tenants.find(t=>t.tenantId===m.tenantId);return {tenantId:m.tenantId,tenantName:t?.displayName||'Gym',role:m.role,status:m.status==='active'?entitlement(t):'revoked'};});
  await Promise.all(choices.filter(c=>c.status==='active').map(async c=>{try{await assertGymAppleEntitlement(c.tenantId);}catch{c.status='revoked';}}));
  const selection:any=await TenantSelection.findOne({userId}).lean();
  const current=selection?choices.find(c=>c.tenantId===selection.tenantId):(choices.find(c=>c.status==='active')||choices[0]);
  const state=current?.status||'no_tenant';
  let context:any=null,facility:any=null;
  if(current&&state==='active') {
    const brand:any=await TenantBranding.findOne({tenantId:current.tenantId}).lean();
    facility=await Facility.findOne({tenantId:current.tenantId,active:true}).lean();
    context={tenant:{schemaVersion:1,id:current.tenantId,name:brand?.gymName||current.tenantName,timezone:'UTC',...brandingDefaults,...(brand?{logoUrl:brand.logoUrl,primaryColor:brand.primaryColor,secondaryColor:brand.secondaryColor,accentColor:brand.accentColor}:{})},roles:[current.role],capabilities:['flagship',...(['owner','admin'].includes(current.role)?['manage_branding','manage_members','manage_inventory']:[])],facility};
  }
  return {identity:{id:String(user._id),globalRole:user.role},choices,currentTenantId:current?.tenantId||null,entitlement:{state,renewalRequired:['expired','revoked'].includes(state)},context,facility,applications:await GymClaim.find({workEmail:user.email}).select('gymName tier status paymentStatus paymentExpiresAt ownershipVerifiedAt tenantId facilityId provisioningState provisioningFailure reason').lean()};
}
