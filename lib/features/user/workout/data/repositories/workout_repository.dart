import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/services/api_service.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/workout_model.dart';

class WorkoutRepository {
  WorkoutRepository({required ApiService apiService}) : _apiService = apiService;

  final ApiService _apiService;

  Future<WorkoutModel> createWorkout(Map<String, dynamic> body) async {
    try {
      final response = await _apiService.post(ApiConstants.workout, data: body);
      return WorkoutModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<WorkoutModel> generateWorkout(String workoutId) async {
    try {
      final response = await _apiService.post(
        ApiConstants.workoutGenerate(workoutId),
      );
      return WorkoutModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<void> startWorkout(String workoutId) async {
    try {
      await _apiService.patch(ApiConstants.workoutStart(workoutId));
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<void> completeExercise(String workoutId, String exerciseId) async {
    try {
      await _apiService.patch(
        ApiConstants.workoutExerciseComplete(workoutId, exerciseId),
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }
}
