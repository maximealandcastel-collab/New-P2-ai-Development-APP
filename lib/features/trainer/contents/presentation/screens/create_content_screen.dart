import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/controllers/create_content_controller.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/screens/children/content_basic_info_page.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/screens/children/content_equipment_tags_page.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/screens/children/content_muscle_difficulty_page.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/screens/children/content_video_details_page.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/widgets/create_content_flow_screen.dart';

class CreateContentScreen extends StatelessWidget {
  const CreateContentScreen({super.key});

  static const _pages = [
    ContentBasicInfoPage(),
    ContentVideoDetailsPage(),
    ContentMuscleDifficultyPage(),
    ContentEquipmentTagsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateContentController>();

    return Obx(
      () => CreateContentFlowScreen(
        pages: _pages,
        formKey: controller.formKey,
        isSubmitting: controller.isSubmitting.value,
        uploadProgress: controller.uploadProgress.value,
        submitLabel:
            controller.isEditMode ? 'Update content' : 'Post content',
        onNextPressed: (currentIndex, navigateToPage, validateAfterNav) async {
          final formValid =
              controller.formKey.currentState?.validate() ?? false;
          if (!formValid) return;

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
