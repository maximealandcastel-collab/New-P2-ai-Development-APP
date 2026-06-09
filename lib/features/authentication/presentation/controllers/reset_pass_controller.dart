import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/features/authentication/domain/services/auth_services.dart';

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
      final result = await _authService.resetPassword(
      newPassword: confirmPasswordController.text,
      );
      _resetState.value = LoadingState.loaded;
    } catch (e) {
      _resetState.value = LoadingState.error;
    }
  }
}
