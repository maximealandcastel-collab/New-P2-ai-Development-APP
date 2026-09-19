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

  Future<List<WorkoutModel>> _fetchWorkoutsPage(int page, int limit) async {
    final fetched = await _service.getWorkouts(
      status: currentStatus,
      page: page,
      limit: limit,
    );

    // Protect the UI from repeated records if an older backend ignores page.
    // Returning an empty page also stops PaginatedList from requesting forever.
    final existingIds = page == 1
        ? <String>{}
        : workoutsList.items
            .map((workout) => workout.id)
            .whereType<String>()
            .toSet();
    return WorkoutModel.dedupeById(
      fetched,
      excludingIds: existingIds,
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
    final unique = WorkoutModel.dedupeById(workoutsList.items);
    workoutsList.items.value = unique;
    _tabCache[selectedTab] = List<WorkoutModel>.from(unique);
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

  final Set<String> _deletingWorkoutIds = <String>{};

  /// Removes every visible copy immediately, then asks the backend to delete
  /// the user-owned workout. Repeated taps are ignored and failures restore a
  /// single deduplicated snapshot.
  Future<void> dismissWorkout(WorkoutModel workout) async {
    final workoutId = workout.id;
    if (workoutId == null || workoutId.isEmpty) {
      ToastMessageHelper.show('Workout id not found');
      return;
    }
    if (!_deletingWorkoutIds.add(workoutId)) return;

    final snapshot = WorkoutModel.dedupeById(workoutsList.items);
    workoutsList.items.removeWhere((item) => item.id == workoutId);
    for (final entry in _tabCache.entries) {
      entry.value.removeWhere((item) => item.id == workoutId);
    }
    _cacheCurrentTab();

    try {
      await _service.deleteWorkout(workoutId);
      ToastMessageHelper.show('Workout removed.');
    } on AppException catch (e) {
      // DELETE is idempotent from the user's perspective: if it is already
      // absent on the server, the desired result has still been reached.
      if (!e.message.toLowerCase().contains('not found')) {
        workoutsList.items.value = snapshot;
        _cacheCurrentTab();
        ToastMessageHelper.show(e.message);
      }
    } catch (_) {
      workoutsList.items.value = snapshot;
      _cacheCurrentTab();
      ToastMessageHelper.show('Could not remove that workout. Try again.');
    } finally {
      _deletingWorkoutIds.remove(workoutId);
    }
  }

  /// Re-runs AI generation for a workout stuck as an empty "0/0" stub
  /// (created, but generation never actually produced a plan).
  Future<void> retryGeneration(WorkoutModel workout) async {
    final workoutId = workout.id;
    if (workoutId == null || workoutId.isEmpty) {
      ToastMessageHelper.show('Workout id not found');
      return;
    }

    final index = workoutsList.items.indexOf(workout);
    try {
      final regenerated = await _service.retryGeneration(workoutId);
      if (index != -1) {
        workoutsList.items[index] = regenerated;
        _cacheCurrentTab();
      }
      ToastMessageHelper.show('Workout regenerated.');
    } on AppException catch (e) {
      ToastMessageHelper.show(e.message);
    } catch (_) {
      ToastMessageHelper.show('Could not regenerate this workout. Try again.');
    }
  }

  @override
  void onClose() {
    workoutsList.dispose();
    super.onClose();
  }
}
