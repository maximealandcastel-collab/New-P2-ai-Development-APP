import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/data/models/exercise_block_model.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/controllers/create_exercise_block_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class BlockExerciseDetailsCard extends StatelessWidget {
  const BlockExerciseDetailsCard({super.key, required this.exercise});

  final BlockExerciseModel exercise;

  @override
  Widget build(BuildContext context) {
    final steps = [...?exercise.steps]
      ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

    return CustomContainer(
      width: double.infinity,
      marginBottom: 10.h,
      paddingHorizontal: 16.w,
      paddingVertical: 16.h,
      radiusAll: 16.r,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: exercise.name ?? 'Exercise',
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 8.h),
          CustomText(
            text: _summaryLine(),
            fontSize: 12.sp,
            color: AppColors.textSecondary,
            textAlign: TextAlign.start,
          ),
          if (exercise.tags?.isNotEmpty ?? false) ...[
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: exercise.tags!
                  .map((tag) => _DetailChip(label: StringFormat.formatLabel(tag)))
                  .toList(),
            ),
          ],
          if (_hasSubstitutions) ...[
            SizedBox(height: 16.h),
            CustomText(
              text: 'Substitutions',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.start,
            ),
            ...exercise.substitutions!.entries.map((entry) {
              final label =
                  CreateExerciseBlockController.substitutionLabels[entry.key] ??
                      StringFormat.formatLabel(entry.key);
              return CustomText(
                top: 6.h,
                text: '$label: ${entry.value}',
                fontSize: 12.sp,
                color: AppColors.textSecondary,
                textAlign: TextAlign.start,
              );
            }),
          ],
          if (steps.isNotEmpty) ...[
            SizedBox(height: 16.h),
            CustomText(
              text: 'Steps',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.start,
            ),
            ...steps.asMap().entries.map((entry) {
              final step = entry.value;
              return Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: 'Step ${step.order ?? entry.key + 1}',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      textAlign: TextAlign.start,
                    ),
                    if ((step.instruction ?? '').trim().isNotEmpty)
                      CustomText(
                        top: 4.h,
                        text: step.instruction!.trim(),
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                        textAlign: TextAlign.start,
                      ),
                    if ((step.tip ?? '').trim().isNotEmpty)
                      CustomText(
                        top: 4.h,
                        text: 'Tip: ${step.tip!.trim()}',
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                        textAlign: TextAlign.start,
                      ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  bool get _hasSubstitutions =>
      exercise.substitutions?.values.any((value) => value.trim().isNotEmpty) ??
      false;

  String _summaryLine() {
    final parts = <String>[
      if ((exercise.muscleGroup ?? '').isNotEmpty)
        StringFormat.formatLabel(exercise.muscleGroup!),
      if ((exercise.difficulty ?? '').isNotEmpty)
        StringFormat.formatLabel(exercise.difficulty!),
      if ((exercise.equipment ?? '').isNotEmpty)
        StringFormat.formatLabel(exercise.equipment!),
      if (exercise.sets != null) '${exercise.sets} sets',
      if ((exercise.reps ?? '').isNotEmpty) '${exercise.reps} reps',
      if ((exercise.restTime ?? '').isNotEmpty) '${exercise.restTime} rest',
      if ((exercise.rpe ?? '').isNotEmpty) 'RPE ${exercise.rpe}',
    ];
    return parts.join(' · ');
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: CustomText(
        text: label,
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        textAlign: TextAlign.start,
      ),
    );
  }
}
