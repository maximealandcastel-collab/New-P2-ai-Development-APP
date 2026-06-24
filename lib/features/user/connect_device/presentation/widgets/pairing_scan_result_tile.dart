import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/user/connect_device/data/models/device_model.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class PairingScanResultTile extends StatelessWidget {
  const PairingScanResultTile({
    super.key,
    required this.device,
    required this.onTap,
  });

  final BluetoothScanResultModel device;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      radiusAll: 14.r,
      color: Colors.white,
      paddingHorizontal: 14.w,
      paddingVertical: 14.h,
      child: Row(
        children: [
          CustomContainer(
            radiusAll: 12.r,
            paddingAll: 10.r,
            color: AppColors.backgroundLight,
            child: Icon(Icons.watch_outlined, color: AppColors.primary, size: 22.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: device.name,
                  textAlign: TextAlign.start,
                  fontWeight: FontWeight.w600,
                  fontSize: 15.sp,
                ),
                if ((device.macAddress ?? '').isNotEmpty)
                  CustomText(
                    top: 2.h,
                    text: device.macAddress!,
                    textAlign: TextAlign.start,
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20.r),
        ],
      ),
    );
  }
}
