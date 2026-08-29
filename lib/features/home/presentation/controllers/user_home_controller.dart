import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/workout_model.dart';
import 'package:pler_to_pler_app/features/home/data/models/trainer_workout_plan_model.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/workout_today_overview_model.dart';
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

  Rxn<WorkoutTodayOverviewModel> get todayOverview =>
      _workoutController.todayOverview;

  WorkoutAiPlanModel? get plan => _workoutController.plan;

  void openFullWorkoutPlan() => _workoutController.openFullWorkoutPlan();

  TrainerWorkoutPlanModel? get trainerPlan => _workoutController.trainerPlan;
  bool get hasTrainerPlan => _workoutController.hasTrainerPlan;

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
        _workoutController.fetchTrainerPlan(silent: true),
        _workoutController.fetchTodayOverview(silent: true),
        _workoutController.fetchMonthlyProgression(silent: true),
        // Resolved unconditionally, not behind Get.isRegistered.
        //
        // ProfileController is registered lazyPut, and isRegistered() reports
        // false for a lazy binding until something first resolves it. This
        // runs from UserHomeScreen.build(), before FeedAppBar has built and
        // touched ProfileController.to — so the guard was always false and the
        // profile was never loaded as part of the dashboard's load. That is why
        // the greeting sat on "Hi there!" while the profile screen, which
        // resolves the controller itself, showed the real name.
        //
        // Get.find on a lazyPut binding creates the instance, so this both
        // registers it and pulls fresh data into the same await as everything
        // else on the screen.
        Get.find<ProfileController>().loadData(),
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
