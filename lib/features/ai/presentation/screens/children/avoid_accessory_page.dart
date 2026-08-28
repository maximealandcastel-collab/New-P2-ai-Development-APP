import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/features/ai/presentation/controllers/train_ai_controller.dart';
import 'package:pler_to_pler_app/widgets/tag_add_widget.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class AvoidAccessoryPage extends StatelessWidget {
  const AvoidAccessoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TrainAiController.to;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          text: 'Exercise preferences',
          fontSize: 24.sp,
          fontWeight: AppFontWeight.label,
        ),
        SizedBox(height: 16.h),
        TagAddWidget(
          labelText: 'Avoid exercises',
          hintText: 'Write here ...',
          initialTags: controller.avoidExercises,
          onTagsChanged: controller.setAvoidExercises,
        ),
        TagAddWidget(
          labelText: 'Accessory favorites',
          hintText: 'Write here ...',
          initialTags: controller.accessoryFavorites,
          onTagsChanged: controller.setAccessoryFavorites,
        ),
      ],
    );
  }
}
