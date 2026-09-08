import 'package:pler_to_pler_app/core/themes/brand_colors.dart';
import 'package:pler_to_pler_app/core/themes/app_typography.dart';
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
  ///
  /// The SharedPreferences read happens BEFORE any Rx field is touched, and
  /// _isAdmin/_viewAsUser/isAdminActive are then set together, synchronously.
  /// Setting _isAdmin.value here and _viewAsUser.value later (after an
  /// `await`) fires two separate Obx rebuilds of BottomNavBarMain's Scaffold
  /// in quick succession -- the second rebuild lands while Scaffold's
  /// internal LayoutBuilder-deferred body attachment from the first rebuild
  /// hasn't finished, leaving one _ScaffoldSlot.body element stuck mid-layout
  /// and a second, empty one in its place (the app's body renders blank).
  Future<void> activate() async {
    bool viewAsUser = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_kPrefKey) ?? 'user';
      viewAsUser = saved != 'admin';
    } catch (_) {
      viewAsUser = true;
    }

    _isAdmin.value       = true;
    isAdminActive.value  = true;
    _viewAsUser.value    = viewAsUser;
    if (kDebugMode) {
      debugPrint('[AdminMode] activated — mode: ${viewAsUser ? "user" : "admin"}');
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

    // Get.overlayContext walks the current Overlay's child elements and
    // hands back whichever context it finds -- right after Get.offAll()
    // replaces the route, that context can be a just-deactivated element
    // from the old screen, and Overlay.of(context) throws "No Overlay
    // widget found" even though a live Overlay clearly still exists.
    // Get.key.currentState?.overlay is the root OverlayState itself
    // (GetMaterialApp's own Navigator), which stays valid across route
    // changes -- inserting into it directly avoids the stale-context hop.
    final overlayState = Get.key.currentState?.overlay;
    if (overlayState == null) {
      // Root navigator/overlay not ready yet — defer to the next frame and
      // retry. This happens when activate() is called during login before
      // the widget tree is fully mounted.
      WidgetsBinding.instance.addPostFrameCallback((_) => _insertPillOverlay());
      return;
    }

    _pillEntry = OverlayEntry(builder: _buildPill);
    overlayState.insert(_pillEntry!);
  }

  void _removePillOverlay() {
    _pillEntry?.remove();
    _pillEntry = null;
  }

  Widget _buildPill(BuildContext context) {
    // Deliberately NOT MediaQuery.maybeOf(context) or View.of(context):
    // both register this Element as a dependent of an ambient InheritedWidget
    // (_MediaQueryFromView / _ViewScope). This OverlayEntry is inserted into
    // the app-root Overlay and can outlive the route that was active when it
    // was built -- if that InheritedWidget is ever torn down (e.g. during a
    // route-stack replacement) while this Element is still a registered
    // dependent, InheritedElement.unmount() hits
    // `assert(_dependents.isEmpty)` and crashes. Reading padding straight off
    // PlatformDispatcher avoids BuildContext/InheritedWidget entirely, so
    // this Element never depends on anything above it.
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final topPad = view.padding.top / view.devicePixelRatio;
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
                        _pillButton(context, 'Admin',
                            active: !viewUser,
                            onTap: viewUser ? () => setViewAsUser(false) : null),
                        _pillButton(context, 'User',
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
                                ? BrandColors.of(context).primary
                                : Colors.white70,
                            size: 12,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            viewUser ? 'Viewing as User' : 'Trainer Dashboard',
                            style: TextStyle(
                              color: viewUser
                                  ? BrandColors.of(context).primary
                                  : Colors.white70,
                              fontSize: 11,
                              fontWeight: AppFontWeight.label,
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

  Widget _pillButton(BuildContext context, String label, {required bool active, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        decoration: BoxDecoration(
          color: active ? BrandColors.of(context).primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.white38,
            fontSize: 13,
            fontWeight: active ? AppFontWeight.display : AppFontWeight.emphasis,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
