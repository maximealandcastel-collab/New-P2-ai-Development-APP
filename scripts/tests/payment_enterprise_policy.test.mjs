import test from 'node:test';
import assert from 'node:assert/strict';
import { createHmac } from 'node:crypto';
import { chargeState, mergePaymentState, planFor, verifyHostedSignature, secureEqual } from '../../artifacts/api-server/src/services/cloverPolicy.ts';
import { requireApproval, canUseFacility, integerCents } from '../../artifacts/p2p-app-backend/src/modules/enterprise/enterprise.policy.ts';
const paid = {id:'charge-1',amount:4999,currency:'usd',paid:true,captured:true,status:'succeeded',created:1719882650000};
test('Clover verified captured payment matches server catalog',()=>assert.equal(chargeState(paid,{amount_cents:4999},true),'paid'));
test('mismatched amount, identity, environment and incomplete charges cannot activate',()=>{
 for (const change of [{amount:1},{currency:'eur'},{paid:false},{captured:false},{status:'failed'},{livemode:false}]) assert.throws(()=>chargeState({...paid,...change},{amount_cents:4999},true));
 assert.throws(()=>chargeState(paid,{amount_cents:4999,charge_id:'another'},true));
});
test('partial and full refunds revoke access; stale paid event cannot reverse a refund',()=>{
 assert.equal(chargeState({...paid,amount_refunded:1},{amount_cents:4999},true),'refunded');
 assert.equal(chargeState({...paid,refunded:true},{amount_cents:4999},true),'refunded');
 assert.equal(mergePaymentState('refunded','paid'),'refunded');
});
test('unknown and prototype plan names are rejected',()=>{for(const id of ['__proto__','constructor','free',null])assert.throws(()=>planFor(id));assert.equal(planFor('enterprise_core').amount,4999);});
test('webhook authentication rejects absent or mismatched keys',()=>{assert.equal(secureEqual(undefined,undefined),false);assert.equal(secureEqual('x','x'),true);assert.equal(secureEqual('x','y'),false);});
test('Hosted Checkout HMAC verifies raw bytes and rejects replay/tamper',()=>{
 const raw=Buffer.from('{"id":"1"}'),secret='test-secret',time=1770000000;
 const sig=createHmac('sha256',secret).update(`${time}.`).update(raw).digest('hex');
 const header=`t=${time},v1=${sig}`;
 assert.equal(verifyHostedSignature(raw,header,secret,time*1000),true);
 assert.equal(verifyHostedSignature(Buffer.from('{}'),header,secret,time*1000),false);
 assert.equal(verifyHostedSignature(raw,header,secret,(time+301)*1000),false);
 assert.equal(verifyHostedSignature(raw,header+',t=1',secret,time*1000),false);
});
const approval={status:'pending_review',ownerUserId:'owner',ownershipVerifiedAt:new Date(),paymentStatus:'paid',paymentExpiresAt:new Date('2030-01-01')};
test('approval needs ownership and unexpired payment',()=>{
 requireApproval(approval,new Date('2029-01-01'));
 for(const change of [{status:'revoked'},{ownerUserId:null},{ownershipVerifiedAt:null},{paymentStatus:'refunded'},{paymentExpiresAt:new Date('2020-01-01')}])assert.throws(()=>requireApproval({...approval,...change}));
});
test('facility membership denies cross-tenant, deleted, unverified and inactive access',()=>{
 const facility={tenantId:'a',active:true}, user={tenantId:'a',isVerified:true};
 assert.equal(canUseFacility(user,facility),true);
 for(const change of [{tenantId:'b'},{isDeleted:true},{isVerified:false}])assert.equal(canUseFacility({...user,...change},facility),false);
 assert.equal(canUseFacility(user,{...facility,active:false}),false);
 assert.equal(canUseFacility({isVerified:true,gymAdminTenantIds:['a']},facility),true);
 assert.equal(canUseFacility({isVerified:true,role:'admin'},facility),false);
});
test('withdrawals reject string, fractional, non-finite and unsafe cents',()=>{
 for(const n of ['100',0,-1,0.1,NaN,Infinity,Number.MAX_SAFE_INTEGER+1])assert.throws(()=>integerCents(n));
 assert.equal(integerCents(200001),200001);
});
