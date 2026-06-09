import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import '../../domain/services/auth_services.dart';

class ForgetPassController extends GetxController {
  final AuthService _authService;

  static ForgetPassController get to => Get.find();

  ForgetPassController(AuthService authService) : _authService = authService;

  // ─── Email Verification State ───────────────────────────────
  final _verifyEmailState = LoadingState.initial.obs;
  LoadingState get verifyEmailState => _verifyEmailState.value;

  final emailVerificationFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  // ─── OTP Verification State ───────────────────────────────
  final _verifyOtpState = LoadingState.initial.obs;
  LoadingState get verifyOtpState => _verifyOtpState.value;

  // OTP টাইমার
  final _remainingSeconds = 90.obs;
  int get remainingSeconds => _remainingSeconds.value;

  final _canResend = false.obs;
  bool get canResend => _canResend.value;

  Timer? _timer;

  // OTP ইনপুট ফিল্ড (6 টি)
  late List<TextEditingController> otpControllers;
  late List<FocusNode> otpFocusNodes;

  @override
  void onInit() {
    super.onInit();
    // ৬টি OTP ফিল্ড ইনিশিয়ালাইজ করো
    otpControllers = List.generate(6, (index) => TextEditingController());
    otpFocusNodes = List.generate(6, (index) => FocusNode());
  }

  // ─── Email Verification Method ───────────────────────────────
  Future<void> verifyEmail() async {
    if (!emailVerificationFormKey.currentState!.validate()) return;

    _verifyEmailState.value = LoadingState.loading;

    try {
      // Backend এ email verify করার API কল করো
      // final result = await _authService.verifyEmail(emailController.text.trim());

      _verifyEmailState.value = LoadingState.loaded;
      Get.toNamed(AppRoute.otpVerificationScreen);
      // OTP টাইমার শুরু করো
      _startOtpTimer();

    } catch (e) {
      _verifyEmailState.value = LoadingState.error;
    }
  }

  // ─── OTP Timer Logic ───────────────────────────────
  void _startOtpTimer() {
    _remainingSeconds.value = 90;
    _canResend.value = false;

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _remainingSeconds.value--;

      if (_remainingSeconds.value <= 0) {
        _canResend.value = true;
        timer.cancel();
      }
    });
  }

  // ─── OTP Resend Method ───────────────────────────────
  Future<void> resendOtp() async {
    if (!_canResend.value) return;

    try {
      // Backend এ resend OTP API কল করো
      // final result = await _authService.resendOtp(emailController.text.trim());

      _startOtpTimer();
    } catch (e) {
      // Error handling
    }
  }

  // ─── OTP সব ফিল্ড পূরণ আছে কিনা চেক করো ───────────────────────────────
  bool get isOtpComplete {
    return otpControllers.every((controller) => controller.text.isNotEmpty);
  }

  // ─── সম্পূর্ণ OTP পান করো ───────────────────────────────
  String getFullOtp() {
    return otpControllers.map((e) => e.text).join();
  }

  // ─── OTP Verification Method ───────────────────────────────
  Future<void> verifyOtp() async {
    if (!isOtpComplete) return;

    _verifyOtpState.value = LoadingState.loading;

    try {
      final otp = getFullOtp();
      // Backend এ OTP verify করার API কল করো
      // final result = await _authService.verifyOtp(
      //   email: emailController.text.trim(),
      //   otp: otp,
      // );

      _verifyOtpState.value = LoadingState.loaded;

      // Success - পাসওয়ার্ড রিসেট পেজে যাও অথবা লগইন পেজে ফিরে যাও
      // Get.toNamed(AppRoute.resetPasswordScreen);

    } catch (e) {
      _verifyOtpState.value = LoadingState.error;
    }
  }

  // ─── OTP ফিল্ড handle করার method (auto-focus পরবর্তী field এ) ───────────────────────────────
  void handleOtpInput(String value, int index) {
    if (value.isEmpty) {
      // যদি খালি হয় তাহলে আগের field এ ফোকাস করো
      if (index > 0) {
        otpFocusNodes[index - 1].requestFocus();
      }
    } else {
      // একটি character হলে পরবর্তী field এ যাও
      if (index < 5) {
        otpFocusNodes[index + 1].requestFocus();
      } else {
        // সর্বশেষ field এ হলে keyboard বন্ধ করো
        otpFocusNodes[index].unfocus();
      }
    }
  }

  // ─── Cleanup ───────────────────────────────
  @override
  void onClose() {
    _timer?.cancel();
    emailController.dispose();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var focusNode in otpFocusNodes) {
      focusNode.dispose();
    }
    super.onClose();
  }
}