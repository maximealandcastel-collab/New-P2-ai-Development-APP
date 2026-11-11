import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import vm from 'node:vm';
import { STORE_PRODUCTS, resolveStoreProduct, googleSubscriptionDates } from '../../artifacts/p2p-app-backend/src/modules/iap/store-policy.ts';

const require = createRequire(new URL('../../artifacts/p2p-app-backend/package.json', import.meta.url));
const ts = require('typescript');
const base = '../../artifacts/p2p-app-backend/src/modules/iap/';
const read = path => readFileSync(new URL(path, import.meta.url), 'utf8');

// Execute real TypeScript modules with explicit store/middleware doubles.
// No credentials, database, store calls, or charges are used by this suite.
function load(path, mocks) {
  const source = ts.transpileModule(read(path), {
    compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022, esModuleInterop: true },
  }).outputText;
  const exports = {};
  vm.runInNewContext(source, {
    exports, Buffer, process: { env: {} }, console,
    require(name) {
      if (!(name in mocks)) throw new Error(`Unexpected dependency: ${name}`);
      return mocks[name];
    },
  });
  return exports;
}

test('every offered Flutter product is accepted with the correct period and access tier', () => {
  const catalog = read('../../lib/features/subscribe/domain/store_subscription_products.dart');
  const offered = [...catalog.matchAll(/static const \w+ = '(p2p_[^']+)';/g)].map(m => m[1]);
  assert.equal(offered.length, 4);
  for (const id of offered) {
    const product = resolveStoreProduct(id);
    assert.ok(product, id);
    assert.equal(product.tier, id.endsWith('_3m') ? 'quarterly' : 'annual');
    assert.equal(product.accessTier, id.startsWith('p2p_pro') ? 'premium' : 'paid');
  }
  for (const id of ['__proto__', 'constructor', 'unknown', 'p2p_gym_starter_monthly']) {
    assert.equal(resolveStoreProduct(id), null);
  }
  assert.equal(Object.keys(STORE_PRODUCTS).length, 6);
});

const now = Date.parse('2026-11-01T00:00:00Z');
const google = {
  startTime: '2026-10-01T00:00:00Z',
  subscriptionState: 'SUBSCRIPTION_STATE_ACTIVE',
  lineItems: [{ productId: 'p2p_standard_3m', expiryTime: '2027-01-01T00:00:00Z' }],
};
test('Google uses matching lineItems expiry, including paid canceled and grace periods', () => {
  for (const subscriptionState of ['SUBSCRIPTION_STATE_ACTIVE', 'SUBSCRIPTION_STATE_CANCELED', 'SUBSCRIPTION_STATE_IN_GRACE_PERIOD']) {
    const dates = googleSubscriptionDates({ ...google, subscriptionState }, 'p2p_standard_3m', now, true);
    assert.equal(dates.endDate.toISOString(), '2027-01-01T00:00:00.000Z');
  }
});
test('Google rejects expired, paused, wrong product and production test purchases', () => {
  for (const change of [
    { lineItems: [] }, { startTime: 'bad' },
    { subscriptionState: 'SUBSCRIPTION_STATE_EXPIRED' },
    { subscriptionState: 'SUBSCRIPTION_STATE_ON_HOLD' },
    { subscriptionState: 'SUBSCRIPTION_STATE_PAUSED' },
    { testPurchase: {} },
    { lineItems: [{ productId: 'p2p_standard_3m', expiryTime: new Date(now).toISOString() }] },
  ]) assert.throws(() => googleSubscriptionDates({ ...google, ...change }, 'p2p_standard_3m', now, true));
  assert.throws(() => googleSubscriptionDates(google, 'p2p_pro_annual', now, false));
});

test('verification endpoint authorizes both signup roles, not anonymous callers', () => {
  let guardRoles;
  let registered;
  const handler = () => {};
  load(base + 'iap.route.ts', {
    express: { Router: () => ({ post: (...args) => { registered = args; } }) },
    './iap.controller': { verifyIAPController: handler },
    '../../middlewares/roleGuard': { guardRole: roles => { guardRoles = [...roles]; return 'authenticated-guard'; } },
  });
  assert.deepEqual(guardRoles, ['user', 'trainer']);
  assert.deepEqual([...registered], ['/verify', 'authenticated-guard', handler]);
});

