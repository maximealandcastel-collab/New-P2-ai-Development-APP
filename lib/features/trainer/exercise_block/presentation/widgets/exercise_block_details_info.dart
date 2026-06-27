import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/data/models/exercise_block_model.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ExerciseBlockDetailsInfo extends StatelessWidget {
  const ExerciseBlockDetailsInfo({super.key, required this.block});

  final ExerciseBlockModel block;

  @override
  Widget build(BuildContext context) {
    final exerciseCount = block.exercises?.length ?? 0;

    return CustomContainer(
      color: Colors.white,
      radiusAll: 16.r,
      paddingHorizontal: 16.w,
      paddingVertical: 16.h,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _primaryChip(block.categoryLabel),
              _primaryChip('$exerciseCount exercises'),
              if (block.isAiGenerated == true) _primaryChip('AI generated'),
            ],
          ),
          SizedBox(height: 14.h),
          CustomText(
            text: block.title,
            fontWeight: FontWeight.w700,
            fontSize: 20.sp,
            textAlign: TextAlign.start,
          ),
          if ((block.description ?? '').trim().isNotEmpty) ...[
            SizedBox(height: 14.h),
            CustomContainer(
              width: double.infinity,
              radiusAll: 12.r,
              paddingHorizontal: 14.w,
              paddingVertical: 12.h,
              color: AppColors.backgroundLight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: 'Description',
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(height: 6.h),
                  CustomText(
                    text: block.description!.trim(),
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 12.h),
          CustomText(
            text: 'Created at ${block.formattedCreatedAt}',
            fontSize: 12.sp,
            color: AppColors.textSecondary,
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }

  Widget _primaryChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: CustomText(
        text: label,
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
        textAlign: TextAlign.start,
      ),
    );
  }
}
