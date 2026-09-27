import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';

const read = (path) => readFileSync(new URL(`../../${path}`, import.meta.url), 'utf8');

test('large iPhones keep the approved visual density', () => {
  const app = read('lib/app.dart');
  const tokens = read('lib/core/themes/p2p_design_tokens.dart');
  const home = read('lib/features/home/user_home_screen.dart');

  assert.match(app, /enableScaleWH:[\s\S]*referencePhoneWidth/);
  assert.match(app, /math\.min\(instance\.scaleWidth, 1\.0\)/);
  assert.match(tokens, /maxPhoneContentWidth = 414/);
  assert.match(home, /maxWidth: P2PLayout\.maxPhoneContentWidth/);
});

test('dashboard shortcuts retain their real actions', () => {
  const home = read('lib/features/home/user_home_screen.dart');

  assert.match(home, /builder: \(_\) => const AchievementsScreen\(\)/);
  assert.match(home, /AppRoute\.manageDevicesScreen/);
  assert.match(home, /AppRoute\.addDeviceScreen/);
  assert.match(home, /controller\.onChange\(gymsIndex\)/);
});

test('bottom navigation uses the slim visual geometry', () => {
  const bar = read(
    'lib/features/bottom_nav_bar/presentation/widgets/bottom_nav_bar.dart',
  );
  const item = read(
    'lib/features/bottom_nav_bar/presentation/widgets/nav_item_widget.dart',
  );

  assert.match(bar, /height: 44\.h/);
  assert.match(bar, /height: 38\.h/);
  assert.match(item, /width: 20\.w/);
  assert.match(item, /fontSize: 9\.2\.sp/);
});
