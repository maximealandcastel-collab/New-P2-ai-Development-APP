import 'package:flutter_test/flutter_test.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/workout_model.dart';

void main() {
  test('workout history deduplicates server IDs while preserving order', () {
    final result = WorkoutModel.dedupeById([
      WorkoutModel(id: 'a'),
      WorkoutModel(id: 'b'),
      WorkoutModel(id: 'a'),
      WorkoutModel(id: 'c'),
    ]);

    expect(result.map((workout) => workout.id), ['a', 'b', 'c']);
  });

  test('pagination excludes IDs already rendered', () {
    final result = WorkoutModel.dedupeById(
      [WorkoutModel(id: 'a'), WorkoutModel(id: 'b')],
      excludingIds: {'a'},
    );

    expect(result.map((workout) => workout.id), ['b']);
  });

  test('records without IDs are not silently discarded', () {
    final result = WorkoutModel.dedupeById([
      WorkoutModel(),
      WorkoutModel(),
    ]);

    expect(result, hasLength(2));
  });
}
