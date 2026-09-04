import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pler_to_pler_app/core/constants/app_constants.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/authentication/domain/services/auth_services.dart';
import 'package:pler_to_pler_app/features/profile/domain/services/profile_service.dart';
import 'package:pler_to_pler_app/core/services/admin_mode_service.dart';
import 'package:pler_to_pler_app/core/services/affiliate_mode_service.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:pler_to_pler_app/services/stream_chat_service.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/screens/kmf_gym_admin_dashboard_screen.dart';

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
  /// Set the active role tab on the login screen ('Trainer' or 'User').
  void setRole(String role) => _selectedRole.value = role;

  static const _kSaveLoginKey = 'saveLogin';

  final loginFormKey = GlobalKey<FormState>();
  // Debug-only convenience prefill. The kDebugMode guard is what keeps
  // credentials out of a shipped binary even if the defines are set at build
  // time — a release build always starts with empty fields.
  final emailController    = TextEditingController(
    text: kDebugMode
        ? const String.fromEnvironment('PREFILL_EMAIL', defaultValue: '')
        : '',
  );
  final passwordController = TextEditingController(
    text: kDebugMode
        ? const String.fromEnvironment('PREFILL_PASSWORD', defaultValue: '')
        : '',
  );

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

      final loginEmail  = emailController.text.trim().toLowerCase();
      final role        = _authService.getRole() ?? '';
      final gymAdminTenantIds =
          CacheService().get<List<dynamic>>('gymAdminTenantIds') ?? const [];

      // Tenant authorization is backend-issued and deliberately takes
      // precedence over the global admin flow. KMF administrators never enter
      // the Founder Console or the global Admin/User view toggle.
      if (gymAdminTenantIds
          .map((tenantId) => tenantId.toString())
          .contains('kmf-fitness')) {
        Get.offAll(() => const KmfGymAdminDashboardScreen());
        return;
      }

      // Owner accounts must complete the official admin activation step.
      // The bypass screen sends the entered code to the authenticated backend;
      // never embed the owner PIN in the client or silently grant admin mode.
      if (AppConstants.ownerEmails.contains(loginEmail)) {
        await prefs.setBool('sessionPersisted', true);
        Get.offAllNamed(AppRoute.adminBypassScreen);
        return;
      }
      // Other admins → AdminBypassScreen (enter code to unlock dashboard).
      if (role == 'admin') {
        Get.offAllNamed(AppRoute.adminBypassScreen);
        return;
      }

      Get.offAllNamed(AppRoute.bottonNavBar);
    } on NoInternetException {
      _loginState.value = LoadingState.error;
      ToastMessageHelper.show('No internet connection');
    } on UnAuthorizedException catch (e) {
      _loginState.value = LoadingState.error;
      ToastMessageHelper.show(e.details ?? e.message);
    } catch (e) {
      _loginState.value = LoadingState.error;
      ToastMessageHelper.show(e.toString().replaceFirst('Exception: ', ''));
    }
  }
  /// Returns true if a user is currently signed in.
  bool isLoggedIn() => _authService.getRole() != null;

  /// Deletes the account server-side then logs out.
  /// Deletes the account server-side, then clears the local session.
  ///
  /// This used to be `await logout()` and nothing else — it never called the
  /// endpoint. Everything below it was already wired: AuthService.deleteAccount
  /// calls AuthRepository.deleteAccount, which DELETEs
  /// `/api/v1/auth/account-delete`, and that route exists on the backend. Only
  /// this method was skipping the chain, so "Delete my account" silently signed
  /// the user out and left the account intact.
  ///
  /// Failures are rethrown rather than swallowed. Reporting a deletion that did
  /// not happen is the same false-success pattern fixed in the admin write
  /// paths — and here the user believes their data is gone.
  /// Both calls are needed. AuthService.deleteAccount() deletes server-side and
  /// then calls AuthService.logout(), but that only clears Hive — it does not
  /// touch AdminModeService/AffiliateModeService (both permanent, both outside
  /// Hive), does not clear the SharedPreferences admin keys, and does not
  /// navigate. This controller's logout() does all of that. Calling
  /// AuthService.logout() twice is harmless.
  Future<void> deleteAccount() async {
    await _authService.deleteAccount();
    await logout();
  }

  /// Returns the email cached at login, falling back to whatever is typed in
  /// the form. Session restore runs before anything has been typed, so the
  /// cached value is the only reliable source on a cold start.
  String? getCachedEmail() {
    final cached = _authService.getEmail()?.trim();
    if (cached != null && cached.isNotEmpty) return cached;
    final typed = emailController.text.trim();
    return typed.isEmpty ? null : typed;
  }


  bool isTrainer() => _authService.getRole() == 'trainer';

  Future<void> logout() async {
    // Clear the sign-in form. This controller is permanent, so its
    // TextEditingControllers survive logout — the login screen was coming back
    // with the previous account's email filled in and their password still in
    // the password field. Anyone handing the phone over, or a second account on
    // a shared device, was shown the last user's credentials.
    emailController.clear();
    passwordController.clear();
    try {
      await StreamChatService.instance.disconnect();
    } catch (_) {}
    try {
      await _authService.logout();
    } catch (_) {}
    // Admin/affiliate state lives outside Hive and both services are registered
    // permanent, so AuthRepository.logout() does not touch them. Without this
    // the next account signed in on the same device inherits admin mode.
    try {
      if (Get.isRegistered<AdminModeService>()) {
        await AdminModeService.to.deactivate();
      }
    } catch (_) {}
    try {
      if (Get.isRegistered<AffiliateModeService>()) {
        AffiliateModeService.to.deactivate();
      }
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('sessionPersisted');
      await prefs.remove(AppConstants.prefAdminDashboardMode);
      await prefs.remove(AppConstants.prefAdminToken);
    } catch (_) {}
    Get.offAllNamed(AppRoute.loginScreen);
  }
}
