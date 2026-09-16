// Run against a compiled full backend and an ephemeral Mongo replica set only.
const { test, before, after } = require('node:test');
const assert = require('node:assert/strict');
const path = require('node:path');
const { createRequire } = require('node:module');
const root = process.env.P2P_TEST_BACKEND;
if (!root) throw new Error('Set P2P_TEST_BACKEND to the compiled full backend directory');
const backendRequire = createRequire(path.join(root,'package.json'));
const runtimeRequire = process.env.P2P_TEST_RUNTIME ? createRequire(path.join(process.env.P2P_TEST_RUNTIME,'package.json')) : backendRequire;
const { MongoMemoryReplSet } = runtimeRequire('mongodb-memory-server');
const mongoose = backendRequire('mongoose');
const express = backendRequire('express');
const jwt = backendRequire('jsonwebtoken');
process.env.SESSION_SECRET='integration-test-only-signing-secret';
process.env.APP_BACKEND_SHARED_SECRET='integration-test-only-service-secret';
process.env.NODE_ENV='test';
const {EnterpriseRoutes}=require(path.join(root,'dist/modules/enterprise/enterprise.route.js'));
const {UserModel}=require(path.join(root,'dist/modules/user/user.model.js'));
const {GymClaim,Facility,WebPayment}=require(path.join(root,'dist/modules/enterprise/enterprise.model.js'));
const {TenantAccessModel}=require(path.join(root,'dist/modules/tenantAccess/tenantAccess.model.js'));
let repl,server,base,admin,owner,stranger;
const bearer=(user)=>'Bearer '+jwt.sign({id:String(user._id),role:user.role,email:user.email},process.env.SESSION_SECRET);
async function request(url,body,auth,method='POST') {
 const response=await fetch(base+url,{method,headers:{'Content-Type':'application/json',...(auth?{Authorization:auth}:{})},...(method==='GET'?{}:{body:JSON.stringify(body)})});
 return {status:response.status,body:await response.json()};
}
async function internal(body) {
 const response=await fetch(base+'/internal/payment',{method:'POST',headers:{'Content-Type':'application/json','x-admin-key':process.env.APP_BACKEND_SHARED_SECRET},body:JSON.stringify(body)});
 return {status:response.status,body:await response.json()};
}
before(async()=>{
 repl=await MongoMemoryReplSet.create({replSet:{count:1},binary:{version:'7.0.24'},instanceOpts:[{ip:'127.0.0.1'}]});
 await mongoose.connect(repl.getUri());
 await Promise.all([GymClaim.init(),Facility.init(),WebPayment.init(),UserModel.init(),TenantAccessModel.init()]);
 const user=(email,role='user')=>UserModel.create({firstName:'Test',lastName:'Account',email,password:'test-only',gender:'not_prefer_to_say',role,isVerified:true});
 admin=await user('admin@example.test','admin');owner=await user('owner@example.test');stranger=await user('stranger@example.test');
 const app=express();app.use(express.json());app.use(EnterpriseRoutes);app.use((err,req,res,next)=>res.status(400).json({success:false,error:err.message}));
 server=app.listen(0,'127.0.0.1');await new Promise(resolve=>server.once('listening',resolve));base=`http://127.0.0.1:${server.address().port}`;
});
after(async()=>{if(server)await new Promise(resolve=>server.close(resolve));await mongoose.disconnect();if(repl)await repl.stop();});
test('real Mongo transaction: claim requires ownership/payment; scoped provisioning; refund revokes; retry cannot reactivate',async()=>{
 const intake=await request('/gym-applications',{gymName:'Test Gym',workEmail:owner.email,tier:'starter',authorizedRepresentative:true,reviewConsent:true});
 assert.equal(intake.status,201);const id=intake.body.data.applicationId;
 assert.equal((await request(`/admin/gym-applications/${id}/approve`,{},bearer(stranger))).status,403);
 assert.notEqual((await request(`/admin/gym-applications/${id}/approve`,{},bearer(admin))).status,200);
 assert.equal((await request(`/admin/gym-applications/${id}/verify-ownership`,{ownerUserId:String(owner._id),evidence:'Test fixture ownership evidence'},bearer(admin))).status,200);
 const payment={sourcePurchaseId:'test-charge-1',plan:'enterprise_core',amountCents:4999,email:owner.email,applicationId:id,status:'paid',expiresAt:new Date(Date.now()+86400000).toISOString(),environment:'sandbox'};
 assert.equal((await internal(payment)).status,200);assert.equal((await internal(payment)).status,200);
 assert.equal(await WebPayment.countDocuments({sourcePurchaseId:payment.sourcePurchaseId}),1);
 const approved=await request(`/admin/gym-applications/${id}/approve`,{},bearer(admin));assert.equal(approved.status,200);
 const facilityId=approved.body.data.facilityId,tenantId=approved.body.data.tenantId;
 assert.equal((await UserModel.findById(owner._id)).role,'user');
 assert.equal(await Facility.countDocuments({tenantId}),1);
 assert.equal((await request(`/admin/gym-applications/${id}/approve`,{},bearer(admin))).status,200);
 assert.equal(await Facility.countDocuments({tenantId}),1);
 assert.equal((await request(`/facilities/${facilityId}/inventory`,{},bearer(owner),'GET')).status,200);
 assert.notEqual((await request(`/facilities/${facilityId}/inventory`,{},bearer(stranger),'GET')).status,200);
 assert.equal((await request(`/facilities/${facilityId}/inventory`,{equipment:['dumbbells']},bearer(owner),'PUT')).status,200);
 assert.deepEqual((await Facility.findOne({facilityId})).equipment,['dumbbells']);
 assert.equal((await internal({...payment,status:'refunded'})).status,200);
 assert.equal((await internal(payment)).status,200);
 assert.equal((await GymClaim.findById(id)).status,'revoked');
 assert.equal((await WebPayment.findOne({sourcePurchaseId:payment.sourcePurchaseId})).status,'refunded');
 assert.notEqual((await request(`/facilities/${facilityId}/inventory`,{},bearer(owner),'GET')).status,200);
 assert.equal((await UserModel.findById(owner._id)).gymAdminTenantIds.includes(tenantId),false);
});
test('consumer payment delivery is idempotent, email-bound, and production rejects sandbox',async()=>{
 const payment={sourcePurchaseId:'consumer-test-1',plan:'annual',amountCents:12000,email:owner.email,status:'paid',expiresAt:new Date(Date.now()+86400000).toISOString(),environment:'sandbox'};
 const first=await internal(payment),second=await internal(payment);
 assert.equal(first.status,200);assert.equal(second.body.data.promoCode,first.body.data.promoCode);
 assert.notEqual((await internal({...payment,email:stranger.email})).status,200);
 process.env.NODE_ENV='production';
 try{assert.equal((await internal({...payment,sourcePurchaseId:'consumer-test-2'})).status,403);}finally{process.env.NODE_ENV='test';}
});

