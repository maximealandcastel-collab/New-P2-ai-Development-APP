#!/usr/bin/env node
// Read-only smoke/denial checks; NOT a full isolation or workflow certification.
// Env: ENTERPRISE_API_BASE, GYM_A_ID, GYM_B_ID,
// GYM_A_ADMIN_TOKEN, GYM_B_ADMIN_TOKEN, GYM_A_MEMBER_TOKEN, GYM_B_MEMBER_TOKEN.
import assert from 'node:assert/strict';
const resources = ['dashboard','signups','members','plans','subscriptions','trainers','facility','locations','classes','content','activity','analytics'];
async function main() {
  const env = process.env;
  const required = ['ENTERPRISE_API_BASE','GYM_A_ID','GYM_B_ID','GYM_A_ADMIN_TOKEN','GYM_B_ADMIN_TOKEN','GYM_A_MEMBER_TOKEN','GYM_B_MEMBER_TOKEN'];
  for (const name of required) assert.ok(env[name], `Missing ${name}`);
  assert.notEqual(env.GYM_A_ID, env.GYM_B_ID, 'Use two distinct test tenants');
  assert.equal(new Set(required.filter(x => x.endsWith('_TOKEN')).map(x => env[x])).size, 4, 'Use distinct single-tenant test identities');
  const origin = new URL(env.ENTERPRISE_API_BASE);
  assert.ok(!origin.username && !origin.password && !origin.search && !origin.hash, 'Invalid API base');
  assert.ok(origin.protocol === 'https:' || (origin.protocol === 'http:' && ['localhost','127.0.0.1','[::1]'].includes(origin.hostname)), 'HTTPS required except localhost');
  const base = origin.href.replace(/\/$/, '');
  async function get(path, token) {
    return fetch(`${base}/enterprise${path}`, {redirect:'error', signal:AbortSignal.timeout(15000), headers:token ? {Authorization:`Bearer ${token}`} : {}});
  }
  async function data(response) {
    assert.equal(response.status, 200, 'Expected HTTP 200');
    const body = await response.json();
    assert.equal(body.success, true, 'Expected success envelope');
    assert.ok(body.data && typeof body.data === 'object', 'Expected data object');
    return body.data;
  }
  async function denied(response) {
    assert.ok([403,404].includes(response.status), `Expected tenant denial, got HTTP ${response.status}`);
    const body = await response.json();
    assert.equal(body.success, false, 'Denial must use failure envelope');
    assert.ok(body.data === undefined || body.data === null || (typeof body.data === 'object' && Object.keys(body.data).length === 0), 'Denial must not include records');
  }
  let cursor = null;
  const seen = new Set(), tenants = new Set();
  do {
    const page = await data(await get(`/tenants?limit=30${cursor ? `&cursor=${encodeURIComponent(cursor)}` : ''}`));
    assert.ok(Array.isArray(page.items), 'Directory items must be an array');
    for (const item of page.items) { tenants.add(item.id); assert.equal(item.schemaVersion,1,'Configuration version'); }
    cursor = page.nextCursor;
    assert.ok(cursor === null || typeof cursor === 'string', 'Invalid nextCursor');
    if (cursor) { assert.ok(!seen.has(cursor), 'Repeated cursor'); seen.add(cursor); assert.ok(seen.size < 1000, 'Pagination exceeded smoke-test bound'); }
  } while (cursor);
  assert.ok(tenants.has(env.GYM_A_ID) && tenants.has(env.GYM_B_ID), 'Both test gyms must be published in the directory');
  for (const [own, other, admin, member] of [
    [env.GYM_A_ID,env.GYM_B_ID,env.GYM_A_ADMIN_TOKEN,env.GYM_A_MEMBER_TOKEN],
    [env.GYM_B_ID,env.GYM_A_ID,env.GYM_B_ADMIN_TOKEN,env.GYM_B_MEMBER_TOKEN],
  ]) {
    const path = `/tenants/${encodeURIComponent(own)}/admin`;
    const dashboard = await data(await get(`${path}/dashboard`, admin));
    for (const key of ['signups','members','activeSubscriptions','trainers']) assert.ok(Number.isInteger(dashboard.counts?.[key]) && dashboard.counts[key] >= 0, `Invalid ${key} count`);
    for (const resource of resources) {
      if (resource !== 'dashboard') {
        const page = await data(await get(`${path}/${resource}?limit=30`,admin));
        assert.ok(Array.isArray(page.items),'Module must return items');
        for (const item of page.items) if (item.tenantId !== undefined) assert.equal(item.tenantId,own,'Cross-tenant list record');
      }
      await denied(await get(`/tenants/${encodeURIComponent(other)}/admin/${resource}`,admin));
      await denied(await get(`${path}/${resource}`,member));
    }
    const memberships = await data(await get('/me/memberships?limit=30',member));
    assert.ok(Array.isArray(memberships.items),'Memberships must be paginated');
    console.log(`Passed authorized reads and cross-tenant/member admin denials for ${own}`);
  }
  console.log('Read-only checks passed. Writes, resource references, media, realtime, revocation and end-to-end workflows still require the backend suite.');
}
main().catch(error => { console.error(error.message); process.exitCode = 1; });
