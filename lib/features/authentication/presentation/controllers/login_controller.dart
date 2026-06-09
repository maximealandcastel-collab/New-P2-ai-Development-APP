import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/features/authentication/domain/services/auth_services.dart';

class LoginController extends GetxController {
  final AuthService _authService;

  static LoginController get to => Get.find();

  LoginController({required AuthService authService})
    : _authService = authService;

  // ─── State ───────────────────────────────

  final _loginState = LoadingState.initial.obs;
  final RxString _selectedRole = 'Trainer'.obs;

  LoadingState get loginState => _loginState.value;
  String get selectedRole => _selectedRole.value;

  final loginFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void changeRole(String role) {
    _selectedRole.value = role;
    debugPrint('Selected role: $role');
  }

  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;

    _loginState.value = LoadingState.loading;

    try {
      final result = await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      _loginState.value = LoadingState.loaded;
    } catch (e) {
      _loginState.value = LoadingState.error;
    }
  }
}
