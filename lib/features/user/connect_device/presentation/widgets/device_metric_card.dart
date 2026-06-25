import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class DeviceMetricCard extends StatelessWidget {
  const DeviceMetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      radiusAll: 16.r,
      paddingHorizontal: 12.w,
      paddingVertical: 14.h,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomContainer(
            radiusAll: 10.r,
            paddingAll: 8.r,
            color: accentColor.withValues(alpha: 0.12),
            child: Icon(icon, size: 18.sp, color: accentColor),
          ),
          SizedBox(height: 12.h),
          CustomText(
            text: label,
            fontSize: 12.sp,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 4.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: CustomText(
                  text: value,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  textAlign: TextAlign.start,
                ),
              ),
              if (unit.isNotEmpty) ...[
                SizedBox(width: 4.w),
                Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
                  child: CustomText(
                    text: unit,
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
