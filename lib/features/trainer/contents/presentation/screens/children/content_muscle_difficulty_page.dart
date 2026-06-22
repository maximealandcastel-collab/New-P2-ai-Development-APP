import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/content_form_constants.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/widgets/dropdown_text_field.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/widgets/muscle_group_picker_field.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ContentMuscleDifficultyPage extends StatelessWidget {
  const ContentMuscleDifficultyPage({
    super.key,
    required this.muscleGroupsController,
    required this.difficultyController,
    required this.selectedMuscleGroups,
    required this.onMuscleGroupsChanged,
    required this.onDifficultySelected,
  });

  final TextEditingController muscleGroupsController;
  final TextEditingController difficultyController;
  final List<String> selectedMuscleGroups;
  final ValueChanged<List<String>> onMuscleGroupsChanged;
  final ValueChanged<String> onDifficultySelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          text: 'Target & difficulty',
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 16.h),
        MuscleGroupPickerField(
          controller: muscleGroupsController,
          selectedValues: selectedMuscleGroups,
          onChanged: onMuscleGroupsChanged,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please select at least one muscle group';
            }
            return null;
          },
        ),
        DropdownTextField(
          controller: difficultyController,
          labelText: 'Difficulty',
          hintText: 'Select difficulty',
          options: ContentFormConstants.difficultyOptions
              .map(ContentFormConstants.formatLabel)
              .toList(),
          onSelected: (display) {
            final match = ContentFormConstants.difficultyOptions.firstWhere(
              (value) => ContentFormConstants.formatLabel(value) == display,
            );
            onDifficultySelected(match);
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
