import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/data/models/exercise_block_model.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/widgets/block_exercise_details_card.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/widgets/exercise_block_details_info.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ExerciseBlockDetailsContent extends StatelessWidget {
  const ExerciseBlockDetailsContent({super.key, required this.block});

  final ExerciseBlockModel block;

  @override
  Widget build(BuildContext context) {
    final exercises = block.exercises ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12.h),
        ExerciseBlockDetailsInfo(block: block),
        SizedBox(height: 22.h),
        _buildSectionHeader(exercises.length),
        SizedBox(height: 12.h),
        if (exercises.isEmpty)
          const EmptyDataWidget(message: 'No exercises in this block.')
        else
          ...exercises.asMap().entries.map(
                (entry) => BlockExerciseDetailsCard(
                  key: ValueKey(entry.value.id ?? entry.value.name),
                  index: entry.key + 1,
                  exercise: entry.value,
                ),
              ),
      ],
    );
  }

  Widget _buildSectionHeader(int count) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: 'Exercise list',
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                textAlign: TextAlign.start,
              ),
              CustomText(
                top: 2.h,
                text: 'Tap an exercise to view details',
                fontSize: 12.sp,
                color: AppColors.textSecondary,
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(999.r),
          ),
          child: CustomText(
            text: '$count',
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }
}
