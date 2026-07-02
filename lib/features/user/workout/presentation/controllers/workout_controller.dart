import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:pler_to_pler_app/features/contents/presentation/arguments/video_player_args.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/workout_model.dart';
import 'package:pler_to_pler_app/features/user/workout/domain/services/workout_service.dart';

class WorkoutController extends GetxController {
  WorkoutController({required WorkoutService service}) : _service = service;

  final WorkoutService _service;

  static WorkoutController get to => Get.find();

  final formKey = GlobalKey<FormState>();
  final Rxn<WorkoutModel> workoutDetails = Rxn<WorkoutModel>();

  final Rx<LoadingState> _submitLoadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _generateLoadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _startSessionLoadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _completeExerciseLoadingState =
      LoadingState.initial.obs;

  LoadingState get submitLoadingState => _submitLoadingState.value;
  LoadingState get generateLoadingState => _generateLoadingState.value;
  LoadingState get startSessionLoadingState => _startSessionLoadingState.value;
  LoadingState get completeExerciseLoadingState =>
      _completeExerciseLoadingState.value;

  final RxList<String> selectedGoals = <String>[].obs;
  final RxList<String> selectedFocusAreas = <String>[].obs;
  final RxList<String> selectedEnvironments = <String>[].obs;
  final RxList<String> selectedEquipment = <String>[].obs;
  final RxList<String> selectedIntensities = <String>[].obs;
  final RxInt selectedDuration = 10.obs;

  final DateTime workoutDate = DateTime.now().toUtc();

  static const int pageCount = 5;

  WorkoutAiPlanModel? get plan => workoutDetails.value?.aiPlan;

  bool get hasVideo {
    final video = plan?.suggestedVideo?.trim() ?? '';
    return video.isNotEmpty;
  }

  void initWorkoutDetails(WorkoutModel workout) {
    workoutDetails.value = workout;
  }

  void onGoalsChanged(List<String> values) {
    selectedGoals.assignAll(values);
  }

  void onFocusAreasChanged(List<String> values) {
    selectedFocusAreas.assignAll(values);
  }

  void onEnvironmentsChanged(List<String> values) {
    selectedEnvironments.assignAll(values);
  }

  void onEquipmentChanged(List<String> values) {
    selectedEquipment.assignAll(values);
  }

  void onIntensitySelected(String value) {
    selectedIntensities.assignAll([value]);
  }

  void onDurationSelected(int value) {
    selectedDuration.value = value;
  }

  bool validateStep(int step) {
    switch (step) {
      case 0:
        return selectedGoals.isNotEmpty;
      case 1:
        return selectedFocusAreas.isNotEmpty;
      case 2:
        return selectedEnvironments.isNotEmpty;
      case 3:
        return selectedEquipment.isNotEmpty;
      case 4:
        return selectedIntensities.isNotEmpty;
      default:
        return true;
    }
  }

  void showStepValidationMessage(int step) {
    switch (step) {
      case 0:
        ToastMessageHelper.show('Please select at least one goal');
      case 1:
        ToastMessageHelper.show('Please select at least one focus area');
      case 2:
        ToastMessageHelper.show('Please select at least one workout environment');
      case 3:
        ToastMessageHelper.show('Please select at least one equipment option');
      case 4:
        ToastMessageHelper.show('Please select workout intensity');
    }
  }

  Map<String, dynamic> _buildBody() {
    return {
      'goal': List<String>.from(selectedGoals),
      'focusArea': List<String>.from(selectedFocusAreas),
      'workout_environment': List<String>.from(selectedEnvironments),
      'equipment_availablity': List<String>.from(selectedEquipment),
      'workout_intensity': List<String>.from(selectedIntensities),
      'duration': selectedDuration.value,
      'date': workoutDate.toIso8601String(),
    };
  }

  Future<void> submit() async {
    if (_submitLoadingState.value.isLoading) return;

    _submitLoadingState.value = LoadingState.loading;

    try {
      await Get.offNamed(
        AppRoute.workoutGeneratingScreen,
        arguments: _buildBody(),
      );
      _submitLoadingState.value = LoadingState.loaded;
    } catch (e) {
      _submitLoadingState.value = LoadingState.error;
      ToastMessageHelper.show(e.errorMessage);
      if (kDebugMode) debugPrint('submitWorkout error: $e');
    }
  }

