import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/profile_complete_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/widgets/complete_profile_page_title.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class GoalSetupPage extends StatelessWidget {
  const GoalSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileCompleteController.to;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CompleteProfilePageTitle(text: 'What\'s your goal?'),
        SizedBox(height: 16.h),
        MenuDropdownField(
          labelText: 'Primary goal',
          hintText: 'Select primary goal',
          controller: controller.primaryGoalController,
          options: MenuShowHelper.goalOptions,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please select your primary goal';
            }
            return null;
          },
        ),
        DatePickerField(
          controller: controller.dateOfBirthController,
          initialDate: controller.selectedDateOfBirth,
          onDateChanged: (date) => controller.selectedDateOfBirth = date,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please select your date of birth';
            }
            return null;
          },
        ),
      ],
    );
  }
}
