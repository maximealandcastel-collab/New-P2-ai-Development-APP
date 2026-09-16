const {test}=require('node:test');const assert=require('node:assert/strict');const fs=require('node:fs');const path=require('node:path');const vm=require('node:vm');const {createRequire}=require('node:module');
const runtime=createRequire(path.join(process.env.P2P_TEST_RUNTIME,'package.json'));const ts=runtime('typescript');
const source=fs.readFileSync(path.resolve(__dirname,'../../artifacts/p2p-app-backend/src/modules/enterprise/gym-apple.service.ts'),'utf8');
const mod={exports:{}};const js=ts.transpileModule(source,{compilerOptions:{module:ts.ModuleKind.CommonJS,target:ts.ScriptTarget.ES2022}}).outputText;
vm.runInThisContext('(function(require,module,exports){'+js+'\n})')(id=>id==='crypto'?require('crypto'):{},mod,mod.exports);
const {validateGymTransaction,GYM_APPLE_PRODUCTS}=mod.exports;
const claim={tier:'starter',appleAccountToken:'01234567-1234-1234-1234-123456789abc',appleOriginalTransactionId:'original-1'};
const tx={productId:GYM_APPLE_PRODUCTS.starter,appAccountToken:claim.appleAccountToken,originalTransactionId:'original-1',expiresDate:new Date(Date.now()+60000)};
test('gym product IDs are separate from individual subscriptions',()=>{assert.equal(GYM_APPLE_PRODUCTS.starter,'p2p_gym_starter_monthly');assert.equal(GYM_APPLE_PRODUCTS.pro,'p2p_gym_pro_monthly');});
test('verified matching purchase and renewal are accepted',()=>assert.doesNotThrow(()=>validateGymTransaction(claim,tx)));
test('wrong tier, wrong account binding, missing token, reused chain and expiry fail closed',()=>{
 for(const change of [{productId:GYM_APPLE_PRODUCTS.pro},{productId:'month_1'},{appAccountToken:'other'},{appAccountToken:undefined},{originalTransactionId:'other-chain'},{expiresDate:new Date(0)}])assert.throws(()=>validateGymTransaction(claim,{...tx,...change}));
 assert.throws(()=>validateGymTransaction({...claim,appleAccountToken:null},tx));
});
test('application and renewal screens have no external checkout path',()=>{
 const root=path.resolve(__dirname,'../../lib/features/gyms/presentation/screens');
 for(const name of ['gym_application_screen.dart','tenant_management_screen.dart'])assert.doesNotMatch(fs.readFileSync(path.join(root,name),'utf8'),/launchUrl|Clover|\/enroll\//);
});
