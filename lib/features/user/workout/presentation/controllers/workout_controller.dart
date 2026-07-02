import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/features/user/workout/domain/services/workout_service.dart';

class WorkoutController extends GetxController {
  WorkoutController({required WorkoutService service}) : _service = service;

  final WorkoutService _service;

  static WorkoutController get to => Get.find();

  final formKey = GlobalKey<FormState>();
  final RxBool isSubmitting = false.obs;

  final RxList<String> selectedGoals = <String>[].obs;
  final RxList<String> selectedFocusAreas = <String>[].obs;
  final RxList<String> selectedEnvironments = <String>[].obs;
  final RxList<String> selectedEquipment = <String>[].obs;
  final RxList<String> selectedIntensities = <String>[].obs;
  final RxInt selectedDuration = 10.obs;

  final DateTime workoutDate = DateTime.now().toUtc();

  static const int pageCount = 5;

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
    if (isSubmitting.value) return;

    isSubmitting.value = true;

    try {
      await _service.createWorkout(_buildBody());
      if (Get.key.currentState?.canPop() ?? false) {
        Get.back(result: true);
      }
    } catch (e) {
      ToastMessageHelper.show(e.errorMessage);
      if (kDebugMode) debugPrint('createWorkout error: $e');
    } finally {
      if (!isClosed) {
        isSubmitting.value = false;
      }
    }
  }
}
