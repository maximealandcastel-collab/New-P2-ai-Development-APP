import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/workout_model.dart';
import 'package:pler_to_pler_app/features/user/workout/data/repositories/workout_repository.dart';

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

  Future<void> startWorkout(String workoutId) {
    return _repository.startWorkout(workoutId);
  }

  Future<void> completeExercise(String workoutId, String exerciseId) {
    return _repository.completeExercise(workoutId, exerciseId);
  }
}
