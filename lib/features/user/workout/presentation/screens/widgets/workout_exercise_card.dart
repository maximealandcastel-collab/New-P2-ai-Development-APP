import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/workout_model.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/controllers/workout_controller.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/screens/widgets/workout_metric_chip.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class WorkoutExerciseCard extends StatefulWidget {
  const WorkoutExerciseCard({
    super.key,
    required this.exercise,
  });

  final WorkoutExerciseModel exercise;

  @override
  State<WorkoutExerciseCard> createState() => _WorkoutExerciseCardState();
}

class _WorkoutExerciseCardState extends State<WorkoutExerciseCard> {
  bool _showSteps = false;

  List<WorkoutExerciseStepModel> get _steps {
    final steps = [...?widget.exercise.steps]
      ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
    return steps;
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
    final steps = _steps;

    return CustomContainer(
      radiusAll: 16.r,
      paddingAll: 12.r,
      marginBottom: 12.h,
      bordersColor: AppColors.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomText(
                  textAlign: TextAlign.start,
                  text: exercise.exerciseName ?? '',
                  fontSize: 18.sp,
                  color: const Color(0xff6A3400),
                  fontWeight: FontWeight.w700,
                ),
              ),
              _buildCompletionAction(context),
            ],
          ),
          if ((exercise.muscleGroup ?? '').isNotEmpty) ...[
            SizedBox(height: 4.h),
            CustomText(
              text:
                  'Muscle group: ${StringFormat.formatLabel(exercise.muscleGroup!)}',
              fontSize: 13.sp,
              color: AppColors.textSecondary,
            ),
          ],
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              if (exercise.sets != null)
                WorkoutMetricChip(label: '${exercise.sets} sets'),
              if ((exercise.reps ?? '').isNotEmpty)
                WorkoutMetricChip(label: '${exercise.reps} reps'),
              if ((exercise.restTime ?? '').isNotEmpty)
                WorkoutMetricChip(label: 'Rest ${exercise.restTime}'),
              if ((exercise.rpe ?? '').isNotEmpty)
                WorkoutMetricChip(label: 'RPE ${exercise.rpe}'),
            ],
          ),
          if (steps.isNotEmpty) ...[
            SizedBox(height: 14.h),
            Divider(height: 1.h, color: AppColors.colorE6E6E6),
            Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _showSteps = !_showSteps),
                child: AnimatedRotation(
                  turns: _showSteps ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 28.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            if (_showSteps) ...[
              //  SizedBox(height: 6.h),
              ...steps.asMap().entries.map(_buildStepItem),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildCompletionAction(BuildContext context) {
    return Obx(() {
      final isCompleted = _isExerciseCompleted();

      if (isCompleted) {
        return _buildCompletedStatus();
      }

      return CustomButton(
        onPressed: () => _showCompleteDialog(context),
        label: 'Mark Completed',
        width: 100.w,
        height: 30.h,
        fontSize: 10.sp,
      );
    });
  }

  bool _isExerciseCompleted() {
    final exerciseId = widget.exercise.exerciseId ?? widget.exercise.id;
    if (exerciseId == null || exerciseId.isEmpty) {
      return widget.exercise.isCompleted == true;
    }

    final plan = WorkoutController.to.plan;
    final exercises = [
      ...?plan?.mainWork,
      ...?plan?.accessories,
      ...?plan?.finisher,
    ];

    for (final exercise in exercises) {
      if (exercise.exerciseId == exerciseId || exercise.id == exerciseId) {
        return exercise.isCompleted == true;
      }
    }

    return widget.exercise.isCompleted == true;
  }

  Widget _buildCompletedStatus() {
    return CustomContainer(
      paddingHorizontal: 10.w,
      paddingVertical: 6.h,
      radiusAll: 8.r,
      color: AppColors.success.withValues(alpha: 0.12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 14.sp,
            color: AppColors.success,
          ),
          SizedBox(width: 4.w),
          CustomText(
            text: 'Completed',
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.success,
          ),
        ],
      ),
    );
  }

  void _showCompleteDialog(BuildContext context) {
    final controller = WorkoutController.to;
    final exerciseName = widget.exercise.exerciseName ?? 'this exercise';

    Get.dialog(
      Obx(
        () => CustomDialog(
          title: 'Mark Completed',
          description: 'Mark "$exerciseName" as completed?',
          titleColor: AppColors.primary,
          rightButtonLabel: 'Confirm',
          rightButtonBgColor: AppColors.primary,
          rightButtonLabelColor: AppColors.textWhite,
          isLoading: controller.completeExerciseLoadingState.isLoading,
          onTapLeftButton: () => Get.back(),
          onTapRightButton: () => controller.completeExercise(widget.exercise),
        ),
      ),
      barrierDismissible: !controller.completeExerciseLoadingState.isLoading,
    );
  }

  Widget _buildStepItem(MapEntry<int, WorkoutExerciseStepModel> entry) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: entry.key == _steps.length - 1 ? 0 : 10.h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: '${entry.key + 1}.',
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: entry.value.instruction ?? '',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.start,
                ),
                if ((entry.value.tip ?? '').isNotEmpty) ...[
                  SizedBox(height: 3.h),
                  CustomText(
                    text: 'Tip: ${entry.value.tip!}',
                    fontSize: 11.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    textAlign: TextAlign.start,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
