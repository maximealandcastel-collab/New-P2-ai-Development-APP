import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/profile_complete_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class PhysicalInfoPage extends StatelessWidget {
  const PhysicalInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileCompleteController.to;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          text: 'What\'s your physical\ninfo ?',
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 16.h),
        GestureDetector(
          onTapDown: (details) {
            final menu = MenuShowHelper.showCustomMenu(
              context: context,
              details: details,
              options: MenuShowHelper.heightOptions,
            );
            menu.then((value) {
              if (value != null) controller.heightController.text = value;
            });
          },
          child: AbsorbPointer(
            child: CustomTextField(
              suffixIcon: Icon(Icons.arrow_drop_down_outlined),
              labelText: 'Your height',
              hintText: 'Eg : 120 cm',
              controller: controller.heightController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please select your height';
                }
                return null;
              },
            ),
          ),
        ),
        GestureDetector(
          onTapDown: (details) {
            final menu = MenuShowHelper.showCustomMenu(
              context: context,
              details: details,
              options: MenuShowHelper.weightOptions,
            );
            menu.then((value) {
              if (value != null) controller.weightController.text = value;
            });
          },
          child: AbsorbPointer(
            child: CustomTextField(
              suffixIcon: Icon(Icons.arrow_drop_down_outlined),
              labelText: 'Weight',
              hintText: 'Eg : 64 kg',
              controller: controller.weightController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please select your weight';
                }
                return null;
              },
            ),
          ),
        ),
        GestureDetector(
          onTapDown: (details) {
            final menu = MenuShowHelper.showCustomMenu(
              context: context,
              details: details,
              options: MenuShowHelper.fitnessLevelOptions,
            );
            menu.then((value) {
              if (value != null) controller.fitnessLevelController.text = value;
            });
          },
          child: AbsorbPointer(
            child: CustomTextField(
              suffixIcon: Icon(Icons.arrow_drop_down_outlined),
              labelText: 'Fitness level',
              hintText: 'Select fitness level',
              controller: controller.fitnessLevelController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please select your fitness level';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }
}
