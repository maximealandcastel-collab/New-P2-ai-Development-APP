import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/user/connect_device/data/models/connected_device_model.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ConnectedDeviceTile extends StatelessWidget {
  const ConnectedDeviceTile({
    super.key,
    required this.device,
  });

  final ConnectedDeviceModel device;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      radiusAll: 14.r,
      color: Colors.white,
      paddingHorizontal: 14.w,
      paddingVertical: 14.h,
      child: Row(
        children: [
          CustomContainer(
            height: 40.r,
            width: 40.r,
            radiusAll: 10.r,
            color: AppColors.backgroundLight,
            child: Icon(
              Icons.watch_outlined,
              size: 20.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: device.name,
                  textAlign: TextAlign.start,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
                CustomText(
                  top: 3.h,
                  text: device.serial,
                  textAlign: TextAlign.start,
                  fontSize: 11.sp,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          CustomContainer(
            paddingHorizontal: 10.w,
            paddingVertical: 5.h,
            radiusAll: 20.r,
            color: const Color(0xFF4CAF50),
            child: CustomText(
              text: 'Connected',
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
