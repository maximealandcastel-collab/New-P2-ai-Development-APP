import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/helpers/helper_data.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/widgets/complete_profile_page_title.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/controllers/exercise_block_controller.dart';
import 'package:pler_to_pler_app/widgets/tag_add_widget.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class AddExerciseOptionsPage extends StatelessWidget {
  const AddExerciseOptionsPage({super.key});

  List<String> _formatOptions(List<String> options) =>
      options.map(StringFormat.formatLabel).toList();

  @override
  Widget build(BuildContext context) {
    final controller = ExerciseBlockController.to;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CompleteProfilePageTitle(text: 'Target & equipment'),
        SizedBox(height: 16.h),
        MenuDropdownField(
          labelText: 'Muscle group',
          hintText: 'Select muscle group',
          controller: controller.exerciseMuscleGroupController,
          options: _formatOptions(HelperData.muscleGroupOptions),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please select muscle group';
            }
            return null;
          },
        ),
        SizedBox(height: 12.h),
        MenuDropdownField(
          labelText: 'Difficulty',
          hintText: 'Select difficulty',
          controller: controller.exerciseDifficultyController,
          options: _formatOptions(
            HelperData.contentDifficultyOptions
                .where((item) => item != 'all')
                .toList(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please select difficulty';
            }
            return null;
          },
        ),
        SizedBox(height: 12.h),
        MenuDropdownField(
          labelText: 'Equipment',
          hintText: 'Select equipment',
          controller: controller.exerciseEquipmentController,
          options: _formatOptions(HelperData.exerciseEquipmentOptions),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please select equipment';
            }
            return null;
          },
        ),
        SizedBox(height: 12.h),
        Obx(
          () => TagAddWidget(
            labelText: 'Tags',
            hintText: 'Add tag',
            initialTags: controller.exerciseTags.toList(),
            onTagsChanged: controller.onExerciseTagsChanged,
          ),
        ),
      ],
    );
  }
}
