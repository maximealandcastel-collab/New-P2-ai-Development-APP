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
import 'package:pler_to_pler_app/services/stream_chat_service.dart';

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

  static const _kSaveLoginKey = 'saveLogin';

  final loginFormKey = GlobalKey<FormState>();
  final emailController    = TextEditingController(text: kDebugMode ? 'gabriel@trainer.com' : '');
  final passwordController = TextEditingController(text: kDebugMode ? 'Password123!' : '');

  @override
  void onInit() {
    super.onInit();
    _restoreSaveLoginPreference();
  }

  Future<void> _restoreSaveLoginPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      saveLogin.value = prefs.getBool(_kSaveLoginKey) ?? false;
    } catch (_) {}
  }

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

      final prefs = await SharedPreferences.getInstance();
      if (saveLogin.value) {
        await prefs.setBool('sessionPersisted', true);
      } else {
        await prefs.remove('sessionPersisted');
      }

      // ── Connect Stream Chat in the background (non-blocking) ─────────────
      // We fire-and-forget so login navigation is instant; the chat screen
      // itself also calls initFromBackend() as a safety net.
      StreamChatService.instance.initFromBackend().ignore();

      const ownerEmails = {'pmoney78q@gmail.com'};
      final loginEmail  = emailController.text.trim().toLowerCase();
      final role        = _authService.getRole() ?? '';

      if (ownerEmails.contains(loginEmail)) {
        Get.offAll(() => BottomNavBar());
        return;
      }

      if (role == 'admin') {
        Get.offAll(() => AdminBypassScreen());
        return;
      }

      Get.offAll(() => BottomNavBar());
    } on NoInternetException {
      _loginState.value = LoadingState.error;
      ToastMessageHelper.show('No internet connection');
    } on AppException catch (e) when (e.errorCode == 'UNAUTHORIZED') {
      _loginState.value = LoadingState.error;
      ToastMessageHelper.show('Invalid email or password');
    } catch (e) {
      _loginState.value = LoadingState.error;
      ToastMessageHelper.show(e.toString().replaceFirst('Exception: ', ''));
    }
  }
  /// Returns true if a user is currently signed in.
  bool isLoggedIn() => _authService.getRole() != null;

  /// Deletes the account server-side then logs out.
  Future<void> deleteAccount() async {
    try {
      await _profileService.deleteAccount();
    } catch (_) {
      // proceed with local logout even if server call fails
    }
    await logout();
  }

  /// Returns the cached login email (used by chat/notification screens).
  String? getCachedEmail() {
    final e = emailController.text.trim();
    return e.isEmpty ? null : e;
  }


  bool isTrainer() => _authService.getRole() == 'trainer';

  Future<void> logout() async {
    try {
      await StreamChatService.instance.disconnect();
    } catch (_) {}
    try {
      await _authService.logout();
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('sessionPersisted');
    } catch (_) {}
    Get.offAllNamed(AppRoute.login);
  }
}