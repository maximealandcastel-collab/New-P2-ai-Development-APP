import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/features/authentication/domain/services/auth_services.dart';

class ChangePasswordController extends GetxController {
  final AuthService _authService;

  static ChangePasswordController get to => Get.find();

  ChangePasswordController({required AuthService authService})
      : _authService = authService;

  final _changePasswordState = LoadingState.initial.obs;

  LoadingState get changePasswordState => _changePasswordState.value;

  final formKey = GlobalKey<FormState>();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  Future<void> changePassword() async {
    if (!formKey.currentState!.validate()) return;

    _changePasswordState.value = LoadingState.loading;

    try {
      await _authService.changePassword(
        oldPassword: oldPasswordController.text,
        newPassword: newPasswordController.text,
      );
      _changePasswordState.value = LoadingState.loaded;
      ToastMessageHelper.show('Password changed successfully');
      Get.back();
    } catch (e) {
      _changePasswordState.value = LoadingState.error;
      ToastMessageHelper.show(e.errorMessage);
    }
  }

  @override
  void onClose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
