import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/services/api_service.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';

class PhoneOtpController extends GetxController {
  final ApiService _api;

  PhoneOtpController({required ApiService api}) : _api = api;

  static PhoneOtpController get to => Get.find();

  @override
  void onReady() {
    super.onReady();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      startVerification(
        args['phone']?.toString() ?? '',
        args['role']?.toString() ?? 'user',
      );
    }
  }

  // phone number displayed on the waiting screen
  final _phone = ''.obs;
  String get phone => _phone.value;

  final _isVerified = false.obs;
  bool get isVerified => _isVerified.value;

  final _isSending = false.obs;
  bool get isSending => _isSending.value;

  Timer? _pollTimer;
  int _pollCount = 0;
  static const int _maxPolls = 100; // ~5 min at 3s each

  // role to forward after confirmation
  String _role = 'user';

  // ── Entry point called from SignUpController ─────────────────────────────
  Future<void> startVerification(String phone, String role) async {
    _phone.value = phone;
    _role = role;
    _isSending.value = true;

    try {
      await _api.post(ApiConstants.phoneSendOtp, data: {'phone': phone});
    } catch (e) {
      ToastMessageHelper.show('Could not send SMS — please try again');
    } finally {
      _isSending.value = false;
    }

    _startPolling();
  }

  void _startPolling() {
    _pollCount = 0;
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _poll());
  }

  Future<void> _poll() async {
    _pollCount++;
    if (_pollCount > _maxPolls) {
      _pollTimer?.cancel();
      ToastMessageHelper.show('Verification timed out — please try again');
      return;
    }

    try {
      final resp = await _api.get(ApiConstants.phoneOtpStatus);
      final verified = resp.data?['data']?['verified'] == true;
      if (verified) {
        _isVerified.value = true;
        _pollTimer?.cancel();
        _proceed();
      }
    } catch (_) {
      // silently retry
    }
  }

  void _proceed() {
    if (_role == 'trainer') {
      Get.offNamed(AppRoute.trainerCompleteProfileScreen);
    } else {
      Get.offNamed(AppRoute.userCompleteProfileScreen);
    }
  }

  /// Manual resend
  Future<void> resend() async {
    if (_isSending.value) return;
    _isSending.value = true;
    try {
      await _api.post(ApiConstants.phoneSendOtp, data: {'phone': _phone.value});
      ToastMessageHelper.show('Verification text resent!');
      _startPolling();
    } catch (_) {
      ToastMessageHelper.show('Could not resend — please try again');
    } finally {
      _isSending.value = false;
    }
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    super.onClose();
  }
}
