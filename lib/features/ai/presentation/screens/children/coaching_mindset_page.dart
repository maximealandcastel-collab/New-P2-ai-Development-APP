import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/ai/presentation/controllers/train_ai_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class CoachingMindsetPage extends StatelessWidget {
  const CoachingMindsetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TrainAiController.to;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          text: 'Coaching mindset',
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          keyboardType: TextInputType.text,
          borderColor: Colors.transparent,
          labelColor: AppColors.textPrimary,
          labelText: 'Consistency method',
          hintText: 'Write here  . . .',
          controller: controller.consistencyMethodController,
        ),
        CustomTextField(
          keyboardType: TextInputType.text,
          borderColor: Colors.transparent,
          labelColor: AppColors.textPrimary,
          labelText: 'Motivation drop response',
          hintText: 'Write here  . . .',
          controller: controller.motivationDropResponseController,
        ),
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