const transaction = {
  transactionId: '100000123', originalTransactionId: '100000001',
  bundleId: 'com.p2pfittech.ai', productId: 'p2p_standard_3m',
  purchaseDate: now - 1000, expiresDate: now + 86400000,
  environment: 'Production',
};
const jws = payload => 'header.' + Buffer.from(JSON.stringify(payload)).toString('base64url') + '.signature';
function appleVerifier(payload = transaction) {
  let calls = 0;
  const source = ts.transpileModule(read(base + 'apple-verifier.service.ts'), {
    compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022, esModuleInterop: true },
  }).outputText;
  const exports = {};
  const env = {
    NODE_ENV: 'production', APPLE_IAP_KEY_ID: 'test-key',
    APPLE_IAP_ISSUER_ID: 'test-issuer', APPLE_IAP_PRIVATE_KEY: 'test-private-key',
  };
  vm.runInNewContext(source, {
    exports, Buffer, process: { env },
    require: name => {
      if (name === 'jsonwebtoken') return { sign: () => 'server-auth' };
      if (name === 'axios') return { get: async (url, options) => {
        calls++;
        assert.match(url, /^https:\/\/api\.storekit\.itunes\.apple\.com\/inApps\/v1\/transactions\/100000123$/);
        assert.equal(options.headers.Authorization, 'Bearer server-auth');
        return { data: { signedTransactionInfo: jws(payload) } };
      } };
      throw new Error(name);
    },
  });
  return { verify: exports.verifyAppleTransaction, env, calls: () => calls };
}
test('Apple supports Flutter legacy receipt and JWS but uses only authenticated server data', async () => {
  for (const proof of ['base64StoreKit1Receipt==', jws({ ...transaction, expiresDate: 0 })]) {
    const apple = appleVerifier();
    const result = await apple.verify(proof, transaction.transactionId, transaction.productId);
    assert.equal(result.productId, transaction.productId);
    assert.equal(result.expiresDate.getTime(), transaction.expiresDate);
    assert.equal(apple.calls(), 1);
  }
});
test('Apple rejects mismatched, revoked, sandbox and malformed server transactions', async () => {
  for (const change of [
    { bundleId: 'wrong' }, { productId: 'p2p_pro_annual' },
    { transactionId: 'wrong' }, { originalTransactionId: '' },
    { expiresDate: 'bad' }, { environment: 'Sandbox' }, { revocationDate: now },
  ]) {
    const apple = appleVerifier({ ...transaction, ...change });
    await assert.rejects(apple.verify('receipt', transaction.transactionId, transaction.productId));
  }
});
test('Apple fails closed without credentials or valid input', async () => {
  const apple = appleVerifier();
  await assert.rejects(apple.verify('', transaction.transactionId, transaction.productId));
  await assert.rejects(apple.verify('receipt', '../other', transaction.productId));
  delete apple.env.APPLE_IAP_PRIVATE_KEY;
  await assert.rejects(apple.verify('receipt', transaction.transactionId, transaction.productId));
  assert.equal(apple.calls(), 0);
});

function verificationService({ stored = null, verified, endError } = {}) {
  const rows = stored ? [stored] : [];
  let writes = 0;
  let storeCalls = 0;
  class ApiError extends Error {
    constructor(status, message) { super(message); this.status = status; }
  }
  const model = {
    findOne(query) {
      const result = rows.find(row => Object.entries(query).every(([key, value]) => row[key] === value)) ?? null;
      return { then: (resolve, reject) => Promise.resolve(result).then(resolve, reject), session: async () => result };
    },
    startSession: async () => ({
      withTransaction: async callback => callback(), endSession: async () => {},
    }),
    findOneAndUpdate: async (_filter, update) => {
      writes++;
      const record = { ...update.$setOnInsert, ...update.$set };
      rows.push(record);
      return record;
    },
  };
  const service = load(base + 'iap.service.ts', {
    jsonwebtoken: {}, axios: {},
    'node:crypto': { createHash: () => { throw new Error('Not an Android test'); } },
    mongoose: { Types: { ObjectId: class { constructor(id) { this.id = id; } toString() { return this.id; } } } },
    './iap.model': { IAPSubscriptionModel: model },
    '../user/user.model': { UserModel: { findByIdAndUpdate: async () => ({ isDeleted: false }) } },
    './store-policy': { resolveStoreProduct, googleSubscriptionDates },
    '../../errors/ApiError': ApiError,
    'http-status': { BAD_REQUEST: 400, CONFLICT: 409, PAYMENT_REQUIRED: 402, FORBIDDEN: 403 },
    './apple-verifier.service': { verifyAppleTransaction: async () => {
      storeCalls++;
      if (endError) throw new Error('Store rejected');
      return verified ?? {
        purchaseDate: new Date(Date.now() - 1000),
        expiresDate: new Date(Date.now() + 86400000),
        originalTransactionId: 'chain-1',
      };
    } },
  });
  return { verify: service.verifyIAPSubscription, writes: () => writes, storeCalls: () => storeCalls };
}

test('verification grants Standard/Pro only from store-verified expiry', async () => {
  for (const productId of ['p2p_standard_3m', 'p2p_pro_annual']) {
    const service = verificationService();
    const result = await service.verify('user-a', 'ios', productId, '100000123', 'receipt');
    assert.equal(result.isSubscribed, true);
    assert.equal(result.productId, productId);
    assert.equal(result.subscriptionTier, productId.includes('_pro_') ? 'premium' : 'paid');
    assert.equal(service.storeCalls(), 1);
    assert.equal(service.writes(), 1);
  }
});
test('expired, store-rejected and unknown purchases cannot write an entitlement', async () => {
  for (const options of [
    { endError: true },
    { verified: { purchaseDate: new Date(0), expiresDate: new Date(1), originalTransactionId: 'chain-1' } },
  ]) {
    const service = verificationService(options);
    await assert.rejects(service.verify('user-a', 'ios', 'p2p_standard_3m', '100000123', 'receipt'));
    assert.equal(service.writes(), 0);
  }
  const service = verificationService();
  await assert.rejects(service.verify('user-a', 'ios', 'unknown', '100000123', 'receipt'));
  assert.equal(service.storeCalls(), 0);
});
test('restore rechecks the store; transaction and original-chain ownership cannot be transferred', async () => {
  const stored = {
    userId: { toString: () => 'user-a' }, purchaseId: '100000123',
    originalTransactionId: 'chain-1', status: 'active',
    startDate: new Date(Date.now() - 1000), endDate: new Date(Date.now() + 864000000),
    productId: 'p2p_standard_3m', platform: 'ios',
  };
  const restore = verificationService({ stored });
  await restore.verify('user-a', 'ios', stored.productId, stored.purchaseId, 'receipt');
  assert.equal(restore.storeCalls(), 1);
  assert.equal(restore.writes(), 0); // Never shorten a later verified period.
  for (const purchaseId of [stored.purchaseId, '100000124']) {
    const service = verificationService({ stored });
    await assert.rejects(
      service.verify('user-b', 'ios', stored.productId, purchaseId, 'receipt'),
      error => error.status === 409,
    );
    assert.equal(service.writes(), 0);
  }
});
