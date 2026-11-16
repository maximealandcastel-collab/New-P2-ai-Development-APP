// Source/asset checks only; not a substitute for Flutter compilation or device QA.
import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const root = fileURLToPath(new URL('../../', import.meta.url));
const read = relative => readFileSync(path.join(root, relative), 'utf8');
const styles = [
  'boxing', 'calisthenics', 'weight_lifting', 'wrestling', 'hiit', 'yoga',
  'pilates', 'mobility', 'functional_training', 'cardio',
  'sports_performance', 'rehabilitation',
];
const selection = read('lib/features/user/workout_find/presentation/workout_find_screen.dart');
const application = read('lib/features/gyms/presentation/screens/gym_application_screen.dart');

for (const style of styles) {
  test(`${style} has a referenced, nonempty, optimized PNG`, () => {
    assert.match(selection, new RegExp(`'id':\\s*'${style}'`));
    const image = readFileSync(path.join(root, `assets/images/training_styles/${style}.png`));
    assert.equal(image.subarray(0, 8).toString('hex'), '89504e470d0a1a0a');
    assert.ok(image.readUInt32BE(16) > 0 && image.readUInt32BE(20) > 0);
    assert.ok(image.length > 1024 && image.length < 1024 * 1024);
  });
}

test('training selection uses the declared asset directory', () => {
  assert.ok(selection.includes("imagePath: 'assets/images/training_styles/$id.png'"));
  assert.match(read('pubspec.yaml'), /-\s+assets\/images\/training_styles\//);
  assert.match(selection, /Image\.asset\(/);
});

for (const [method, next] of [
  ['_buildFreePartnerCard', '_buildElitePartnerCard'],
  ['_buildElitePartnerCard', null],
]) {
  test(`${method} uses the actual logo with a safe fallback`, () => {
    const start = application.indexOf(`Widget ${method}()`);
    assert.ok(start >= 0);
    const end = next ? application.indexOf(`Widget ${next}()`, start) : application.length;
    const card = application.slice(start, end);
    assert.match(card, /ClipOval\(\s*child:\s*Image\.asset\(\s*'assets\/images\/app_logo\.png'/);
    assert.match(card, /filterQuality:\s*FilterQuality\.high/);
    assert.match(card, /errorBuilder:/);
    assert.ok(card.includes("Text('P2P FitTech AI'"));
    assert.ok(existsSync(path.join(root, 'assets/images/app_logo.png')));
  });
}

test('subscription catalog retains all four offered products and legacy restores', () => {
  const catalog = read('lib/features/subscribe/domain/store_subscription_products.dart');
  for (const id of [
    'p2p_standard_3m', 'p2p_standard_annual', 'p2p_pro_3m', 'p2p_pro_annual',
    'month_1', 'year_1',
  ]) assert.ok(catalog.includes(`'${id}'`), id);
});

test('Codemagic still watches Elijah and publishes successful builds to TestFlight', () => {
  const yaml = read('codemagic.yaml');
  assert.match(yaml, /pattern:\s*elijah-stabilization/);
  assert.match(yaml, /events:\s*\n\s*-\s*push/);
  assert.match(yaml, /submit_to_testflight:\s*true/);
});

test('backend handoff matches its recorded hash and retains the tested fixes', () => {
  const manifest = JSON.parse(read('release/backend/SOURCE-MANIFEST.json'));
  const patch = read('release/backend/verified-backend.patch');
  assert.equal(createHash('sha256').update(patch).digest('hex'), manifest.patchSha256);
  assert.ok(Object.keys(manifest.files).length >= 18);
  assert.equal(manifest.verification.isolatedDatabaseChecks, 17);
  assert.ok(patch.includes('enterprise-session.model.ts'));
  assert.ok(patch.includes('p2p_iap_persistence.cjs'));
  assert.ok(patch.includes('withTransaction'));
});
