import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/profile_complete_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/widgets/complete_profile_page_title.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class PhysicalInfoPage extends StatelessWidget {
  const PhysicalInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileCompleteController.to;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CompleteProfilePageTitle(text: 'What\'s your physical\ninfo ?'),
        SizedBox(height: 16.h),
        MenuDropdownField(
          labelText: 'Your height',
          hintText: 'Eg : 120 cm',
          controller: controller.heightController,
          options: MenuShowHelper.heightOptions,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please select your height';
            }
            return null;
          },
        ),
        MenuDropdownField(
          labelText: 'Weight',
          hintText: 'Eg : 64 kg',
          controller: controller.weightController,
          options: MenuShowHelper.weightOptions,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please select your weight';
            }
            return null;
          },
        ),
        MenuDropdownField(
          labelText: 'Fitness level',
          hintText: 'Select fitness level',
          controller: controller.fitnessLevelController,
          options: MenuShowHelper.fitnessLevelOptions,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please select your fitness level';
            }
            return null;
          },
        ),
      ],
    );
  }
}
