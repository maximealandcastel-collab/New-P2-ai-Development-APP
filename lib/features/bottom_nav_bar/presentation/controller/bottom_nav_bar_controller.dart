import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/services/admin_mode_service.dart';
import 'package:pler_to_pler_app/core/services/affiliate_mode_service.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/data/models/nav_fab_model.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/data/models/nav_item_model.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/content_details_controller.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/content_controller.dart';

class BottomNavBarController extends GetxController {
  static BottomNavBarController get to => Get.find();

  // ── Per-mode tab indices (preserved across mode switches) ─────────────────
  final RxInt _adminIndex = 0.obs;
  final RxInt _userIndex  = 0.obs;

  // Unified signal — fires for both admin and user tab changes
  final RxInt _tabChangedSignal = 0.obs;
  RxInt get tabChangedSignal => _tabChangedSignal;

  int get adminIndex => _adminIndex.value;
  int get userIndex  => _userIndex.value;

  int get selectedIndex {
    final isAdmin = Get.isRegistered<AdminModeService>() &&
        AdminModeService.to.isAdmin;
    final viewUser = isAdmin && AdminModeService.to.viewAsUser;
    return (isAdmin && !viewUser) ? _adminIndex.value : _userIndex.value;
  }

  RxInt get selectedIndexRx =>
      _isAdminMode() ? _adminIndex : _userIndex;

  // ── Nav items ─────────────────────────────────────────────────────────────
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

  /// FAB items are role-aware AND mode-aware.
  /// When owner is in viewAsUser mode, always show user FAB — never trainer.
  /// This is a hardcoded gate so trainer actions never leak to the user view.
  List<NavFabModel> get fabItems {
    final isAdmin = Get.isRegistered<AdminModeService>() &&
        AdminModeService.to.isAdmin;
    // Owner in User-mode preview → subscriber FAB only
    if (isAdmin && AdminModeService.to.viewAsUser) {
      return NavFabModel.userFabItems;
    }
    // Regular role check for non-admin sessions
    return LoginController.to.isTrainer()
        ? NavFabModel.trainerFabItems
        : NavFabModel.userFabItems;
  }

  static const int contentsTabIndex = 2;

    @override
    void onInit() {
      super.onInit();
      // Ensure reel is silent at startup — the Contents tab is Offstage on launch
      // so audio would bleed to the home screen without this guard.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          if (Get.isRegistered<ContentController>()) {
            ContentController.to.reel.pauseAll();
          }
        } catch (_) {}
      });
    }

  // ── Tab selection ─────────────────────────────────────────────────────────
  void onChange(int index) {
    // Pause full-screen detail player
    try {
      if (Get.isRegistered<ContentDetailsController>()) {
        ContentDetailsController.to.pauseVideo();
      }
    } catch (_) {}
    // Pause feed reel — stops audio when user leaves the Contents tab
    try {
      if (Get.isRegistered<ContentController>()) {
        ContentController.to.reel.pauseAll();
      }
    } catch (_) {}

    if (_isAdminMode()) {
      _adminIndex.value = index;
    } else {
      _userIndex.value = index;
    }
    _tabChangedSignal.value = index;
  }

  void goToContentsTab() {
    if (_isAdminMode()) {
      _adminIndex.value = contentsTabIndex;
    } else {
      _userIndex.value = contentsTabIndex;
    }
  }

  void switchToAdmin() {
    if (kDebugMode) debugPrint('[ADMIN] Dashboard state restored (tab $_adminIndex)');
  }

  void switchToUser() {
    if (kDebugMode) debugPrint('[USER] User state restored (tab $_userIndex)');
  }

  void resetIndex() {
    _adminIndex.value = 0;
    _userIndex.value  = 0;
  }

  bool _isAdminMode() {
    final isAdmin = Get.isRegistered<AdminModeService>() &&
        AdminModeService.to.isAdmin;
    final viewUser = isAdmin && AdminModeService.to.viewAsUser;
    return isAdmin && !viewUser;
  }
}
