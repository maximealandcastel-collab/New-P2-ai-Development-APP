import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ExerciseBlockFab extends StatelessWidget {
  const ExerciseBlockFab({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onPressed,
      color: Theme.of(context).colorScheme.primary,
      radiusAll: 100.r,
      paddingHorizontal: 20.w,
      paddingVertical: 14.h,
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20.sp),
          SizedBox(width: 8.w),
          CustomText(
            text: label,
            fontSize: 14.sp,
            fontWeight: AppFontWeight.label,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
