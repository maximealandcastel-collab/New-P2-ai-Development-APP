import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks whether admin mode is active and which view (admin / user) to show.
///
/// ARCHITECTURE:
///   • authenticationState — handled by AuthService / AuthRepository
///   • accountRole         — set once at login (isAdmin stays true forever)
///   • activeDashboardMode — the ONLY thing that changes on toggle (viewAsUser)
///
/// Toggling between Admin ↔ User mode NEVER changes accountRole.
/// User UX is the default after login. Admin can switch to Admin view via pill.
class AdminModeService extends GetxController {
  static AdminModeService get to => Get.find();

  static const _kPrefKey = 'adminDashboardMode'; // 'admin' | 'user'

  final _isAdmin    = false.obs;
  // Default: User UX — admin sees what their customers see on first login.
  // The pill lets them switch to Admin view whenever they want.
  final _viewAsUser = true.obs;

  bool get isAdmin    => _isAdmin.value;
  bool get viewAsUser => _viewAsUser.value;
  RxBool get viewAsUserRx => _viewAsUser; // for ever() workers

  /// Called once when an admin account successfully authenticates.
  /// Restores the last dashboard mode the admin had selected.
  Future<void> activate() async {
    _isAdmin.value = true;

    // Restore the last selected mode, defaulting to User UX.
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_kPrefKey) ?? 'user';
      _viewAsUser.value = (saved != 'admin');
      if (kDebugMode) {
        debugPrint('[AdminMode] activated — mode: ${_viewAsUser.value ? "user" : "admin"}');
      }
    } catch (e) {
      _viewAsUser.value = true; // safe default
    }
  }

  /// Flip between admin view and user view.
  void toggleView() => setViewAsUser(!_viewAsUser.value);

  /// Set dashboard mode and persist it so the next cold launch restores it.
  Future<void> setViewAsUser(bool val) async {
    _viewAsUser.value = val;
    if (kDebugMode) {
      debugPrint('[AdminMode] setViewAsUser($val)');
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kPrefKey, val ? 'user' : 'admin');
    } catch (_) {}
  }

  /// Deactivate when logging out.
  Future<void> deactivate() async {
    _isAdmin.value    = false;
    _viewAsUser.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kPrefKey);
    } catch (_) {}
  }
}
