import 'package:flutter/material.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/create_content_flow_screen.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/controllers/exercise_block_controller.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/screens/children/add_exercise_details_page.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/screens/children/add_exercise_options_page.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/screens/children/add_exercise_steps_substitutions_page.dart';

class AddExerciseScreen extends StatelessWidget {
  const AddExerciseScreen({super.key});

  static const _pages = [
    AddExerciseDetailsPage(),
    AddExerciseOptionsPage(),
    AddExerciseStepsSubstitutionsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = ExerciseBlockController.to;

    return CreateContentFlowScreen(
      pages: _pages,
      formKey: controller.exerciseFormKey,
      isSubmitting: false,
      uploadProgress: 0,
      submitLabel: 'Create exercise',
      onNextPressed: (currentIndex, navigateToPage, validateAfterNav) async {
        final formValid =
            controller.exerciseFormKey.currentState?.validate() ?? false;
        if (!formValid) return;

        if (!controller.validateExerciseStep(currentIndex)) {
          controller.showExerciseStepValidationMessage(currentIndex);
          validateAfterNav();
          return;
        }

        if (currentIndex < _pages.length - 1) {
          navigateToPage(currentIndex + 1);
          return;
        }

        for (var step = 0; step < _pages.length; step++) {
          if (!controller.validateExerciseStep(step)) {
            navigateToPage(step);
            validateAfterNav();
            return;
          }
        }

        controller.saveExercise();
      },
    );
  }
}
