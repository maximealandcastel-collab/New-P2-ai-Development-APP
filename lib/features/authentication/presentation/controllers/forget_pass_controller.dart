import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import '../../domain/services/auth_services.dart';

class ForgetController extends GetxController {
  final AuthService _authService;

  static ForgetController get to => Get.find();

  ForgetController({required AuthService authService})
    : _authService = authService;

  final _forgotState = LoadingState.initial.obs;

  LoadingState get forgotState => _forgotState.value;

  final forgotFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();


  Future<void> forgot() async {
    if (!forgotFormKey.currentState!.validate()) return;
    try {
      _forgotState.value = LoadingState.loading;

      await _authService.forgotPassword(
        emailController.text.trim(),
      );
      _forgotState.value = LoadingState.loaded;
      Get.toNamed(AppRoute.otpVerificationScreen,arguments: 'forgot');
    } catch (e) {
      ToastMessageHelper.show(e.errorMessage);
      _forgotState.value = LoadingState.error;
    }
  }

  Timer? _resendTimer;
  final _resendSeconds = 0.obs;

  int get resendSeconds => _resendSeconds.value;
  bool get canResend => _resendSeconds.value == 0;

  void startResendTimer() {
    _resendSeconds.value = 72;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds.value == 0) {
        timer.cancel();
      } else {
        _resendSeconds.value--;
      }
    });
  }

  Future<void> resendOtp() async {
    startResendTimer();
    try {
      await _authService.resendOtp(email: emailController.text.trim());
    } catch (e) {
      debugPrint('Error resending OTP: $e');
    }
  }

}
