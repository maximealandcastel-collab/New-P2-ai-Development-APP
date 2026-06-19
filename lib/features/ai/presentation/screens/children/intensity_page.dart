import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/ai/presentation/controllers/train_ai_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class IntensityPage extends StatelessWidget {
  const IntensityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TrainAiController.to;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          text: 'Intensity & deload',
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 16.h),
        GestureDetector(
          onTapDown: (details) {
            MenuShowHelper.showCustomMenu(
              context: context,
              details: details,
              options: MenuShowHelper.intensityMeasureOptions,
            ).then((value) {
              if (value != null) {
                controller.intensityMeasureController.text = value;
              }
            });
          },
          child: AbsorbPointer(
            child: CustomTextField(
              suffixIcon: Icon(Icons.arrow_drop_down_outlined),
              borderColor: Colors.transparent,
              labelColor: AppColors.textPrimary,
              labelText: 'Intensity measure',
              hintText: 'Select intensity (e.g. RPE)',
              controller: controller.intensityMeasureController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please select intensity measure';
                }
                return null;
              },
            ),
          ),
        ),
        CustomTextField(
          keyboardType: TextInputType.text,
          borderColor: Colors.transparent,
          labelColor: AppColors.textPrimary,
          labelText: 'Deload frequency',
          hintText: 'Write here  . . .',
          controller: controller.deloadFrequencyController,
        ),
      ],
    );
  }
}
