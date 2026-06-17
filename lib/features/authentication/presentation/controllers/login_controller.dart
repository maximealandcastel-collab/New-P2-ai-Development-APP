import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/authentication/domain/services/auth_services.dart';
import 'package:pler_to_pler_app/features/profile/domain/services/profile_service.dart';

class LoginController extends GetxController {
  final AuthService _authService;
  final ProfileService _profileService;

  static LoginController get to => Get.find();

  LoginController({
    required AuthService authService,
    required ProfileService profileService,
  }) : _authService = authService,
       _profileService = profileService;

  // ─── State ───────────────────────────────

  final _loginState = LoadingState.initial.obs;
  final RxString _selectedRole = 'Trainer'.obs;

  LoadingState get loginState => _loginState.value;
  String get selectedRole => _selectedRole.value;

  final loginFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController(text: kDebugMode ? 'gabriel@trainer.com' : '');
  final passwordController = TextEditingController(text: kDebugMode ? 'Password123!' : '');



  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;

    _loginState.value = LoadingState.loading;

    try {
       await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      _loginState.value = LoadingState.loaded;
      final route = await _profileService.resolveInitialRoute();
      Get.offAllNamed(route);
    } catch (e) {
      _loginState.value = LoadingState.error;
    }
  }

  bool isTrainer() {
    final role = _authService.getRole();
    if (role != null) {
      return role == 'trainer';
    }
    return false;
  }

  /// ─── LOGOUT ────────────────────────────
  Future<void> logout() async {
    Get.back();
    await _authService.logout();
    Get.offAllNamed(AppRoute.loginScreen);
  }

  /// ─── IS LOGGED IN ──────────────────────
  bool isLoggedIn() => _authService.isLoggedIn();


  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

}
