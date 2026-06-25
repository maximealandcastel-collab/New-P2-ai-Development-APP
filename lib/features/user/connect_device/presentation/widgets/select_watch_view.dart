import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/user/connect_device/domain/constants/supported_watch_type.dart';
import 'package:pler_to_pler_app/features/user/connect_device/presentation/controllers/device_pairing_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class SelectWatchView extends StatelessWidget {
  const SelectWatchView({super.key, required this.controller});

  final DevicePairingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 8.h),
        CustomText(
          text: 'Choose your watch',
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        CustomText(
          text:
              'Only one watch can be active at a time. Switching watches replaces your current connection.',
          fontSize: 13.sp,
          color: AppColors.textSecondary,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24.h),
        Obx(() {
          if (controller.pairingError.value.isNotEmpty) {
            return Column(
              children: [
                CustomContainer(
                  radiusAll: 12.r,
                  paddingAll: 12.r,
                  color: Colors.redAccent.withValues(alpha: 0.08),
                  child: CustomText(
                    text: controller.pairingError.value,
                    textAlign: TextAlign.center,
                    color: Colors.redAccent,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            );
          }
          return const SizedBox.shrink();
        }),
        ...SupportedWatchType.all.map((watchType) {
          final isAppleOnNonIos =
              watchType.usesHealthKit && !Platform.isIOS;
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _WatchTypeCard(
              watchType: watchType,
              enabled: !isAppleOnNonIos,
              disabledHint: isAppleOnNonIos ? 'Available on iPhone only' : null,
              onTap: () => controller.selectWatchType(watchType),
            ),
          );
        }),
      ],
    );
  }
}

class _WatchTypeCard extends StatelessWidget {
  const _WatchTypeCard({
    required this.watchType,
    required this.enabled,
    required this.onTap,
    this.disabledHint,
  });

  final SupportedWatchType watchType;
  final bool enabled;
  final VoidCallback onTap;
  final String? disabledHint;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: enabled ? onTap : null,
      radiusAll: 14.r,
      color: Colors.white,
      paddingHorizontal: 14.w,
      paddingVertical: 14.h,
      child: Row(
        children: [
          CustomContainer(
            radiusAll: 12.r,
            paddingAll: 10.r,
            color: enabled
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.backgroundLight,
            child: Icon(
              watchType.usesHealthKit
                  ? Icons.favorite_outline
                  : Icons.bluetooth,
              color: enabled ? AppColors.primary : AppColors.textSecondary,
              size: 22.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: watchType.displayName,
                  textAlign: TextAlign.start,
                  fontWeight: FontWeight.w600,
                  fontSize: 15.sp,
                  color: enabled ? null : AppColors.textSecondary,
                ),
                CustomText(
                  top: 2.h,
                  text: disabledHint ?? watchType.description,
                  textAlign: TextAlign.start,
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: enabled ? AppColors.textSecondary : Colors.grey.shade400,
            size: 20.r,
          ),
        ],
      ),
    );
  }
}
