import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/workout_model.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/workout_today_overview_model.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/workout_progression_model.dart';
import 'package:pler_to_pler_app/features/user/workout/data/repositories/workout_repository.dart';
import 'package:pler_to_pler_app/features/home/data/models/trainer_workout_plan_model.dart';

class WorkoutService {
  WorkoutService({required WorkoutRepository repository})
      : _repository = repository;

  final WorkoutRepository _repository;

  Future<WorkoutModel> createWorkout(Map<String, dynamic> body) {
    return _repository.createWorkout(body);
  }

  Future<WorkoutModel> generateWorkout(String workoutId) {
    return _repository.generateWorkout(workoutId);
  }

  Future<WorkoutModel> createAndGenerateWorkout(Map<String, dynamic> body) async {
    final created = await _repository.createWorkout(body);
    final workoutId = created.id;
    if (workoutId == null || workoutId.isEmpty) {
      throw UnknownException('Workout id missing from response');
    }
    return _repository.generateWorkout(workoutId);
  }

  Future<WorkoutModel?> getTodayWorkout() {
    return _repository.getTodayWorkout();
  }

  Future<WorkoutTodayOverviewModel?> getTodayOverview() {
    return _repository.getTodayOverview();
  }

  Future<List<WorkoutProgressionModel>> getMonthlyProgression() {
    return _repository.getMonthlyProgression();
  }

  Future<List<WorkoutModel>> getWorkouts({
    String? status,
    required int page,
    required int limit,
  }) {
    return _repository.getWorkouts(
      status: status,
      page: page,
      limit: limit,
    );
  }

  Future<WorkoutModel> getWorkoutById(String workoutId) {
    return _repository.getWorkoutById(workoutId);
  }

  /// Dismisses/removes a workout from history.
  Future<void> deleteWorkout(String workoutId) {
    return _repository.deleteWorkout(workoutId);
  }

  /// Re-runs AI generation for a workout that was created but never got a
  /// plan (e.g. generation failed the first time and left an empty stub).
  Future<WorkoutModel> retryGeneration(String workoutId) {
    return _repository.generateWorkout(workoutId);
  }

  Future<void> startWorkout(String workoutId) {
    return _repository.startWorkout(workoutId);
  }

  Future<void> completeWorkout(
    String workoutId, {
    required String checkInResponse,
    required int actualDurationMinutes,
  }) {
    return _repository.completeWorkout(
      workoutId,
      checkInResponse: checkInResponse,
      actualDurationMinutes: actualDurationMinutes,
    );
  }

  Future<void> completeExercise(String workoutId, String exerciseId) {
    return _repository.completeExercise(workoutId, exerciseId);
  }

  Future<TrainerWorkoutPlanModel?> getTrainerPlan() {
    return _repository.getTrainerPlan();
  }
}
