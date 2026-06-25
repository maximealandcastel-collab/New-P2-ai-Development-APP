import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/widgets/complete_profile_page_title.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/controllers/create_content_controller.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/widgets/dropdown_text_field.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/widgets/muscle_group_picker_field.dart';

class ContentMuscleDifficultyPage extends StatelessWidget {
  const ContentMuscleDifficultyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = CreateContentController.to;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CompleteProfilePageTitle(text: 'Target & difficulty'),
        SizedBox(height: 16.h),
        Obx(
          () => MuscleGroupPickerField(
            controller: controller.muscleGroupsController,
            selectedValues: controller.selectedMuscleGroups.toList(),
            onChanged: controller.onMuscleGroupsChanged,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please select at least one muscle group';
              }
              return null;
            },
          ),
        ),
        DropdownTextField(
          controller: controller.difficultyController,
          labelText: 'Difficulty',
          hintText: 'Select difficulty',
          options: MenuShowHelper.contentDifficultyOptions
              .map(StringFormat.formatLabel)
              .toList(),
          onSelected: (display) {
            final match = StringFormat.contentDifficultyBackendValue(display);
            if (match != null) controller.onDifficultySelected(match);
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please select difficulty';
            }
            return null;
          },
        ),
      ],
    );
  }
}
