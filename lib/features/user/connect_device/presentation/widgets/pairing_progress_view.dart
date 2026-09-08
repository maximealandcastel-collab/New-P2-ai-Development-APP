import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/user/connect_device/presentation/controllers/device_pairing_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class PairingProgressView extends StatefulWidget {
  const PairingProgressView({super.key, required this.controller});

  final DevicePairingController controller;

  @override
  State<PairingProgressView> createState() => _PairingProgressViewState();
}

class _PairingProgressViewState extends State<PairingProgressView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = widget.controller.pairingStep.value == PairingStep.saving;

    return Column(
      children: [
        SizedBox(height: 24.h),
        RotationTransition(
          turns: _spinController,
          child: CustomContainer(
            shape: BoxShape.circle,
            paddingAll: 24.r,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            child: Icon(
              isSaving ? Icons.cloud_upload_outlined : Icons.link,
              size: 40.r,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        SizedBox(height: 24.h),
        CustomText(
          text: isSaving ? 'Saving device' : 'Connecting device',
          fontSize: 20.sp,
          fontWeight: AppFontWeight.section,
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
        SizedBox(height: 28.h),
        Obx(
          () => ClipRRect(
            borderRadius: BorderRadius.circular(99.r),
            child: LinearProgressIndicator(
              value: widget.controller.pairingProgress.value,
              minHeight: 8.h,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
