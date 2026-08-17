import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/services/admin_mode_service.dart';
import 'package:pler_to_pler_app/core/services/affiliate_mode_service.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/data/models/nav_fab_model.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/data/models/nav_item_model.dart';

class BottomNavBarController extends GetxController {
  static BottomNavBarController get to => Get.find();

  // ── Per-mode tab indices (preserved across mode switches) ─────────────────
  // Admin stack and user stack each remember which tab the user was on.
  // Switching Admin ↔ User restores where you were, not index 0 every time.
  final RxInt _adminIndex = 0.obs;
  final RxInt _userIndex  = 0.obs;

  // Unified signal — fires for both admin and user tab changes
  final RxInt _tabChangedSignal = 0.obs;
  RxInt get tabChangedSignal => _tabChangedSignal;

  int get adminIndex => _adminIndex.value;
  int get userIndex  => _userIndex.value;

  /// Legacy accessor — resolves to the active mode's current index.
  int get selectedIndex {
    final isAdmin = Get.isRegistered<AdminModeService>() &&
        AdminModeService.to.isAdmin;
    final viewUser = isAdmin && AdminModeService.to.viewAsUser;
    return (isAdmin && !viewUser) ? _adminIndex.value : _userIndex.value;
  }

  /// Legacy Rx accessor used by BottomNavBar widget.
  RxInt get selectedIndexRx =>
      _isAdminMode() ? _adminIndex : _userIndex;

  // ── Nav items (used by external callers, not by BottomNavBarMain) ─────────
  List<NavItemModel> get navItems {
    final isAdmin = Get.isRegistered<AdminModeService>() &&
        AdminModeService.to.isAdmin;
    final viewAsUser = isAdmin &&
        Get.isRegistered<AdminModeService>() &&
        AdminModeService.to.viewAsUser;
    final isAffiliate = Get.isRegistered<AffiliateModeService>() &&
        AffiliateModeService.to.isAffiliate;

    if (viewAsUser) return NavItemModel.userNavItems;
    if (isAdmin)    return NavItemModel.adminNavItems;
    if (isAffiliate) {
      return [...NavItemModel.userNavItems, NavItemModel.affiliateNavItem];
    }
    return LoginController.to.isTrainer()
        ? NavItemModel.trainerNavItems
        : NavItemModel.userNavItems;
  }

  List<NavFabModel> get fabItems =>
      LoginController.to.isTrainer()
          ? NavFabModel.trainerFabItems
          : NavFabModel.userFabItems;

  static const int contentsTabIndex = 2;

  // ── Tab selection ─────────────────────────────────────────────────────────
  void onChange(int index) {
    if (_isAdminMode()) {
      _adminIndex.value = index;
    } else {
      _userIndex.value = index;
    }
    _tabChangedSignal.value = index; // unified — ContentController suspend/resume
  }

  void goToContentsTab() {
    if (_isAdminMode()) {
      _adminIndex.value = contentsTabIndex;
    } else {
      _userIndex.value = contentsTabIndex;
    }
  }

  /// Restore admin tab position when switching to Admin mode.
  void switchToAdmin() {
    if (kDebugMode) debugPrint('[ADMIN] Dashboard state restored (tab $_adminIndex)');
    // Index is already saved in _adminIndex — nothing to do.
    // The Offstage flip in BottomNavBarMain makes admin stack visible.
  }

  /// Restore user tab position when switching to User mode.
  void switchToUser() {
    if (kDebugMode) debugPrint('[USER] User state restored (tab $_userIndex)');
    // Index is already saved in _userIndex — nothing to do.
  }

  /// Reset both stacks to tab 0 (used on logout / hard reset).
  void resetIndex() {
    _adminIndex.value = 0;
    _userIndex.value  = 0;
  }

  // ── Private helpers ───────────────────────────────────────────────────────
  bool _isAdminMode() {
    final isAdmin = Get.isRegistered<AdminModeService>() &&
        AdminModeService.to.isAdmin;
    final viewUser = isAdmin && AdminModeService.to.viewAsUser;
    return isAdmin && !viewUser;
  }
}
