import 'package:flutter_test/flutter_test.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/workout_model.dart';

void main() {
  test('only pending workouts without main exercises are retryable stubs', () {
    expect(WorkoutModel(status: 'pending').isEmptyGenerationStub, isTrue);
    expect(
      WorkoutModel(
        status: 'pending',
        aiPlan: WorkoutAiPlanModel(mainWork: []),
      ).isEmptyGenerationStub,
      isTrue,
    );
    expect(
      WorkoutModel(
        status: 'pending',
        aiPlan: WorkoutAiPlanModel(mainWork: [WorkoutExerciseModel()]),
      ).isEmptyGenerationStub,
      isFalse,
    );
    expect(WorkoutModel(status: 'completed').isEmptyGenerationStub, isFalse);
  });
}
