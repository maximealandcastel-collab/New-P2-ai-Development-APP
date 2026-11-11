import test from 'node:test';
import assert from 'node:assert/strict';
import vm from 'node:vm';
import { readFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { DEFAULT_TENANT_BRANDING } from '../../artifacts/p2p-app-backend/src/modules/enterprise/tenant-branding-policy.ts';

const require = createRequire(new URL('../../artifacts/p2p-app-backend/package.json', import.meta.url));
const ts = require('typescript');
const source = readFileSync(new URL('../../artifacts/p2p-app-backend/src/modules/enterprise/tenant.service.ts', import.meta.url), 'utf8');

function fixture() {
  const state = {
    user: { _id: 'member-a', email: 'member@example.test', isVerified: true, role: 'user' },
    memberships: [{ userId: 'member-a', tenantId: 'gym-a', status: 'active', role: 'member' }],
    tenants: [{ tenantId: 'gym-a', displayName: 'Gym A', isLive: true, accessExpiresAt: new Date(Date.now() + 86400000) }],
    selection: null,
    brand: null,
    rejectStore: false,
    facilityQueries: [],
  };
  const exports = {};
  const lean = value => ({ lean: async () => value });
  const mocks = {
    './tenant-branding-policy': { DEFAULT_TENANT_BRANDING },
    './gym-apple.service': { assertGymAppleEntitlement: async () => {
      if (state.rejectStore) throw new Error('No active store entitlement');
    } },
    '../user/user.model': { UserModel: { findById: () => lean(state.user) } },
    '../tenantAccess/tenantAccess.model': { TenantAccessModel: {
      find: query => lean(state.tenants.filter(t => query.tenantId.$in.includes(t.tenantId))),
      findOne: query => lean(state.tenants.find(t => t.tenantId === query.tenantId)),
    } },
    './enterprise.model': {
      Facility: { findOne: query => {
        state.facilityQueries.push(query);
        return lean({ facilityId: 'facility-a', tenantId: query.tenantId });
      } },
      GymClaim: { find: () => ({ select: () => lean([]) }) },
    },
    './tenant.model': {
      TenantMembership: {
        find: query => lean(state.memberships.filter(m => m.userId === query.userId)),
        findOne: query => lean(state.memberships.find(m =>
          m.userId === query.userId && m.tenantId === query.tenantId && m.status === query.status)),
      },
      TenantBranding: { findOne: () => lean(state.brand) },
      TenantSelection: { findOne: () => lean(state.selection) },
    },
  };
  const js = ts.transpileModule(source, {
    compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022, esModuleInterop: true },
  }).outputText;
  vm.runInNewContext(js, { exports, require: name => {
    if (!(name in mocks)) throw new Error(`Unexpected dependency: ${name}`);
    return mocks[name];
  } });
  return { state, ...exports };
}

test('personal accounts without memberships receive no tenant context', async () => {
  const f = fixture();
  f.state.memberships = [];
  const result = await f.bootstrap('member-a');
  assert.equal(result.context, null);
  assert.equal(result.currentTenantId, null);
  assert.equal(result.entitlement.state, 'no_tenant');
  assert.equal(f.state.facilityQueries.length, 0);
});
test('bootstrap restores only a server-issued active membership', async () => {
  const f = fixture();
  const result = await f.bootstrap('member-a');
  assert.equal(result.context.tenant.id, 'gym-a');
  assert.equal(result.context.roles[0], 'member');
  assert.equal(result.context.capabilities.includes('manage_members'), false);
  assert.equal(f.state.facilityQueries[0].tenantId, 'gym-a');
});
test('foreign selections and explicit personal-mode selection never fall back into another gym', async () => {
  for (const tenantId of ['foreign-gym', null]) {
    const f = fixture();
    f.state.selection = { tenantId };
    assert.equal((await f.bootstrap('member-a')).context, null);
  }
});
test('revoked memberships, expired licenses and failed store checks suppress tenant context', async () => {
  for (const change of [
    f => { f.state.memberships[0].status = 'revoked'; },
    f => { f.state.tenants[0].isLive = false; },
    f => { f.state.tenants[0].accessExpiresAt = new Date(0); },
    f => { f.state.rejectStore = true; },
  ]) {
    const f = fixture();
    change(f);
    assert.equal((await f.bootstrap('member-a')).context, null);
    await assert.rejects(f.authorizeTenant('member-a', 'gym-a'));
  }
});
test('a gym member cannot manage the gym or access another tenant', async () => {
  const f = fixture();
  await assert.rejects(f.authorizeTenant('member-a', 'gym-a', true));
  await assert.rejects(f.authorizeTenant('member-a', 'gym-b'));
  assert.equal((await f.authorizeTenant('member-a', 'gym-a')).role, 'member');
});
test('global role alone never creates a member context', async () => {
  const f = fixture();
  f.state.user.role = 'admin';
  f.state.memberships = [];
  assert.equal((await f.bootstrap('member-a')).context, null);
  await assert.rejects(f.authorizeTenant('member-a', 'gym-a'));
  assert.equal((await f.authorizeTenant('member-a', 'gym-a', false, true)).role, 'global_admin');
});
test('deleted and unverified accounts cannot bootstrap a tenant', async () => {
  for (const change of [{ isDeleted: true }, { isVerified: false }]) {
    const f = fixture();
    Object.assign(f.state.user, change);
    await assert.rejects(f.bootstrap('member-a'));
    await assert.rejects(f.authorizeTenant('member-a', 'gym-a'));
  }
});
test('new/unconfigured gyms use neutral colors; approved brand and logo remain unchanged', async () => {
  const f = fixture();
  let result = await f.bootstrap('member-a');
  assert.equal(result.context.tenant.primaryColor, '#27272A');
  assert.equal(result.context.tenant.accentColor, '#52525B');
  f.state.brand = {
    gymName: 'Approved Gym', logoUrl: 'https://example.test/original-logo.png',
    primaryColor: '#004488', secondaryColor: '#101010', accentColor: '#005599',
  };
  result = await f.bootstrap('member-a');
  for (const key of ['logoUrl', 'primaryColor', 'secondaryColor', 'accentColor']) {
    assert.equal(result.context.tenant[key], f.state.brand[key]);
  }
});
