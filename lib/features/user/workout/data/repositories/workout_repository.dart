import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/services/api_service.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/workout_model.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/workout_today_overview_model.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/workout_progression_model.dart';

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

  Future<List<WorkoutModel>> getWorkouts({
    String? status,
    required int page,
    required int limit,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.workouts(status: status, page: page, limit: limit),
      );
      return WorkoutModel.listFromResponse(response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<WorkoutModel> getWorkoutById(String workoutId) async {
    try {
      final response = await _apiService.get(ApiConstants.workoutById(workoutId));
      return WorkoutModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<WorkoutTodayOverviewModel?> getTodayOverview() async {
    try {
      final response = await _apiService.get(ApiConstants.workoutTodayOverview);
      final data = response.data;
      if (data == null) return null;

      final payload = data is Map ? Map<String, dynamic>.from(data) : null;
      if (payload == null || payload['data'] == null) return null;

      return WorkoutTodayOverviewModel.fromJson(payload);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<List<WorkoutProgressionModel>> getMonthlyProgression() async {
    try {
      final response = await _apiService.get(ApiConstants.workoutProgressionMonthly);
      final data = response.data;
      if (data == null) return [];

      final payload = data is Map ? Map<String, dynamic>.from(data) : null;
      if (payload == null || payload['data'] == null) return [];

      final list = payload['data'] as List;
      return WorkoutProgressionModel.listFromJson(list);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<WorkoutModel?> getTodayWorkout() async {
    try {
      final response = await _apiService.get(ApiConstants.workoutToday);
      final data = response.data;
      if (data == null) return null;

      final payload = data is Map ? Map<String, dynamic>.from(data) : null;
      if (payload == null || payload['data'] == null) return null;

      return WorkoutModel.fromJson(payload);
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

  Future<void> completeWorkout(
    String workoutId, {
    required String checkInResponse,
    required int actualDurationMinutes,
  }) async {
    try {
      await _apiService.post(
        ApiConstants.workoutExerciseComplete(workoutId),
        data: {
          'checkInResponse': checkInResponse,
          'actualDurationMinutes': actualDurationMinutes,
        },
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<void> completeExercise(String workoutId, String exerciseId) async {
    try {
      await _apiService.patch(
        ApiConstants.workoutComplete(workoutId, exerciseId),
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }
}
