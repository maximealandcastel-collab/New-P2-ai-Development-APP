import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/features/home/data/models/trainer_dashboard_stats_model.dart';
import 'package:pler_to_pler_app/features/home/data/repositories/trainer_dashboard_repository.dart';

class TrainerDashboardService {
  final TrainerDashboardRepository _repository;

  TrainerDashboardService({required TrainerDashboardRepository repository})
      : _repository = repository;

  Future<TrainerDashboardStatsModel> getDashboardStats() async {
    try {
      return await _repository.getDashboardStats();
    } on AppException {
      if (_repository.hasCache()) {
        return _repository.getCachedDashboardStats()!;
      }
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  bool hasCache() {
    return _repository.hasCache();
  }

  TrainerDashboardStatsModel? getCachedDashboardStats() {
    return _repository.getCachedDashboardStats();
  }
}
