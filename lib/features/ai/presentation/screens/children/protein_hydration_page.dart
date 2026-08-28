import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/ai/presentation/controllers/train_ai_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ProteinHydrationPage extends StatelessWidget {
  const ProteinHydrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TrainAiController.to;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          text: 'Nutrition basics',
          fontSize: 24.sp,
          fontWeight: AppFontWeight.label,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          keyboardType: TextInputType.text,
          borderColor: Colors.transparent,
          labelColor: AppColors.textPrimary,
          labelText: 'Protein target',
          hintText: 'Write here  . . .',
          controller: controller.proteinTargetController,
        ),
        CustomTextField(
          keyboardType: TextInputType.text,
          borderColor: Colors.transparent,
          labelColor: AppColors.textPrimary,
          labelText: 'Hydration rule',
          hintText: 'Write here  . . .',
          controller: controller.hydrationRuleController,
        ),
      ],
    );
  }
}
