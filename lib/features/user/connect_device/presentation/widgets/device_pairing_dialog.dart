import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/user/connect_device/data/models/device_model.dart';
import 'package:pler_to_pler_app/features/user/connect_device/presentation/controllers/device_pairing_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class DevicePairingDialog extends StatelessWidget {
  const DevicePairingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = DevicePairingController.to;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Obx(() {
          switch (controller.pairingStep.value) {
            case PairingStep.scanning:
              return _ScanningContent(controller: controller);
            case PairingStep.connecting:
            case PairingStep.saving:
              return _ProgressContent(controller: controller);
            case PairingStep.idle:
              return const SizedBox.shrink();
          }
        }),
      ),
    );
  }
}

class _ScanningContent extends StatelessWidget {
  const _ScanningContent({required this.controller});

  final DevicePairingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomText(
                text: 'Scanning for devices',
                textAlign: TextAlign.start,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            IconButton(
              onPressed: controller.cancelPairing,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        CustomText(
          text: 'Choose a nearby fitness device to connect.',
          textAlign: TextAlign.start,
          fontSize: 13.sp,
          color: AppColors.textSecondary,
        ),
        SizedBox(height: 16.h),
        Obx(() {
          if (controller.discoveredDevices.isEmpty) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Center(
                child: Column(
                  children: [
                    SizedBox(
                      width: 28.r,
                      height: 28.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    CustomText(
                      text: 'Searching for devices...',
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            );
          }

          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 260.h),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: controller.discoveredDevices.length,
              separatorBuilder: (_, _) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                final device = controller.discoveredDevices[index];
                return _ScanResultTile(
                  device: device,
                  onTap: () => controller.selectAndConnectDevice(device),
                );
              },
            ),
          );
        }),
      ],
    );
  }
}

class _ProgressContent extends StatelessWidget {
  const _ProgressContent({required this.controller});

  final DevicePairingController controller;

  @override
  Widget build(BuildContext context) {
    final isSaving = controller.pairingStep.value == PairingStep.saving;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 42.r,
          height: 42.r,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 16.h),
        CustomText(
          text: isSaving ? 'Saving device...' : 'Connecting device...',
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
        ),
        SizedBox(height: 8.h),
        CustomText(
          text: isSaving
              ? 'Registering your wearable with your account.'
              : 'Please keep your device nearby.',
          textAlign: TextAlign.center,
          color: AppColors.textSecondary,
          fontSize: 13.sp,
        ),
        SizedBox(height: 16.h),
        Obx(
          () => LinearProgressIndicator(
            value: controller.pairingProgress.value,
            minHeight: 6.h,
            borderRadius: BorderRadius.circular(99.r),
            backgroundColor: AppColors.backgroundLight,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _ScanResultTile extends StatelessWidget {
  const _ScanResultTile({
    required this.device,
    required this.onTap,
  });

  final BluetoothScanResultModel device;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      radiusAll: 12.r,
      color: AppColors.backgroundLight,
      paddingHorizontal: 12.w,
      paddingVertical: 12.h,
      child: Row(
        children: [
          Icon(Icons.watch_outlined, color: AppColors.textSecondary),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: device.name,
                  textAlign: TextAlign.start,
                  fontWeight: FontWeight.w600,
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
          Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
