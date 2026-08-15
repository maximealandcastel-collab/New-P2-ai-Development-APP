import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/authentication/domain/services/auth_services.dart';
import 'package:pler_to_pler_app/features/profile/domain/services/profile_service.dart';
import 'package:pler_to_pler_app/core/services/admin_mode_service.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/admin_bypass_screen.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/bottom_nav_bar.dart';

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

  /// Whether the user has ticked "Save Login" on the sign-in screen.
  final saveLogin = false.obs;

  LoadingState get loginState => _loginState.value;
  String get selectedRole => _selectedRole.value;

  static const _kSaveLoginKey = 'saveLogin'; // SharedPreferences key

  final loginFormKey = GlobalKey<FormState>();
  final emailController    = TextEditingController(text: kDebugMode ? 'gabriel@trainer.com' : '');
  final passwordController = TextEditingController(text: kDebugMode ? 'Password123!' : '');

  @override
  void onInit() {
    super.onInit();
    _restoreSaveLoginPreference();
  }

  /// Restore "Save Login" checkbox state from SharedPreferences.
  Future<void> _restoreSaveLoginPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      saveLogin.value = prefs.getBool(_kSaveLoginKey) ?? false;
    } catch (_) {}
  }

  /// Persist "Save Login" selection every time the user toggles it.
  Future<void> toggleSaveLogin() async {
    saveLogin.value = !saveLogin.value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kSaveLoginKey, saveLogin.value);
    } catch (_) {}
  }

  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;

    _loginState.value = LoadingState.loading;

    try {
      await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      _loginState.value = LoadingState.loaded;

      // ── Persist "Save Login" flag ─────────────────────────────────────
      // If the user opted in, mark the session as persistent so the
      // SplashController can skip login on the next cold launch.
      final prefs = await SharedPreferences.getInstance();
      if (saveLogin.value) {
        await prefs.setBool('sessionPersisted', true);
      } else {
        await prefs.remove('sessionPersisted');
      }

      // ── Admin activation ──────────────────────────────────────────────
      // Hardcoded owner emails always get trainer+admin nav regardless of role.
      const ownerEmails = {'pmoney78q@gmail.com'};
      final loginEmail  = emailController.text.trim().toLowerCase();
      final role        = _authService.getRole() ?? '';
      final isOwner     = ownerEmails.contains(loginEmail) || role == 'admin';

      if (isOwner) {
        if (!Get.isRegistered<AdminModeService>()) {
          await Get.putAsync(() async => AdminModeService());
        }
        // activate() restores the admin's last saved dashboard mode.
        // Default is User UX — admin sees the real customer experience first.
        await AdminModeService.to.activate();
        Get.offAll(() => const BottomNavBarMain());
      } else {
        // All other roles go through the bypass screen (PIN optional)
        Get.offAll(() => AdminBypassScreen());
      }
    } catch (e) {
      _loginState.value = LoadingState.error;
      if (kDebugMode) debugPrint('[Login] error: $e');
    }
  }

  bool isTrainer() {
    final role = _authService.getRole();
    if (role != null) {
      return role == 'trainer';
    }
    return false;
  }

  /// Returns the email cached at login — used by SplashController to restore
  /// admin mode on app restart without re-authenticating.
  String? getCachedEmail() => _authService.getEmail();

  /// ─── LOGOUT ────────────────────────────
  Future<void> logout() async {
    Get.back();
    // Clear "Save Login" persistence so cold launch goes to login screen.
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('sessionPersisted');
    } catch (_) {}
    // Deactivate admin mode if needed.
    if (Get.isRegistered<AdminModeService>()) {
      await AdminModeService.to.deactivate();
    }
    await _authService.logout();
    Get.offAllNamed(AppRoute.loginScreen);
  }

  /// ─── DELETE ACCOUNT ────────────────────
  Future<void> deleteAccount() async {
    Get.back();
    try {
      await _authService.deleteAccount();
      Get.offAllNamed(AppRoute.loginScreen);
    } on AppException catch (e) {
      ToastMessageHelper.show(e.errorMessage);
    } catch (e) {
      ToastMessageHelper.show('Failed to delete account. Please try again.');
      if (kDebugMode) debugPrint('Delete account error: $e');
    }
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
