import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/services/connectivity_service.dart';
import 'package:pler_to_pler_app/core/services/paginated_list.dart';
import 'package:pler_to_pler_app/core/services/paginated_loader_ui.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/workout_model.dart';
import 'package:pler_to_pler_app/features/user/workout/domain/services/workout_service.dart';

class HistoryController extends GetxController with PaginatedLoaderUi {
  HistoryController({
    required WorkoutService service,
    required ConnectivityService connectivityService,
  })  : _service = service,
        _connectivityService = connectivityService;

  final WorkoutService _service;
  final ConnectivityService _connectivityService;

  static HistoryController get to => Get.find();

  static const _tabStatuses = <String?>[null, 'pending', 'completed'];

  final RxInt _selectedTab = 0.obs;
  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;
  final Map<int, List<WorkoutModel>> _tabCache = {};

  late final PaginatedList<WorkoutModel> workoutsList;

  int get selectedTab => _selectedTab.value;
  LoadingState get loadingState => _loadingState.value;
  List<WorkoutModel> get workouts => workoutsList.items;
  ScrollController? get scrollController => workoutsList.scrollController;

  String? get currentStatus => _tabStatuses[selectedTab];

  @override
  LoadingState get paginationContentState => loadingState;

  @override
  PaginatedList<dynamic> get paginatedList => workoutsList;

  @override
  void onInit() {
    super.onInit();
    workoutsList = PaginatedList<WorkoutModel>(
      limit: 5,
      fetchPage: _fetchWorkoutsPage,
    );
    workoutsList.initScroll();
    ever(_connectivityService.isConnected, (isConnected) {
      if (isConnected) _loadData();
    });
    _loadData();
  }

  Future<List<WorkoutModel>> _fetchWorkoutsPage(int page, int limit) {
    return _service.getWorkouts(
      status: currentStatus,
      page: page,
      limit: limit,
    );
  }

  void onTabSelected(int index) {
    if (_selectedTab.value == index) return;
    _selectedTab.value = index;
    _loadData();
  }

  List<WorkoutModel> _getCachedWorkouts(int tabIndex) =>
      List<WorkoutModel>.from(_tabCache[tabIndex] ?? const []);

  void _cacheCurrentTab() {
    _tabCache[selectedTab] = List<WorkoutModel>.from(workoutsList.items);
  }

  Future<void> _loadData({bool showFullLoader = true}) async {
    try {
      final isOnline = _connectivityService.isConnected.value;
      final hasCachedData = _tabCache.containsKey(selectedTab);
      final cached = _getCachedWorkouts(selectedTab);

      if (showFullLoader) {
        if (hasCachedData) {
          workoutsList.items.value = cached;
          _loadingState.value = LoadingState.loaded;
        } else {
          workoutsList.items.clear();
          _loadingState.value = LoadingState.loading;
        }
      }

      if (!isOnline) {
        if (!hasCachedData && workoutsList.items.isEmpty) {
          _loadingState.value = LoadingState.offline;
        }
        return;
      }

      try {
        await workoutsList.loadFirst();
        _cacheCurrentTab();
        _loadingState.value = LoadingState.loaded;
      } on AppException catch (e) {
        if (!hasCachedData && workoutsList.items.isEmpty) {
          _loadingState.value = LoadingState.error;
        }
        if (kDebugMode) debugPrint('fetchWorkoutHistory error: $e');
      }
    } catch (e) {
      if (!_tabCache.containsKey(selectedTab) && workoutsList.items.isEmpty) {
        _loadingState.value = LoadingState.error;
      }
      if (kDebugMode) debugPrint('fetchWorkoutHistory error: $e');
    }
  }

  @override
  Future<void> refresh() =>
      workoutsList.refreshWith(() => _loadData(showFullLoader: false));

  void openWorkoutDetails(WorkoutModel workout) {
    final workoutId = workout.id;
    if (workoutId == null || workoutId.isEmpty) {
      ToastMessageHelper.show('Workout id not found');
      return;
    }

    Get.toNamed(AppRoute.workoutPlanDetailsScreen, arguments: workoutId);
  }

  @override
  void onClose() {
    workoutsList.dispose();
    super.onClose();
  }
}
