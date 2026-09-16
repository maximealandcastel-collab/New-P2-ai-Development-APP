import 'package:pler_to_pler_app/core/constants/enterprise_flags.dart';
import 'package:pler_to_pler_app/core/services/tenant_brand_service.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/screens/enterprise_gym_admin_dashboard_screen.dart';
import 'package:pler_to_pler_app/features/authentication/data/models/login_result_model.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/screens/enterprise_access_recovery_screen.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/tenant_configuration.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_gym_model.dart';
import 'package:pler_to_pler_app/features/gyms/data/services/enterprise_service.dart';
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
import 'package:pler_to_pler_app/core/themes/app_theme_data.dart';
import 'package:pler_to_pler_app/core/services/video_playback_manager.dart';
import 'package:pler_to_pler_app/services/stream_chat_service.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/data/models/nav_item_model.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/screens/enterprise_session_screen.dart';

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
  final emailController = TextEditingController(
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

  Future<void> login({
    String? requestedTenantId,
    GlobalKey<FormState>? formKey,
  }) async {
    if (_loginState.value == LoadingState.loading) return;
    final formState = (formKey ?? loginFormKey).currentState;
    if (formState == null || !formState.validate()) {
      passwordController.clear();
      return;
    }

    _loginState.value = LoadingState.loading;
    final submittedEmail = emailController.text.trim().toLowerCase();
    var authenticated = false;

    try {
      await CacheService().delete('tenantId');
      EnterpriseService.instance.clear();
      final loginResult = await _authService.login(
        email: submittedEmail,
        password: passwordController.text,
      );
      authenticated = true;

      final prefs = await SharedPreferences.getInstance();
      if (saveLogin.value) {
        await prefs.setBool('sessionPersisted', true);
      } else {
        await prefs.remove('sessionPersisted');
      }

      try {
        await _completeAuthenticatedLogin(
          loginResult,
          submittedEmail,
          requestedTenantId,
        );
      } catch (error) {
        await _resetUiForAuthenticatedSession();
        Get.offAll(
          () => EnterpriseAccessRecoveryScreen(
            initialError: error,
            onRetry: () => _completeAuthenticatedLogin(
              loginResult,
              submittedEmail,
              requestedTenantId,
            ),
            onSignOut: logout,
          ),
        );
      }
    } on NoInternetException {
      _loginState.value = LoadingState.error;
      ToastMessageHelper.show('No internet connection');
    } on UnAuthorizedException catch (e) {
      _loginState.value = LoadingState.error;
      ToastMessageHelper.show(e.details ?? e.message);
    } catch (e) {
      _loginState.value = LoadingState.error;
      ToastMessageHelper.show(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (_loginState.value == LoadingState.loading)
        _loginState.value = LoadingState.loaded;
      // LoginController is permanent, so field values otherwise survive route
      // changes and can appear when another person opens a tenant login.
      // Passwords are never retained, even after a failed attempt.
      passwordController.clear();
      if (authenticated && !saveLogin.value) {
        emailController.clear();
      }
    }
  }

  /// Retrying account setup reuses the authenticated session, never the password.
  Future<void> _completeAuthenticatedLogin(
    LoginResultModel loginResult,
    String submittedEmail,
    String? requestedTenantId,
  ) async {
    if (!isSingleMode) await EnterpriseService.instance.restore();
    await _resetUiForAuthenticatedSession();
    if (!isSingleMode && requestedTenantId != null) {
      try {
        await EnterpriseService.instance.switchTenant(requestedTenantId);
        await _resetUiForAuthenticatedSession();
      } on EnterpriseException catch (error) {
        if (error.status != 403) rethrow;
        final config = TenantConfiguration.fromJson(
          await EnterpriseService.instance.request(
            '/enterprise/tenants/${Uri.encodeComponent(requestedTenantId)}',
            authenticated: false,
          ),
        );
        Get.offAll(() => EnterpriseJoinScreen(gym: config.toGym()));
        return;
      }
    }

    // ── Connect Stream Chat in the background (non-blocking) ─────────────
    // We fire-and-forget so login navigation is instant; the chat screen
    // itself also calls initFromBackend() as a safety net.
    if (EnterpriseService.instance.active.value == null) {
      StreamChatService.instance.initFromBackend().ignore();
    }

    final loginEmail = submittedEmail;
    final role = _authService.getRole() ?? '';
    final tenantScope = loginResult.tenantScope;
    String? authorizedTenantId;
    if (isSingleMode) {
      final authorizedTenantIds = <String>{
        ...?tenantScope?.gymAdminTenantIds,
      };
      final memberTenantId = tenantScope?.tenantId;
      if (memberTenantId != null) authorizedTenantIds.add(memberTenantId);

      if (requestedTenantId != null &&
          !authorizedTenantIds.contains(requestedTenantId)) {
        EnterpriseGymModel? requestedGym;
        for (final gym in EnterpriseGymModel.activatedPartners) {
          if (gym.tenantId == requestedTenantId) requestedGym = gym;
        }
        if (requestedGym != null) {
          Get.offAll(() => EnterpriseJoinScreen(gym: requestedGym!));
          return;
        }
      }

      authorizedTenantId =
          requestedTenantId != null &&
              authorizedTenantIds.contains(requestedTenantId)
          ? requestedTenantId
          : memberTenantId ??
              (tenantScope?.gymAdminTenantIds.isNotEmpty ?? false
                  ? tenantScope!.gymAdminTenantIds.first
                  : null);
      if (authorizedTenantId != null) {
        await CacheService().put('tenantId', authorizedTenantId);
      }
    }
    if (EnterpriseService.instance.active.value != null || ['expired','revoked'].contains(EnterpriseService.instance.bootstrapData.value['entitlement']?['state'])) {
      Get.offAll(() => const EnterpriseSessionScreen());
      return;
    }

    if (isSingleMode &&
        (tenantScope?.gymAdminTenantIds.isNotEmpty ?? false)) {
      final adminTenantIds = tenantScope!.gymAdminTenantIds;
      final adminTenantId = requestedTenantId != null &&
              adminTenantIds.contains(requestedTenantId)
          ? requestedTenantId
          : adminTenantIds.first;
      await CacheService().put('tenantId', adminTenantId);
      Get.offAll(
        () => EnterpriseGymAdminDashboardScreen(tenantId: adminTenantId),
      );
      return;
    }
    if (!isSingleMode && (tenantScope?.gymAdminTenantIds.isNotEmpty ?? false)) {
      Get.offAll(() => EnterpriseMembershipScreen());
      return;
    }
    // Owner accounts must complete the official admin activation step.
    // The bypass screen sends the entered code to the authenticated backend;
    // never embed the owner PIN in the client or silently grant admin mode.
    if (AppConstants.ownerEmails.contains(loginEmail)) {
      Get.offAllNamed(AppRoute.adminBypassScreen);
      return;
    }
    // Other admins → AdminBypassScreen (enter code to unlock dashboard).
    if (role == 'admin') {
      Get.offAllNamed(AppRoute.adminBypassScreen);
      return;
    }

    Get.offAllNamed(
      AppRoute.bottonNavBar,
      parameters: <String, String>{
        'tenantSession': isSingleMode
            ? tenantScope?.tenantId ?? 'default'
            : 'default',
      },
    );
  }

  Future<void> _resetUiForAuthenticatedSession() async {
    // Enterprise branding is scoped to its disposable navigation boundary.
    // The root remains neutral after logout, denial, or a pending gym switch.
    final brand = isSingleMode ? TenantBrandService.to.activeBrand : null;
    Get.changeTheme(
      brand == null
          ? AppThemeData.themeData
          : AppThemeData.forBrand(
              primaryColor: brand.primaryColor,
              scaffoldBackground: brand.scaffoldBackground,
            ),
    );
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
    // Do not resolve BottomNavBarController here. It is lazy-registered, and
    // resolving it while the login route is active makes GetX associate it
    // with the route that Get.offAllNamed removes moments later. The new shell
    // then retains a controller that is disposed at the end of the transition.
    // A controller created by BottomNavBarMain starts at Home by default.
    try {
      if (Get.isRegistered<VideoPlaybackManager>()) {
        Get.find<VideoPlaybackManager>().stopAll();
      }
    } catch (_) {}
  }

  /// Returns true if a user is currently signed in.
  bool isLoggedIn() =>
      (CacheService().get<String>('accessToken')?.isNotEmpty ?? false) &&
      _authService.getRole() != null;

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

  bool isTrainer() => EnterpriseService.instance.active.value?.roles.contains('trainer') ?? (_authService.getRole() == 'trainer');

  Future<void> logout() async {
    final isAdminOriginatedPreview =
        Get.isRegistered<AdminModeService>() &&
        AdminModeService.to.isAdmin &&
        AdminModeService.to.viewAsUser &&
        Get.isRegistered<BottomNavBarController>();
    var hasBackendIssuedAdminToken = false;
    if (isAdminOriginatedPreview) {
      try {
        final prefs = await SharedPreferences.getInstance();
        hasBackendIssuedAdminToken =
            (prefs.getString(AppConstants.prefAdminToken)?.isNotEmpty ?? false);
      } catch (_) {}
    }
    if (isAdminOriginatedPreview && hasBackendIssuedAdminToken) {
      // Bug 1 — Logout redirect (Admin/Enterprise Demo):
      // "Logout" exits the authorized user preview without destroying the
      // underlying admin session, then returns to the Admin Dashboard.
      await AdminModeService.to.setViewAsUser(false);
      final adminTab = BottomNavBarController.to.indexOfTab(NavItemId.admin);
      if (adminTab >= 0) {
        BottomNavBarController.to.onChange(adminTab);
      }
      Get.offAllNamed(AppRoute.bottonNavBar);
      return;
    }

    EnterpriseService.instance.clear();
    try {
      if (Get.isRegistered<VideoPlaybackManager>()) {
        await Get.find<VideoPlaybackManager>().exitVideoModule();
      }
    } catch (_) {}
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
    Get.changeTheme(AppThemeData.themeData);
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
