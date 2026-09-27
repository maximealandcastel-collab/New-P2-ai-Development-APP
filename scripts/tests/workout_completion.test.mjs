import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import test from 'node:test';

const root = new URL('../../', import.meta.url);
const read = (path) => readFile(new URL(path, root), 'utf8');

test('both workout completion paths open the real results screen', async () => {
  const [controller, aiResult] = await Promise.all([
    read('lib/features/user/workout/presentation/controllers/workout_controller.dart'),
    read('lib/features/user/workout_find/presentation/ai_plan_result_screen.dart'),
  ]);

  assert.match(controller, /WorkoutCompletionScreen\(/);
  assert.match(controller, /WorkoutCompletionSummary\.fromWorkout/);
  assert.match(aiResult, /WorkoutCompletionScreen\(/);
  assert.match(aiResult, /WorkoutCompletionSummary\.fromWorkout/);
});

test('completion metrics are derived and never use mock showcase values', async () => {
  const screen = await read(
    'lib/features/user/workout/presentation/screens/workout_completion_screen.dart',
  );

  assert.match(screen, /actualDurationMinutes/);
  assert.match(screen, /completedSets/);
  assert.match(screen, /actualWeight/);
  assert.doesNotMatch(screen, /12,840|3 NEW PRs|47 min|18 sets/);
});

test('completed workouts are rendered in the profile workout filter', async () => {
  const profile = await read(
    'lib/features/user/user_profile/presentation/user_profile_screen.dart',
  );

  assert.match(profile, /_WorkoutResultCard/);
  assert.match(profile, /user!\.workoutHistory/);
  assert.match(profile, /Saved to your workout profile/);
});

test('backend history persistence is independent from trainer memory', async () => {
  const service = await read(
    'artifacts/p2p-app-backend/src/modules/workoutGoal/workoutGoal.service.ts',
  );
  const historyWrite = service.indexOf('user.workoutHistory.push');
  const trainerMemoryGate = service.indexOf(
    'if (!user || !workout.trainerId) return { workout, memoryUpdated: false }',
  );

  assert.ok(historyWrite > -1);
  assert.ok(trainerMemoryGate > historyWrite);
});
