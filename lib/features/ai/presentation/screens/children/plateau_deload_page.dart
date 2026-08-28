import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/ai/presentation/controllers/train_ai_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class PlateauDeloadPage extends StatelessWidget {
  const PlateauDeloadPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TrainAiController.to;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          text: 'Progress protocol',
          fontSize: 24.sp,
          fontWeight: AppFontWeight.label,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          keyboardType: TextInputType.text,
          borderColor: Colors.transparent,
          labelColor: AppColors.textPrimary,
          labelText: 'Plateau protocol',
          hintText: 'Write here  . . .',
          controller: controller.plateauProtocolController,
        ),
        CustomTextField(
          keyboardType: TextInputType.text,
          borderColor: Colors.transparent,
          labelColor: AppColors.textPrimary,
          labelText: 'Deload rules',
          hintText: 'Write here  . . .',
          controller: controller.deloadRulesController,
        ),
      ],
    );
  }
}
