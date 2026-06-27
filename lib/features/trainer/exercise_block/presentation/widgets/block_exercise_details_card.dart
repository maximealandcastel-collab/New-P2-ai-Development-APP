import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/data/models/exercise_block_model.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/widgets/block_exercise_details_content.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class BlockExerciseDetailsCard extends StatefulWidget {
  const BlockExerciseDetailsCard({
    super.key,
    required this.exercise,
    required this.index,
  });

  final BlockExerciseModel exercise;
  final int index;

  @override
  State<BlockExerciseDetailsCard> createState() =>
      _BlockExerciseDetailsCardState();
}

class _BlockExerciseDetailsCardState extends State<BlockExerciseDetailsCard> {
  bool _isExpanded = false;

  BlockExerciseModel get exercise => widget.exercise;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: _isExpanded
                ? AppColors.primary.withValues(alpha: 0.35)
                : AppColors.colorE6E6E6,
            width: _isExpanded ? 1.2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(
                alpha: _isExpanded ? 0.08 : 0.04,
              ),
              blurRadius: _isExpanded ? 18 : 10,
              offset: Offset(0, _isExpanded ? 6.h : 3.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            if (_isExpanded) ...[
              SizedBox(height: 14.h),
              Divider(color: AppColors.colorE6E6E6, height: 1.h),
            ],
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              clipBehavior: Clip.hardEdge,
              child: _isExpanded
                  ? BlockExerciseDetailsContent(exercise: exercise)
                  : SizedBox(width: double.infinity, height: 0.h),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final subtitle = _subtitle();

    return Row(
      children: [
        _buildIndexBadge(),
        SizedBox(width: 12.w),
        CustomContainer(
          radiusAll: 14.r,
          paddingAll: 10.r,
          color: AppColors.primary.withValues(alpha: 0.1),
          child: Icon(
            Icons.fitness_center_rounded,
            size: 20.sp,
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: exercise.name ?? 'Exercise',
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                textAlign: TextAlign.start,
              ),
              if (subtitle.isNotEmpty)
                CustomText(
                  top: 4.h,
                  text: subtitle,
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                  textAlign: TextAlign.start,
                ),
            ],
          ),
        ),
        AnimatedRotation(
          turns: _isExpanded ? 0.5 : 0,
          duration: const Duration(milliseconds: 200),
          child: CustomContainer(
            radiusAll: 999.r,
            paddingAll: 6.r,
            color: _isExpanded
                ? AppColors.primary.withValues(alpha: 0.12)
                : AppColors.backgroundLight,
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 22.sp,
              color: _isExpanded ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIndexBadge() {
    return Container(
      width: 28.r,
      height: 28.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: CustomText(
        text: '${widget.index}',
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        textAlign: TextAlign.center,
      ),
    );
  }

  String _subtitle() {
    if ((exercise.muscleGroup ?? '').isEmpty) return '';
    return StringFormat.formatLabel(exercise.muscleGroup!);
  }
}
