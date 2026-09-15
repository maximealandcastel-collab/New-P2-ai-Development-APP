import { test } from 'node:test';
import assert from 'node:assert/strict';
import { normalizeEquipment, resolveWorkoutEquipment, exerciseMatchesEquipment } from '../../artifacts/p2p-app-backend/src/modules/workoutGoal/workoutEquipment.ts';
import { exerciseMatchesSplitDay, splitDayMuscles, selectSplitDayExercises } from '../../artifacts/p2p-app-backend/src/modules/workoutGoal/workoutSplit.ts';

test('facility inventory intersects personal choices', () => {
  assert.deepEqual(resolveWorkoutEquipment(['dumbbells', 'cable_machine'], ['dumbbells', 'bench']), ['dumbbells']);
});
test('personal workouts retain selected equipment without an inventory', () => {
  assert.deepEqual(resolveWorkoutEquipment(['Dumbbell', 'dumbbells', 'Resistance Bands']), ['dumbbells', 'resistance_bands']);
});
test('empty inventory allows explicit bodyweight and rejects unavailable equipment', () => {
  assert.deepEqual(resolveWorkoutEquipment(['no_equipment'], []), ['bodyweight_only']);
  assert.throws(() => resolveWorkoutEquipment(['barbell'], []), /None of the selected/);
});
test('switching facilities cannot reuse unavailable selections', () => {
  assert.deepEqual(resolveWorkoutEquipment(['barbell'], ['barbell']), ['barbell']);
  assert.throws(() => resolveWorkoutEquipment(['barbell'], ['dumbbells']), /None of the selected/);
});
test('malformed equipment is rejected instead of widening access', () => {
  for (const value of [null, 'dumbbells', [3], [''], ['made_up']]) {
    assert.throws(() => normalizeEquipment(value));
  }
  assert.throws(() => resolveWorkoutEquipment([]));
  assert.throws(() => resolveWorkoutEquipment(['dumbbells'], null));
});
test('compound exercise requirements must all be available', () => {
  for (const label of ['Dumbbell + Bench', 'Dumbbells and bench', 'Dumbbell/Bench', 'Dumbbell, Bench']) {
    assert.equal(exerciseMatchesEquipment(label, ['dumbbells']), false);
    assert.equal(exerciseMatchesEquipment(label, ['dumbbells', 'bench']), true);
  }
});
test('others and unknown metadata never bypass filtering', () => {
  assert.equal(exerciseMatchesEquipment('barbell', ['others']), false);
  assert.equal(exerciseMatchesEquipment('others', ['others']), false);
  assert.equal(exerciseMatchesEquipment(undefined, ['dumbbells']), false);
  assert.equal(exerciseMatchesEquipment('smith machine', ['machines']), false);
  assert.equal(exerciseMatchesEquipment('cable_machine', ['machines']), false);
});
test('bodyweight remains possible alongside selected physical equipment', () => {
  assert.equal(exerciseMatchesEquipment('Bodyweight', ['dumbbells']), true);
  assert.equal(exerciseMatchesEquipment('barbell', ['bodyweight_only']), false);
  assert.equal(exerciseMatchesEquipment('bodyweight + pull up bar', ['bodyweight_only']), false);
});
test('split days match the intended body parts', () => {
  for (const [muscle, day] of [['chest','Push A'],['biceps','Pull B'],['quadriceps','Legs Hypertrophy'],['abs','Conditioning + Core'],['glutes','Lower B'],['back','Upper Strength']]) {
    assert.equal(exerciseMatchesSplitDay(muscle, day), true, `${muscle}: ${day}`);
  }
  assert.equal(exerciseMatchesSplitDay('chest', 'Legs'), false);
  assert.equal(exerciseMatchesSplitDay('quadriceps', 'Push'), false);
  assert.equal(exerciseMatchesSplitDay('back', 'Push'), false);
  assert.equal(exerciseMatchesSplitDay(undefined, 'Legs'), false);
});
test('full-body and combined splits support multiple muscle groups', () => {
  assert.equal(exerciseMatchesSplitDay('glutes', 'Total-Body Strength'), true);
  assert.equal(exerciseMatchesSplitDay('chest', 'Full Body A'), true);
  assert.equal(exerciseMatchesSplitDay('triceps', 'Shoulders + Arms'), true);
  assert.equal(exerciseMatchesSplitDay('legs', 'Shoulders + Arms'), false);
  assert.equal(splitDayMuscles('Unrecognized day'), null);
});

test('fallback day selection removes duplicates and off-target exercises', () => {
  const library = [
    { _id: '1', muscleGroup: 'chest' },
    { _id: '2', muscleGroup: 'quads' },
    { _id: '2', muscleGroup: 'quads' },
    { _id: '3', muscleGroup: 'glutes' },
  ];
  assert.deepEqual(selectSplitDayExercises(library, 'Legs', 0, 4).map(e => e._id), ['2', '3']);
  assert.throws(() => selectSplitDayExercises(library, 'Push', 0, 4), /Not enough approved/);
  assert.throws(() => selectSplitDayExercises(library, 'Unknown', 0, 4), /Not enough approved/);
});
test('lower back focus does not turn into a leg day', () => {
  assert.equal(exerciseMatchesSplitDay('back', 'Lower back + Core'), true);
  assert.equal(exerciseMatchesSplitDay('quads', 'Lower back + Core'), false);
});
