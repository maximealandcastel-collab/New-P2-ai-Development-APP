import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks whether admin mode is active and which view (admin / user) to show.
///
/// ARCHITECTURE:
///   • authenticationState — handled by AuthService / AuthRepository
///   • accountRole         — set once at login (isAdmin stays true forever)
///   • activeDashboardMode — the ONLY thing that changes on toggle (viewAsUser)
///
/// GLOBAL PILL:
///   activate() inserts an OverlayEntry above the Navigator so the Admin|User
///   toggle pill is visible 24/7 on every screen (push routes, modals, sheets).
///   deactivate() removes it.
class AdminModeService extends GetxController {
  static AdminModeService get to => Get.find();

  /// Global reactive flag — Obx anywhere can observe this without importing
  /// the full service. Stays false until activate() is called.
  static final RxBool isAdminActive = false.obs;

  static const _kPrefKey = 'adminDashboardMode'; // 'admin' | 'user'

  final _isAdmin    = false.obs;
  // Default: User UX — admin sees what their customers see on first login.
  final _viewAsUser = true.obs;

  OverlayEntry? _pillEntry;

  bool get isAdmin    => _isAdmin.value;
  bool get viewAsUser => _viewAsUser.value;
  RxBool get viewAsUserRx => _viewAsUser;

  /// Called once when an admin account successfully authenticates.
  Future<void> activate() async {
    _isAdmin.value    = true;
    isAdminActive.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_kPrefKey) ?? 'user';
      _viewAsUser.value = (saved != 'admin');
      if (kDebugMode) {
        debugPrint('[AdminMode] activated — mode: ${_viewAsUser.value ? "user" : "admin"}');
      }
    } catch (e) {
      _viewAsUser.value = true;
    }

    // Insert global toggle pill after the frame so the overlay is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) => _insertPillOverlay());
  }

  void toggleView() => setViewAsUser(!_viewAsUser.value);

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

  Future<void> deactivate() async {
    _isAdmin.value      = false;
    _viewAsUser.value   = true;
    isAdminActive.value = false;
    _removePillOverlay();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kPrefKey);
    } catch (_) {}
  }

  @override
  void onClose() {
    _removePillOverlay();
    super.onClose();
  }

  // ── Overlay management ────────────────────────────────────────────────────

  void _insertPillOverlay() {
    _removePillOverlay();

    final overlayCtx = Get.overlayContext;
    if (overlayCtx == null) {
      // Navigator overlay not ready yet — defer to the next frame and retry.
      // This happens when activate() is called during login before the widget
      // tree is fully mounted.
      WidgetsBinding.instance.addPostFrameCallback((_) => _insertPillOverlay());
      return;
    }

    _pillEntry = OverlayEntry(builder: _buildPill);
    Overlay.of(overlayCtx).insert(_pillEntry!);
  }

  void _removePillOverlay() {
    _pillEntry?.remove();
    _pillEntry = null;
  }

  Widget _buildPill(BuildContext context) {
    final topPad = MediaQuery.maybeOf(context)?.padding.top ?? 44.0;
    return Obx(() {
      final viewUser = _viewAsUser.value;
      return Positioned(
        top: topPad + 6,
        left: 0,
        right: 0,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {}, // absorb taps on the gap between buttons
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Toggle buttons ───────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _pillButton('Admin',
                            active: !viewUser,
                            onTap: viewUser ? () => setViewAsUser(false) : null),
                        _pillButton('User',
                            active: viewUser,
                            onTap:
                                !viewUser ? () => setViewAsUser(true) : null),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  // ── Animated detail label — shows which view is active ─
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.4),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        )),
                        child: child,
                      ),
                    ),
                    child: Container(
                      key: ValueKey(viewUser),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.58),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.10)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            viewUser
                                ? Icons.person_rounded
                                : Icons.admin_panel_settings_rounded,
                            color: viewUser
                                ? const Color(0xFFFF6B1A)
                                : Colors.white70,
                            size: 12,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            viewUser ? 'Viewing as User' : 'Trainer Dashboard',
                            style: TextStyle(
                              color: viewUser
                                  ? const Color(0xFFFF6B1A)
                                  : Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _pillButton(String label, {required bool active, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFF6B1A) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.white38,
            fontSize: 13,
            fontWeight: active ? FontWeight.w800 : FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
