import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/authentication/domain/services/auth_services.dart';

class SignUpController extends GetxController {
  final AuthService _authService;

  static SignUpController get to => Get.find();

  SignUpController({required AuthService authService})
    : _authService = authService;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final genderController = TextEditingController();
  final emailController = TextEditingController(
    text: kDebugMode ? 'dev.milon923@gmail.com' : '',
  );
  final passwordController = TextEditingController(
    text: kDebugMode ? '1qazxsw2' : '',
  );
  final confirmPasswordController = TextEditingController();

  final registerFormKey = GlobalKey<FormState>();

  final _registerState = LoadingState.initial.obs;

  LoadingState get registerState => _registerState.value;

  final RxString _selectedRole = 'Trainer'.obs;

  String get selectedRole => _selectedRole.value;

  void changeRole(String role) {
    _selectedRole.value = role;
    debugPrint('Selected role: $role');
  }

  Future<void> register() async {
    if (!registerFormKey.currentState!.validate()) return;

    _registerState.value = LoadingState.loading;
    try {
      await _authService.register(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        gender: genderController.text.trim().toLowerCase(),
        role: _selectedRole.value.toLowerCase(),
        password: confirmPasswordController.text,
      );
      _registerState.value = LoadingState.loaded;
      Get.toNamed(AppRoute.otpVerificationScreen,arguments: 'signup');
    } catch (e) {
      ToastMessageHelper.show(e.errorMessage);
      _registerState.value = LoadingState.error;
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    genderController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
