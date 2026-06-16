import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/authentication/domain/services/auth_services.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/forget_pass_controller.dart';

class ResetPassController extends GetxController {
  final AuthService _authService;

  static ResetPassController get to => Get.find();

  ResetPassController({required AuthService authService})
    : _authService = authService;

  // ─── State ───────────────────────────────

  final _resetState = LoadingState.initial.obs;

  LoadingState get resetState => _resetState.value;

  final resetFormKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  Future<void> resetPassword() async {
    if (!resetFormKey.currentState!.validate()) return;

    _resetState.value = LoadingState.loading;

    try {
      await _authService.resetPassword(
        email: ForgetController.to.emailController.text.trim(),
        newPassword: confirmPasswordController.text,
      );
      _resetState.value = LoadingState.loaded;
      Get.offAllNamed(AppRoute.loginScreen);
    } catch (e) {
      _resetState.value = LoadingState.error;
    }
  }

  @override
  void dispose() {
    super.dispose();
    confirmPasswordController.dispose();
    ForgetController.to.emailController.dispose();
  }
}
