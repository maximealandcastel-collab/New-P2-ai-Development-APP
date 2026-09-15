import { test } from 'node:test';
import assert from 'node:assert/strict';
import { runWithProviderBackup } from '../../artifacts/p2p-app-backend/src/services/providerFallback.ts';
const wait = ms => new Promise(resolve => setTimeout(resolve, ms));
test('fast primary never invokes backup', async () => {
  let calls = 0;
  assert.equal(await runWithProviderBackup({primary: async () => 'primary', backup: async () => { calls++; return 'backup'; }, backupDelayMs: 20, deadlineMs: 100}), 'primary');
  await wait(25);
  assert.equal(calls, 0);
});
test('failed primary immediately invokes backup', async () => {
  assert.equal(await runWithProviderBackup({primary: async () => {throw new Error('invalid JSON');}, backup: async () => 'backup', backupDelayMs: 500, deadlineMs: 1000}), 'backup');
});
test('slow primary does not block backup and winner cancels outstanding work', async () => {
  let primarySignal;
  const value = await runWithProviderBackup({primary: signal => { primarySignal=signal; return new Promise(() => {}); }, backup: async () => 'backup', backupDelayMs: 5, deadlineMs: 100});
  assert.equal(value, 'backup');
  assert.equal(primarySignal.aborted, true);
});
test('invalid backup cannot win over valid primary', async () => {
  assert.equal(await runWithProviderBackup({primary: async () => {await wait(15); return 'valid';}, backup: async () => {throw new Error('bad schema');}, backupDelayMs: 1, deadlineMs: 100}), 'valid');
});
test('deadline terminates even providers that ignore cancellation', async () => {
  await assert.rejects(runWithProviderBackup({primary: () => new Promise(() => {}), backup: () => new Promise(() => {}), backupDelayMs: 1, deadlineMs: 15}), /deadline/);
});
test('both failures surface for library fallback', async () => {
  const fail = async () => { throw new Error('unavailable'); };
  await assert.rejects(runWithProviderBackup({primary: fail, backup: fail, backupDelayMs: 5, deadlineMs: 100}), /Both workout providers/);
});
