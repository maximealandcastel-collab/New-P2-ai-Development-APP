// Embedded PostgreSQL + simulated provider transport; never makes real charges.
const {test,before,after}=require('node:test');
const assert=require('node:assert/strict');
const path=require('node:path');
const {createRequire}=require('node:module');
const runtime=createRequire(path.join(process.env.P2P_TEST_RUNTIME,'package.json'));
const {PGlite}=runtime('@electric-sql/pglite');
const express=runtime('express');
const root=process.env.P2P_TEST_BILLING;
let db,server,base,postCount=0,deliveryCount=0,failDelivery=false,refund=false;
const realFetch=global.fetch;
const calls=[];
process.env.CLOVER_ENV='sandbox';process.env.NODE_ENV='test';
process.env.CLOVER_API_KEY='test-only';process.env.CLOVER_MERCHANT_ID='merchant-test';
process.env.CLOVER_APP_ID='app-test';process.env.CLOVER_WEBHOOK_AUTH='webhook-test';
process.env.APP_BACKEND_URL='https://backend.example.test';process.env.APP_BACKEND_SHARED_SECRET='service-test';
const query=async(sql,values)=> {
 if(sql.includes('CREATE TABLE')) {await db.exec(sql);return {rows:[]};}
 const result=await db.query(sql,values);return {rows:result.rows,rowCount:result.affectedRows};
};
const pool={query,connect:async()=>({query,release(){}})};
const dbPath=path.join(root,'dist/lib/db.js');
require.cache[dbPath]={id:dbPath,filename:dbPath,loaded:true,exports:{__esModule:true,default:pool}};
before(async()=>{
 db=new PGlite();await db.waitReady;
 global.fetch=async(url,options={})=>{
  const target=String(url);
  if(target.startsWith('https://scl-sandbox.dev.clover.com')) {
   const posted=options.method==='POST';
   if(posted){postCount++;calls.push(JSON.parse(options.body));assert.match(options.headers['Idempotency-Key'],/^[a-f0-9-]{36}$/);}
   const charge={id:'charge-'+(postCount||1),amount:1999,currency:'usd',created:Date.now(),paid:true,captured:true,status:'succeeded',amount_refunded:refund?1999:0};
   return new Response(JSON.stringify(charge),{status:200});
  }
  if(target.startsWith('https://backend.example.test')) {
   deliveryCount++;
   if(failDelivery)return new Response('{}',{status:503});
   return new Response(JSON.stringify({success:true,data:{promoCode:'TEST-PROMO'}}),{status:200});
  }
  return realFetch(url,options);
 };
 const router=require(path.join(root,'dist/routes/clover.js')).default;
 const app=express();app.use(express.json());app.use(router);
 server=app.listen(0,'127.0.0.1');await new Promise(resolve=>server.once('listening',resolve));base=`http://127.0.0.1:${server.address().port}`;
});
after(async()=>{global.fetch=realFetch;if(server)await new Promise(resolve=>server.close(resolve));if(db)await db.close();});
const checkout=(body)=>realFetch(base+'/checkout',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(body)});
test('persisted retry does not charge twice; client amount ignored; refund event is authenticated and idempotent',async()=>{
 const payload={token:'test-card-token',plan:'three_months',email:'buyer@example.test',amount:1,idempotencyKey:'11111111-1111-4111-8111-111111111111'};
 const first=await checkout(payload);assert.equal(first.status,200);assert.equal((await first.json()).success,true);
 const second=await checkout(payload);assert.equal(second.status,200);assert.equal((await second.json()).promoCode,'TEST-PROMO');
 assert.equal(postCount,1);assert.equal(calls[0].amount,1999);assert.equal(deliveryCount,1);
 assert.equal((await checkout({...payload,email:'other@example.test'})).status,409);
 const event={appId:'app-test',merchants:{'merchant-test':[{objectId:'P:charge-1',type:'UPDATE',ts:Date.now()}]}};
 const webhook=(auth)=>realFetch(base+'/webhook',{method:'POST',headers:{'Content-Type':'application/json','X-Clover-Auth':auth},body:JSON.stringify(event)});
 refund=true;
 assert.equal((await webhook('wrong')).status,401);
 assert.equal((await webhook('webhook-test')).status,200);
 assert.equal((await webhook('webhook-test')).status,200);
 assert.equal(deliveryCount,2);
 const state=await db.query('SELECT status,delivered_status FROM billing_attempts WHERE id=$1',[payload.idempotencyKey]);
 assert.equal(state.rows[0].status,'refunded');assert.equal(state.rows[0].delivered_status,'refunded');
});
test('backend outage preserves the charge and delivery retry reuses the same attempt',async()=>{
 refund=false;failDelivery=true;
 const payload={token:'test-card-token-2',plan:'three_months',email:'buyer2@example.test',idempotencyKey:'22222222-2222-4222-8222-222222222222'};
 const first=await checkout(payload);assert.equal(first.status,200);assert.equal((await first.json()).deliveryPending,true);
 assert.equal(postCount,2);
 failDelivery=false;
 const second=await checkout(payload);assert.equal(second.status,200);assert.equal((await second.json()).deliveryPending,false);assert.equal(postCount,2);
});
