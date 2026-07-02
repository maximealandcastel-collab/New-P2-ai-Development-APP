import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/create_content_flow_screen.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/controllers/workout_controller.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/screens/children/workout_environment_page.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/screens/children/workout_equipment_page.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/screens/children/workout_focus_area_page.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/screens/children/workout_goal_page.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/screens/children/workout_intensity_duration_page.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  static const _pages = [
    WorkoutGoalPage(),
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
        isSubmitting: controller.isSubmitting.value,
        uploadProgress: 0,
        submitLabel: 'Create workout',
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
