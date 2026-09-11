import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/features/paywall/controllers/paywall_controller.dart';
import '../../domain/services/auth_services.dart';

class OtpController extends GetxController {
  final AuthService _authService;

  static OtpController get to => Get.find();

  OtpController({required AuthService authService})
    : _authService = authService;

  final _otpState = LoadingState.initial.obs;

  LoadingState get otpState => _otpState.value;

  final otpFormKey = GlobalKey<FormState>();
  final otpController = TextEditingController();


  bool isTrainer() {
    final role = _authService.getRole();
    if (role != null) {
      return role == 'trainer';
    }
    return false;
  }



  Future<bool> otpVerify({String? requiredTenantId, GlobalKey<FormState>? formKey}) async {
    if (!(formKey ?? otpFormKey).currentState!.validate()) return false;

    _otpState.value = LoadingState.loading;
    try {
      await _authService.otpVerify(
        otp: otpController.text.trim(),
        requiredTenantId: requiredTenantId,
      );
      if ((Get.arguments ?? '') == 'signup' && !isTrainer()) {
        final activated = await PaywallController.to.activatePendingEntitlement();
        if (!activated) {
          ToastMessageHelper.show(
            'Your account is verified. Subscription activation is still processing.',
          );
        }
      }
      _otpState.value = LoadingState.loaded;
      return true;
    } catch (e) {
      _otpState.value = LoadingState.error;
      ToastMessageHelper.show(e.errorMessage);
      return false;
    }
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }
}
