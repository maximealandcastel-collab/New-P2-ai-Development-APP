import 'package:pler_to_pler_app/features/user/workout/data/repositories/workout_repository.dart';

class WorkoutService {
  WorkoutService({required WorkoutRepository repository})
      : _repository = repository;

  final WorkoutRepository _repository;

  Future<void> createWorkout(Map<String, dynamic> body) {
    return _repository.createWorkout(body);
  }
}
