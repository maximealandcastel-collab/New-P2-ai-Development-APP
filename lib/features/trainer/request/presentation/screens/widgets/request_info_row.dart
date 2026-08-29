import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class RequestInfoRow extends StatelessWidget {
  const RequestInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: label,
            fontSize: 13.sp,
            color: AppColors.textSecondary,
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 4.h),
          CustomText(
            text: value,
            fontSize: 15.sp,
            fontWeight: AppFontWeight.label,
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}