test('account deletion removes personal/health data and immediately revokes sessions, retaining billing records',async()=>{
 const {deletePersonalAccount}=require(path.join(root,'dist/modules/privacy/accountDeletion.service.js'));
 const victim=await UserModel.create({firstName:'Private',lastName:'Person',email:'delete@example.test',password:'test-only',gender:'male',isVerified:true,fcmToken:'test-device'});
 await mongoose.connection.db.collection('workouts').insertOne({userId:victim._id,healthNote:'private test data'});
 await mongoose.connection.db.collection('payments').insertOne({userId:victim._id,amount:999});
 const token=bearer(victim);
 await deletePersonalAccount(String(victim._id));
 const deleted=await UserModel.findById(victim._id).lean();
 assert.equal(deleted.isDeleted,true);assert.notEqual(deleted.email,victim.email);assert.equal(deleted.fcmToken,undefined);
 assert.equal(await mongoose.connection.db.collection('workouts').countDocuments({userId:victim._id}),0);
 assert.equal(await mongoose.connection.db.collection('payments').countDocuments({userId:victim._id}),1);
 assert.equal((await request('/facilities',{},token,'GET')).status,403);
});

test('Mux cleanup retries failures, leases jobs across workers, rejects wrong ownership and tolerates missing media',async()=>{
 const {MediaCleanup,runMediaCleanupBatch,removeMuxMedia}=require(path.join(root,'dist/modules/privacy/mediaCleanup.service.js'));
 await MediaCleanup.init();
 let reads=0,deletes=0,fail=true;
 const provider={video:{assets:{retrieve:async()=>{reads++;if(fail)throw Object.assign(new Error('private provider detail'),{status:503});return {passthrough:'owned-content'};},delete:async()=>{deletes++;}},uploads:{retrieve:async()=>({status:'waiting',new_asset_settings:{passthrough:'owned-content'}}),cancel:async()=>{}}}};
 const job=await MediaCleanup.create({userId:owner._id,contentId:'owned-content',kind:'mux_asset',providerId:'asset-1'});
 await runMediaCleanupBatch(provider);
 let row=await MediaCleanup.findById(job._id).lean();
 assert.equal(row.state,'pending');assert.equal(row.attempts,1);assert.equal(row.lastError,'provider_retry_required');assert.equal(deletes,0);
 fail=false;await MediaCleanup.updateOne({_id:job._id},{$set:{nextAttemptAt:new Date(0)}});
 await Promise.all([runMediaCleanupBatch(provider),runMediaCleanupBatch(provider)]);
 row=await MediaCleanup.findById(job._id).lean();assert.equal(row.state,'complete');assert.equal(deletes,1);assert.equal(reads,2);
 await assert.rejects(removeMuxMedia({kind:'mux_asset',providerId:'other',contentId:'wrong-owner'},provider),/ownership_mismatch/);
 assert.equal(deletes,1);
 const missing={video:{...provider.video,assets:{retrieve:async()=>{throw {status:404};},delete:async()=>{throw new Error('must not delete');}}}};
 await removeMuxMedia({kind:'mux_asset',providerId:'gone',contentId:'owned-content'},missing);
 let cancelled=0;
 provider.video.uploads.cancel=async()=>{cancelled++;};
 await removeMuxMedia({kind:'mux_upload',providerId:'upload',contentId:'owned-content'},provider);assert.equal(cancelled,1);
 provider.video.uploads.retrieve=async()=>({status:'asset_created',asset_id:'late-asset',new_asset_settings:{passthrough:'owned-content'}});
 await removeMuxMedia({kind:'mux_upload',providerId:'upload',contentId:'owned-content'},provider);assert.equal(deletes,2);
 // Expired leases recover after a worker crashes.
 const recovered=await MediaCleanup.create({userId:owner._id,contentId:'owned-content',kind:'mux_asset',providerId:'asset-recovered',leaseUntil:new Date(0),leaseToken:'dead-process'});
 await runMediaCleanupBatch(provider);assert.equal((await MediaCleanup.findById(recovered._id)).state,'complete');
});

test('account deletion transaction queues both uploaded assets and unfinished uploads',async()=>{
 const {deletePersonalAccount}=require(path.join(root,'dist/modules/privacy/accountDeletion.service.js'));
 const {MediaCleanup}=require(path.join(root,'dist/modules/privacy/mediaCleanup.service.js'));
 const userId=new mongoose.Types.ObjectId(),trainerId=new mongoose.Types.ObjectId(),contentId=new mongoose.Types.ObjectId();
 await UserModel.collection.insertOne({_id:userId,email:'cleanup@example.test',isDeleted:false,isVerified:true});
 await mongoose.connection.db.collection('trainers').insertOne({_id:trainerId,userId});
 await mongoose.connection.db.collection('contents').insertOne({_id:contentId,trainerId,muxAssetId:'queued-asset',muxUploadId:'queued-upload'});
 await deletePersonalAccount(String(userId));
 const jobs=await MediaCleanup.find({userId}).lean();assert.equal(jobs.length,2);assert.deepEqual(jobs.map(j=>j.kind).sort(),['mux_asset','mux_upload']);
 assert.ok(jobs.every(j=>j.contentId===String(contentId)));
 await deletePersonalAccount(String(userId));assert.equal(await MediaCleanup.countDocuments({userId}),2);
});
