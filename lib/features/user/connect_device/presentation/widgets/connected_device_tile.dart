import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/user/connect_device/data/models/device_model.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ConnectedDeviceTile extends StatelessWidget {
  const ConnectedDeviceTile({
    super.key,
    required this.device,
    this.onTap,
    this.isConnecting = false,
    this.onRemove,
    this.onSync,
  });

  final DeviceModel device;
  final VoidCallback? onTap;
  final bool isConnecting;
  final VoidCallback? onRemove;
  final VoidCallback? onSync;

  @override
  Widget build(BuildContext context) {
    final statusColor =
        device.isConnected ? const Color(0xFF4CAF50) : AppColors.textSecondary;
    final statusText = device.isConnected ? 'Connected' : 'Disconnected';

    return CustomContainer(
      onTap: device.isConnected ? null : onTap,
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
                  text: device.serialNumber,
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
            color: isConnecting ? AppColors.primary : statusColor,
            child: isConnecting
                ? SizedBox(
                    width: 12.r,
                    height: 12.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : CustomText(
                    text: statusText,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 20.sp, color: Colors.black54),
            onSelected: (value) {
              switch (value) {
                case 'sync':
                  onSync?.call();
                case 'remove':
                  onRemove?.call();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sync',
                child: Text('Sync metrics'),
              ),
              const PopupMenuItem(
                value: 'remove',
                child: Text('Remove device'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
