import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/data/models/exercise_block_model.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ExerciseBlockCard extends StatelessWidget {
  const ExerciseBlockCard({
    super.key,
    required this.block,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final ExerciseBlockModel block;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      width: double.infinity,
      paddingAll: 16.r,
      radiusAll: 16.r,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomText(
                  text: block.title,
                  fontSize: 16.sp,
                  fontWeight: AppFontWeight.label,
                  textAlign: TextAlign.start,
                ),
              ),
              GestureDetector(
                onTapDown: (details) {
                  MenuShowHelper.showCustomMenu(
                    context: context,
                    details: details,
                    options: const ['Edit', 'Delete'],
                  ).then((value) {
                    if (value == 'Edit') onEdit?.call();
                    if (value == 'Delete') onDelete?.call();
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Icon(
                  Icons.more_vert_outlined,
                  size: 20.sp,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          CustomText(
            top: 10.h,
            text: 'Category : ${block.categoryLabel}',
            color: AppColors.textSecondary,
            textAlign: TextAlign.start,
          ),
          CustomText(
            top: 4.h,
            text: 'Created at ${block.formattedCreatedAt}',
            color: AppColors.textSecondary,
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}
