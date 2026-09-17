import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/create_content_flow_screen.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/controllers/workout_controller.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/screens/children/workout_environment_page.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/screens/children/workout_equipment_page.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/screens/children/workout_focus_area_page.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/screens/children/workout_goal_page.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/screens/children/workout_intensity_duration_page.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/screens/children/workout_training_pick_page.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  static const _pages = [
    WorkoutGoalPage(),
    WorkoutTrainingPickPage(),
    WorkoutFocusAreaPage(),
    WorkoutEnvironmentPage(),
    WorkoutEquipmentPage(),
    WorkoutIntensityDurationPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WorkoutController>();

    return Obx(
      () => CreateContentFlowScreen(
        pages: _pages,
        formKey: controller.formKey,
        isSubmitting: controller.submitLoadingState.isLoading,
        uploadProgress: 0,
        submitLabel: 'Create workout',
        canSkipStep: (index) => index == 1,
        onSkipPressed: (index, navigateToPage) {
          if (index == 1) {
            controller.selectedTrainingStyles.clear();
            controller.trainingPickSkipped.value = true;
            if (index < _pages.length - 1) {
              navigateToPage(index + 1);
            } else {
              controller.submit();
            }
          }
        },
        onNextPressed: (currentIndex, navigateToPage, validateAfterNav) async {
          if (!controller.validateStep(currentIndex)) {
            controller.showStepValidationMessage(currentIndex);
            validateAfterNav();
            return;
          }

          if (currentIndex < _pages.length - 1) {
            navigateToPage(currentIndex + 1);
            return;
          }

          for (var step = 0; step < _pages.length; step++) {
            if (!controller.validateStep(step)) {
              navigateToPage(step);
              validateAfterNav();
              return;
            }
          }

          await controller.submit();
        },
      ),
    );
  }
}
