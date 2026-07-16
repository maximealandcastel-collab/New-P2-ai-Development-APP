import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/constants/app_constants.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/services/api_service.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:pler_to_pler_app/features/home/data/models/trainer_dashboard_stats_model.dart';

class TrainerDashboardRepository {
  final ApiService _apiService;
  final CacheService _cacheService;

  TrainerDashboardRepository({
    required ApiService apiService,
    required CacheService cacheService,
  })  : _apiService = apiService,
        _cacheService = cacheService;

  Future<TrainerDashboardStatsModel> getDashboardStats() async {
    try {
      final response = await _apiService.get(ApiConstants.trainerDashboardStats);
      final model = TrainerDashboardStatsModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );

      // Cache successful response data
      await _cacheService.put(
        AppConstants.cacheTrainerDashboard,
        model.toJson(),
      );

      return model;
    } on AppException {
      if (hasCache()) {
        return getCachedDashboardStats()!;
      }
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  bool hasCache() {
    return _cacheService.containsKey(AppConstants.cacheTrainerDashboard);
  }

  TrainerDashboardStatsModel? getCachedDashboardStats() {
    try {
      final cachedJson = _cacheService.get<Map>(AppConstants.cacheTrainerDashboard);
      if (cachedJson == null) return null;
      return TrainerDashboardStatsModel.fromJson(
        Map<String, dynamic>.from(cachedJson),
      );
    } catch (_) {
      return null;
    }
  }
}
