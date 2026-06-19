import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/ai/presentation/controllers/train_ai_controller.dart';
import 'package:pler_to_pler_app/widgets/tag_add_widget.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ExercisesPage extends StatelessWidget {
  const ExercisesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TrainAiController.to;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          text: 'Exercises',
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          keyboardType: TextInputType.text,
          borderColor: Colors.transparent,
          labelColor: AppColors.textPrimary,
          labelText: 'Cardio philosophy',
          hintText: 'Write here  . . .',
          controller: controller.cardioPhilosophyController,
        ),
        TagAddWidget(
          labelText: 'Must use exercise',
          hintText: 'Write here ...',
          initialTags: controller.mustUseExercises,
          onTagsChanged: controller.setMustUseExercises,
        ),
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
