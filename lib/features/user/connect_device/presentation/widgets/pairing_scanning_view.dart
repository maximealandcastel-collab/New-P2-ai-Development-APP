import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/user/connect_device/presentation/controllers/device_pairing_controller.dart';
import 'package:pler_to_pler_app/features/user/connect_device/presentation/widgets/pairing_pulse_indicator.dart';
import 'package:pler_to_pler_app/features/user/connect_device/presentation/widgets/pairing_scan_result_tile.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class PairingScanningView extends StatelessWidget {
  const PairingScanningView({super.key, required this.controller});

  final DevicePairingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 8.h),
        const Center(child: PairingPulseIndicator()),
        SizedBox(height: 20.h),
        Obx(
          () => CustomText(
            text: controller.selectedWatchType.value != null
                ? 'Searching for ${controller.selectedWatchType.value!.displayName}'
                : 'Searching nearby devices',
            fontSize: 18.sp,
            fontWeight: AppFontWeight.section,
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 8.h),
        CustomText(
          text: 'Only supported watches appear here. Keep your watch close to your phone.',
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
                CustomButton(
                  label: 'Try again',
                  onPressed: controller.retryScanning,
                ),
              ],
            );
          }

          if (controller.discoveredDevices.isEmpty) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 32.h),
              child: CustomText(
                text: controller.selectedWatchType.value != null
                    ? 'No ${controller.selectedWatchType.value!.displayName} found yet...'
                    : 'No devices found yet...',
                textAlign: TextAlign.center,
                color: AppColors.textSecondary,
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.discoveredDevices.length,
            separatorBuilder: (_, _) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              final device = controller.discoveredDevices[index];
              return PairingScanResultTile(
                device: device,
                onTap: () => controller.selectAndConnectDevice(device),
              );
            },
          );
        }),
      ],
    );
  }
}
