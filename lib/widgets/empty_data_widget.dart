import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/custom_text.dart';

class EmptyDataWidget extends StatelessWidget {
  const EmptyDataWidget({super.key, this.message, this.onRefresh});

  final String? message;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.lotties.emptyData.lottie(height: 150.h),
          SizedBox(height: 16.h),
          CustomText(text: message ?? 'No data found'),
          SizedBox(height: 44.h),
          if (onRefresh != null)
            TextButton(
              onPressed: onRefresh,
              child: CustomText(
                text: 'Refresh',
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
