import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/controllers/workout_controller.dart';

class UserHomeController extends GetxController {
  UserHomeController({required WorkoutController workoutController})
      : _workoutController = workoutController;

  final WorkoutController _workoutController;

  static UserHomeController get to => Get.find();

  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;

  LoadingState get loadingState => _loadingState.value;

  bool get showShimmer =>
      _loadingState.value == LoadingState.initial ||
      _loadingState.value.isLoading;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData({bool isRefresh = false}) async {
    if (!isRefresh && _loadingState.value.isLoading) return;

    if (!isRefresh) {
      _loadingState.value = LoadingState.loading;
    }

    try {
      await Future.wait([
        _workoutController.fetchTodayWorkout(silent: true),
        _workoutController.fetchTodayOverview(silent: true),
        if (Get.isRegistered<ProfileController>()) ProfileController.to.loadData(),
      ]);
    } catch (e) {
      if (kDebugMode) debugPrint('UserHome loadData error: $e');
    } finally {
      _loadingState.value = LoadingState.loaded;
    }
  }

  @override
  Future<void> refresh() => loadData(isRefresh: true);
}
