import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/ai/presentation/controllers/train_ai_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class RestTimesPage extends StatelessWidget {
  const RestTimesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TrainAiController.to;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          text: 'Rest times',
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                keyboardType: TextInputType.number,
                borderColor: Colors.transparent,
                labelColor: AppColors.textPrimary,
                labelText: 'Rest times',
                hintText: 'eg : 60',
                controller: controller.restTimeMinController,
                validator: (value) {
                  final min = int.tryParse(value?.trim() ?? '');
                  if (min == null || min < 1) {
                    return 'Enter min rest in sec (e.g. 60)';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: CustomTextField(
                keyboardType: TextInputType.number,
                borderColor: Colors.transparent,
                labelColor: AppColors.textPrimary,
                labelText: '',
                hintText: 'eg : 90',
                controller: controller.restTimeMaxController,
                validator: (value) {
                  final max = int.tryParse(value?.trim() ?? '');
                  final min = int.tryParse(
                    controller.restTimeMinController.text.trim(),
                  );
                  if (max == null || max < 1) {
                    return 'Enter max rest in sec (e.g. 90)';
                  }
                  if (min != null && max <= min) {
                    return 'Max must be greater than min';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
