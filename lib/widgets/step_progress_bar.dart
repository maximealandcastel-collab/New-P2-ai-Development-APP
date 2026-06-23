import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/widgets/custom_container.dart';

class StepProgressBar extends StatelessWidget {
  const StepProgressBar({
    super.key,
    required this.stepCount,
    required this.currentIndex,
    required this.showLeading,
  });

  final int stepCount;
  final int currentIndex;
  final bool showLeading;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        stepCount,
        (index) => Expanded(
          child: CustomContainer(
            marginLeft: (index == 0 && !showLeading) ? 16.w : 4.w,
            height: 6.h,
            color: currentIndex == index
                ? AppColors.textPrimary
                : AppColors.textWhite,
            radiusAll: 99.r,
          ),
        ),
      ),
    );
  }
}
