import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:pler_to_pler_app/features/contents/presentation/arguments/video_player_args.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/workout_model.dart';
import 'package:pler_to_pler_app/features/home/data/models/trainer_workout_plan_model.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/workout_today_overview_model.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/workout_progression_model.dart';
import 'package:pler_to_pler_app/features/user/workout/domain/services/workout_service.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class WorkoutController extends GetxController {
  WorkoutController({required WorkoutService service}) : _service = service;

  final WorkoutService _service;

  static WorkoutController get to => Get.find();

  final formKey = GlobalKey<FormState>();
  final checkInResponseController = TextEditingController();
  final actualDurationController = TextEditingController();
  final Rxn<WorkoutModel> workoutDetails = Rxn<WorkoutModel>();
  final Rxn<WorkoutTodayOverviewModel> todayOverview = Rxn<WorkoutTodayOverviewModel>();
  final RxList<WorkoutProgressionModel> monthlyProgression = <WorkoutProgressionModel>[].obs;
  final Rxn<TrainerWorkoutPlanModel> _trainerPlan = Rxn<TrainerWorkoutPlanModel>();
  String? _detailsWorkoutId;

  String? get detailsWorkoutId => _detailsWorkoutId;

  final Rx<LoadingState> _submitLoadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _generateLoadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _todayWorkoutLoadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _todayOverviewLoadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _monthlyProgressionLoadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _detailsLoadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _startSessionLoadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _completeSessionLoadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _completeExerciseLoadingState =
      LoadingState.initial.obs;

  LoadingState get submitLoadingState => _submitLoadingState.value;
  LoadingState get generateLoadingState => _generateLoadingState.value;
  LoadingState get todayWorkoutLoadingState => _todayWorkoutLoadingState.value;
  LoadingState get todayOverviewLoadingState => _todayOverviewLoadingState.value;
  LoadingState get monthlyProgressionLoadingState => _monthlyProgressionLoadingState.value;
  LoadingState get detailsLoadingState => _detailsLoadingState.value;
  LoadingState get startSessionLoadingState => _startSessionLoadingState.value;
  LoadingState get completeSessionLoadingState =>
      _completeSessionLoadingState.value;
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

  bool get hasTodayWorkout =>
      workoutDetails.value != null && (plan?.mainWork?.isNotEmpty ?? false);

  bool get hasTodayOverview => todayOverview.value != null;
  TrainerWorkoutPlanModel? get trainerPlan => _trainerPlan.value;
  bool get hasTrainerPlan => _trainerPlan.value != null;

  bool get isSessionInProgress =>
      workoutDetails.value?.status == 'in_progress';

  bool get isWorkoutCompleted => workoutDetails.value?.status == 'completed';

  bool get showSessionButton => !isWorkoutCompleted;

  bool get hasVideo {
    final video = plan?.suggestedVideo?.trim() ?? '';
    return video.isNotEmpty;
  }

  Future<void> fetchTodayWorkout({bool silent = false}) async {
    if (!silent) {
      if (_todayWorkoutLoadingState.value.isLoading) return;
      _todayWorkoutLoadingState.value = LoadingState.loading;
    }

    try {
      final workout = await _service.getTodayWorkout();
      if (workout != null) {
        initWorkoutDetails(workout);
      }
      if (!silent) {
        _todayWorkoutLoadingState.value = LoadingState.loaded;
      }
    } catch (e) {
      if (!silent) {
        _todayWorkoutLoadingState.value = LoadingState.error;
      }
      if (kDebugMode) debugPrint('fetchTodayWorkout error: $e');
    }
  }

  Future<void> fetchTodayOverview({bool silent = false}) async {
    if (!silent) {
      if (_todayOverviewLoadingState.value.isLoading) return;
      _todayOverviewLoadingState.value = LoadingState.loading;
    }

    try {
      todayOverview.value = await _service.getTodayOverview();
      if (!silent) {
        _todayOverviewLoadingState.value = LoadingState.loaded;
      }
    } catch (e) {
      if (!silent) {
        _todayOverviewLoadingState.value = LoadingState.error;
      }
      if (kDebugMode) debugPrint('fetchTodayOverview error: $e');
    }
  }

  Future<void> fetchMonthlyProgression({bool silent = false}) async {
    if (!silent) {
      if (_monthlyProgressionLoadingState.value.isLoading) return;
      _monthlyProgressionLoadingState.value = LoadingState.loading;
    }

    try {
      final progression = await _service.getMonthlyProgression();
      monthlyProgression.assignAll(progression);
      if (!silent) {
        _monthlyProgressionLoadingState.value = LoadingState.loaded;
      }
    } catch (e) {
      if (!silent) {
        _monthlyProgressionLoadingState.value = LoadingState.error;
      }
      if (kDebugMode) debugPrint('fetchMonthlyProgression error: $e');
    }
  }

  void initWorkoutDetails(WorkoutModel workout) {
    workoutDetails.value = workout;
    _detailsWorkoutId = workout.id;
    _detailsLoadingState.value = LoadingState.loaded;
  }

  Future<void> fetchWorkoutById(
    String workoutId, {
    bool showLoading = true,
  }) async {
    if (showLoading) {
      if (_detailsLoadingState.value.isLoading) return;

      _detailsWorkoutId = workoutId;
      workoutDetails.value = null;
      _detailsLoadingState.value = LoadingState.loading;
    } else {
      _detailsWorkoutId = workoutId;
    }

    try {
      final workout = await _service.getWorkoutById(workoutId);
      initWorkoutDetails(workout);
    } catch (e) {
      if (showLoading) {
        _detailsLoadingState.value = LoadingState.error;
        ToastMessageHelper.show(e.errorMessage);
      }
      if (kDebugMode) debugPrint('fetchWorkoutById error: $e');
    }
  }

  Future<void> refreshWorkoutDetails() async {
    final workoutId = _detailsWorkoutId;
    if (workoutId == null || workoutId.isEmpty) return;
    await fetchWorkoutById(workoutId);
  }

  Future<void> refreshWorkoutDetailsSilently() async {
    final workoutId = _detailsWorkoutId;
    if (workoutId == null || workoutId.isEmpty) return;
    await fetchWorkoutById(workoutId, showLoading: false);
  }

  Future<void> refreshTodayOverviewSilently() async {
    try {
      todayOverview.value = await _service.getTodayOverview();
    } catch (e) {
      if (kDebugMode) debugPrint('refreshTodayOverviewSilently error: $e');
    }
  }

  void openFullWorkoutPlan() {
    final workoutId = workoutDetails.value?.id;
    if (workoutId == null || workoutId.isEmpty) {
      ToastMessageHelper.show('Workout plan not available');
      return;
    }

    Get.toNamed(
      AppRoute.workoutPlanDetailsScreen,
      arguments: workoutId,
    );
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
    // Backend requires every field to be non-empty.
    // Provide the same defaults WorkoutFindScreen uses so users who skip
    // a step don't get a silent failure from the backend.
    // Date must be date-only (YYYY-MM-DD) — backend rejects full ISO timestamps.
    return {
      'goal': selectedGoals.isEmpty
          ? ['general_fitness']
          : List<String>.from(selectedGoals),
      'focusArea': selectedFocusAreas.isEmpty
          ? ['full_body']
          : List<String>.from(selectedFocusAreas),
      'workout_environment': selectedEnvironments.isEmpty
          ? ['home']
          : List<String>.from(selectedEnvironments),
      'equipment_availablity': selectedEquipment.isEmpty
          ? ['no_equipment']
          : List<String>.from(selectedEquipment),
      'workout_intensity': selectedIntensities.isEmpty
          ? ['medium']
          : List<String>.from(selectedIntensities),
      'duration': selectedDuration.value,
      'date': DateTime.now().toUtc().toIso8601String().split('T').first,
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
      workoutDetails.value?.status = 'in_progress';
      workoutDetails.refresh();
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

  void showCompleteSessionDialog() {
    checkInResponseController.clear();
    actualDurationController.clear();

    Get.dialog(
      Obx(
        () => CustomDialog(
          title: 'Mark this session as completed',
          description: "Did you complete today's session? What loads did you use and how hard was it (RPE 1-10)? Any pain or equipment issues?",
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: checkInResponseController,
                contentPaddingVertical: 8.h,
                hintText: 'what did you do?',
                maxLines: 3,
                minLines: 3,
              ),
              SizedBox(height: 12.h),
              CustomTextField(
                controller: actualDurationController,
                hintText: 'actual duration (minutes)',
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          titleColor: AppColors.primary,
          rightButtonLabel: 'Complete',
          rightButtonBgColor: AppColors.primary,
          rightButtonLabelColor: AppColors.textWhite,
          isLoading: completeSessionLoadingState.isLoading,
          onTapLeftButton: () => Get.back(),
          onTapRightButton: completeSession,
        ),
      ),
      barrierDismissible: !completeSessionLoadingState.isLoading,
    );
  }

  Future<void> completeSession() async {
    final workoutId = workoutDetails.value?.id;
    if (workoutId == null || workoutId.isEmpty) {
      ToastMessageHelper.show('Workout id not found');
      return;
    }

    final checkInResponse = checkInResponseController.text.trim();
    if (checkInResponse.isEmpty) {
      ToastMessageHelper.show('Please describe what you did in this session');
      return;
    }

    final actualDurationMinutes = int.tryParse(
      actualDurationController.text.trim(),
    );
    if (actualDurationMinutes == null || actualDurationMinutes <= 0) {
      ToastMessageHelper.show('Please enter a valid duration in minutes');
      return;
    }

    if (_completeSessionLoadingState.value.isLoading) return;

    _completeSessionLoadingState.value = LoadingState.loading;

    try {
      await _service.completeWorkout(
        workoutId,
        checkInResponse: checkInResponse,
        actualDurationMinutes: actualDurationMinutes,
      );
      workoutDetails.value?.status = 'completed';
      workoutDetails.refresh();
      _completeSessionLoadingState.value = LoadingState.loaded;
      if (Get.isDialogOpen ?? false) Get.back();
      await refreshTodayOverviewSilently();
      ToastMessageHelper.show('Session completed');
      goHome();
    } catch (e) {
      _completeSessionLoadingState.value = LoadingState.error;
      ToastMessageHelper.show(e.errorMessage);
      if (kDebugMode) debugPrint('completeSession error: $e');
    }
  }

  void onSessionAction() {
    if (isSessionInProgress) {
      showCompleteSessionDialog();
      return;
    }
    startSession();
  }

  Future<void> completeExercise(WorkoutExerciseModel exercise) async {
    final workoutId = workoutDetails.value?.id;
    final exerciseId = exercise.exerciseId;

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
      _completeExerciseLoadingState.value = LoadingState.loaded;
      if (Get.isDialogOpen ?? false) Get.back();
      _markExerciseCompletedLocally(exerciseId);
      await refreshWorkoutDetailsSilently();
      await refreshTodayOverviewSilently();
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
      if (exercise.exerciseId == exerciseId || exercise.id == exerciseId) {
        exercise.isCompleted = true;
        return;
      }
    }
  }

  Future<void> fetchTrainerPlan({bool silent = false}) async {
    try {
      _trainerPlan.value = await _service.getTrainerPlan();
    } catch (e) {
      if (kDebugMode) debugPrint('fetchTrainerPlan error: \$e');
    }
  }

    @override
  void onClose() {
    checkInResponseController.dispose();
    actualDurationController.dispose();
    super.onClose();
  }
}
