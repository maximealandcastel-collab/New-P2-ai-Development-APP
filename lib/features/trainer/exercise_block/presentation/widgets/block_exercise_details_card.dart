import 'package:pler_to_pler_app/core/themes/app_typography.dart';
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
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: _isExpanded
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : AppColors.colorE6E6E6,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              clipBehavior: Clip.hardEdge,
              child: _isExpanded
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12.h),
                        Divider(color: AppColors.colorE6E6E6, height: 1.h),
                        BlockExerciseDetailsContent(exercise: exercise),
                      ],
                    )
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: exercise.name ?? 'Exercise',
                fontSize: 15.sp,
                fontWeight: AppFontWeight.label,
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
        Icon(
          _isExpanded
              ? Icons.keyboard_arrow_up_rounded
              : Icons.keyboard_arrow_down_rounded,
          size: 22.sp,
          color: _isExpanded ? AppColors.textPrimary : AppColors.textSecondary,
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
        color: AppColors.textPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: CustomText(
        text: '${widget.index}',
        fontSize: 12.sp,
        fontWeight: AppFontWeight.title,
        color: AppColors.textPrimary,
        textAlign: TextAlign.center,
      ),
    );
  }

  String _subtitle() {
    if ((exercise.muscleGroup ?? '').isEmpty) return '';
    return StringFormat.formatLabel(exercise.muscleGroup!);
  }
}
