import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/services/connectivity_service.dart';
import 'package:pler_to_pler_app/features/home/data/models/trainer_dashboard_stats_model.dart';
import 'package:pler_to_pler_app/features/home/domain/services/trainer_dashboard_service.dart';
import 'package:pler_to_pler_app/features/home/data/models/trainer_client_plan_model.dart';
import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/services/api_service.dart';

class TrainerHomeController extends GetxController {
  TrainerHomeController({
    required TrainerDashboardService service,
    required ConnectivityService connectivityService,
    required ApiService apiService,
  })  : _service = service,
        _connectivityService = connectivityService,
        _apiService = apiService;

  final TrainerDashboardService _service;
  final ConnectivityService _connectivityService;
  final ApiService _apiService;

  static TrainerHomeController get to => Get.find();

  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;
  LoadingState get loadingState => _loadingState.value;

  bool get showShimmer =>
      _loadingState.value == LoadingState.initial ||
      _loadingState.value.isLoading;

  final Rxn<TrainerDashboardStatsModel> _dashboardStats = Rxn<TrainerDashboardStatsModel>();
  TrainerDashboardStatsModel? get dashboardStats => _dashboardStats.value;

  @override
  void onInit() {
    super.onInit();
    
    // Listen to connectivity changes to reload when coming back online
    ever(_connectivityService.isConnected, (isConnected) {
      if (isConnected) loadData();
    });
    
    loadData();
  }

  Future<void> loadData({bool isRefresh = false}) async {
    if (!isRefresh && _loadingState.value.isLoading) return;

    final hasUsableCache = _service.hasCache();
    final isOnline = _connectivityService.isConnected.value;

    if (!isRefresh) {
      if (hasUsableCache) {
        _dashboardStats.value = _service.getCachedDashboardStats();
        _loadingState.value = LoadingState.loaded;
      } else {
        _loadingState.value = LoadingState.loading;
      }
    }

    if (!isOnline) {
      if (!hasUsableCache) {
        _loadingState.value = LoadingState.offline;
      }
      return;
    }

    try {
      final stats = await _service.getDashboardStats();
      _dashboardStats.value = stats;
      fetchClientPlans();
      _loadingState.value = LoadingState.loaded;
    } catch (e) {
      if (!hasUsableCache) {
        _loadingState.value = LoadingState.error;
      }
      if (kDebugMode) {
        debugPrint('TrainerHomeController loadData error: $e');
      }
    }
  }

  @override
  Future<void> refresh() => loadData(isRefresh: true);

  Future<void> fetchClientPlans() async {
    try {
      final response = await _apiService.get(ApiConstants.trainerMyWorkoutPlans);
      final data = response.data;
      if (data == null) return;
      final payload = data is Map ? Map<String, dynamic>.from(data) : null;
      if (payload == null) return;
      _clientPlans.assignAll(TrainerClientPlanModel.listFromApiResponse(payload));
    } catch (e) {
      if (kDebugMode) debugPrint('fetchClientPlans error: $e');
    }
  }
}
