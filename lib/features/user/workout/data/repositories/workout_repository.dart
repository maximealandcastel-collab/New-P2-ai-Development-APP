import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/services/api_service.dart';

class WorkoutRepository {
  WorkoutRepository({required ApiService apiService}) : _apiService = apiService;

  final ApiService _apiService;

  Future<void> createWorkout(Map<String, dynamic> body) async {
    try {
      await _apiService.post(ApiConstants.workout, data: body);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }
}
