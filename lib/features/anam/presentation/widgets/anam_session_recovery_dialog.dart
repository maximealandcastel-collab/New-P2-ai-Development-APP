import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/anam/data/anam_session_store.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

Future<AnamSessionRecoveryChoice?> showAnamSessionRecoveryDialog({
  required String trainerName,
  bool forceEndOnly = false,
}) async {
  final context = Get.context;
  if (context == null) return null;

  return showDialog<AnamSessionRecoveryChoice>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return CustomDialog(
        title: 'Active call session',
        titleColor: AppColors.textPrimary,
        description: forceEndOnly
            ? 'You already have an active AI call with another trainer. End it to start a new call.'
            : 'Your previous AI call with $trainerName was interrupted. End the session or continue the call.',
        leftButtonLabel: forceEndOnly ? 'Cancel' : 'Continue call',
        rightButtonLabel: 'End session',
        leftButtonLabelColor: forceEndOnly
            ? AppColors.textSecondary
            : AppColors.primary,
        rightButtonBgColor: AppColors.error,
        onTapLeftButton: () {
          Navigator.of(dialogContext).pop(
            forceEndOnly
                ? AnamSessionRecoveryChoice.cancel
                : AnamSessionRecoveryChoice.continueCall,
          );
        },
        onTapRightButton: () {
          Navigator.of(dialogContext).pop(AnamSessionRecoveryChoice.endSession);
        },
      );
    },
  );
}
