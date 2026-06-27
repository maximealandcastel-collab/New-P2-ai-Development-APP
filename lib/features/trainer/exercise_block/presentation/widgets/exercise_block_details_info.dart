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
      elevation: true,
      elevationColor: AppColors.textPrimary.withValues(alpha: 0.06),
      color: Colors.white,
      radiusAll: 20.r,
      paddingHorizontal: 18.w,
      paddingVertical: 18.h,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _infoChip(
                icon: Icons.category_outlined,
                label: block.categoryLabel,
                color: AppColors.primary,
              ),
              _infoChip(
                icon: Icons.fitness_center_rounded,
                label: '$exerciseCount exercises',
                color: AppColors.info,
              ),
              if (block.isAiGenerated == true)
                _infoChip(
                  icon: Icons.auto_awesome_rounded,
                  label: 'AI generated',
                  color: AppColors.success,
                ),
            ],
          ),
          SizedBox(height: 16.h),
          CustomText(
            text: block.title,
            fontWeight: FontWeight.w700,
            fontSize: 22.sp,
            textAlign: TextAlign.start,
          ),
          if ((block.description ?? '').trim().isNotEmpty) ...[
            SizedBox(height: 14.h),
            CustomContainer(
              width: double.infinity,
              radiusAll: 14.r,
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
          SizedBox(height: 14.h),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 6.w),
              CustomText(
                text: 'Created at ${block.formattedCreatedAt}',
                fontSize: 12.sp,
                color: AppColors.textSecondary,
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 6.w),
          CustomText(
            text: label,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: color,
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}