  Future<void> generateWorkout() async {
    if (_generateLoadingState.value.isLoading) return;

    final arguments = Get.arguments;
    if (arguments is! Map<String, dynamic>) {
      _handleGenerateFailure('Invalid workout data');
      return;
    }

    _generateLoadingState.value = LoadingState.loading;

    try {
      final workout = await _service.createAndGenerateWorkout(arguments);
      initWorkoutDetails(workout);
      _generateLoadingState.value = LoadingState.loaded;
      Get.offNamed(AppRoute.workoutPlanDetailsScreen, arguments: workout);
    } catch (e) {
      _generateLoadingState.value = LoadingState.error;
      _handleGenerateFailure(e.errorMessage);
      if (kDebugMode) debugPrint('generateWorkout error: $e');
    }
  }

  void _handleGenerateFailure(String message) {
    ToastMessageHelper.show(message);
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    }
  }

  Future<void> startSession() async {
    final workoutId = workoutDetails.value?.id;
    if (workoutId == null || workoutId.isEmpty) {
      ToastMessageHelper.show('Workout id not found');
      return;
    }

    if (_startSessionLoadingState.value.isLoading) return;

    _startSessionLoadingState.value = LoadingState.loading;

    try {
      await _service.startWorkout(workoutId);
      _startSessionLoadingState.value = LoadingState.loaded;
      goHome();
    } catch (e) {
      _startSessionLoadingState.value = LoadingState.error;
      ToastMessageHelper.show(e.errorMessage);
      if (kDebugMode) debugPrint('startWorkout error: $e');
    }
  }

  void goHome() {
    if (Get.isRegistered<BottomNavBarController>()) {
      BottomNavBarController.to.resetIndex();
    }
    Get.offAllNamed(AppRoute.bottonNavBar);
  }

  void watchVideo() {
    final videoUrl = plan?.suggestedVideo?.trim();
    if (videoUrl == null || videoUrl.isEmpty) return;

    VideoPlayerArgs.open(
      videoUrl: videoUrl,
      title: 'Workout video',
    );
  }

  Future<void> completeExercise(WorkoutExerciseModel exercise) async {
    final workoutId = workoutDetails.value?.id;
    final exerciseId = exercise.id ?? exercise.exerciseId;

    if (workoutId == null ||
        workoutId.isEmpty ||
        exerciseId == null ||
        exerciseId.isEmpty) {
      ToastMessageHelper.show('Exercise details not found');
      return;
    }

    if (_completeExerciseLoadingState.value.isLoading) return;

    _completeExerciseLoadingState.value = LoadingState.loading;

    try {
      await _service.completeExercise(workoutId, exerciseId);
      _markExerciseCompletedLocally(exerciseId);
      _completeExerciseLoadingState.value = LoadingState.loaded;
      if (Get.isDialogOpen ?? false) Get.back();
      ToastMessageHelper.show('Exercise marked as completed');
    } catch (e) {
      _completeExerciseLoadingState.value = LoadingState.error;
      ToastMessageHelper.show(e.errorMessage);
      if (kDebugMode) debugPrint('completeExercise error: $e');
    }
  }

  void _markExerciseCompletedLocally(String exerciseId) {
    final plan = workoutDetails.value?.aiPlan;
    if (plan == null) return;

    _updateExerciseListCompletion(plan.mainWork, exerciseId);
    _updateExerciseListCompletion(plan.accessories, exerciseId);
    _updateExerciseListCompletion(plan.finisher, exerciseId);
    workoutDetails.refresh();
  }

  void _updateExerciseListCompletion(
    List<WorkoutExerciseModel>? exercises,
    String exerciseId,
  ) {
    if (exercises == null) return;

    for (final exercise in exercises) {
      final id = exercise.id ?? exercise.exerciseId;
      if (id == exerciseId) {
        exercise.isCompleted = true;
        return;
      }
    }
  }
}
