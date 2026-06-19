import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/ai/presentation/controllers/train_ai_controller.dart';
import 'package:pler_to_pler_app/widgets/tag_add_widget.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class DaysSplitsPage extends StatelessWidget {
  const DaysSplitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TrainAiController.to;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          text: 'Training schedule',
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          keyboardType: TextInputType.number,
          borderColor: Colors.transparent,
          labelColor: AppColors.textPrimary,
          labelText: 'Days per week',
          hintText: 'eg : 4 days',
          controller: controller.daysPerWeekController,
          validator: (value) {
            final days = int.tryParse(value?.trim() ?? '');
            if (days == null || days < 1 || days > 7) {
              return 'Enter days between 1 and 7';
            }
            return null;
          },
        ),
        TagAddWidget(
          labelText: 'Preferred Splits',
          hintText: 'Write here ...',
          initialTags: controller.preferredSplits,
          onTagsChanged: controller.setPreferredSplits,
        ),
      ],
    );
  }
}
