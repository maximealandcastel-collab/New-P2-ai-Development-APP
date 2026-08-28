import 'package:pler_to_pler_app/core/themes/app_typography.dart';
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
    return CustomContainer(
      color: Colors.white,
      radiusAll: 16.r,
      paddingHorizontal: 16.w,
      paddingVertical: 16.h,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: block.title,
            fontWeight: AppFontWeight.title,
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
                    fontWeight: AppFontWeight.label,
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
}
