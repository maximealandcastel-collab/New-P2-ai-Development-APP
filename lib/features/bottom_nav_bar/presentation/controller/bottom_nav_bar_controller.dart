import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/services/admin_mode_service.dart';
import 'package:pler_to_pler_app/core/services/affiliate_mode_service.dart';
import 'package:pler_to_pler_app/core/services/video_playback_manager.dart';
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

  /// Position of a tab in the *currently active* nav set, or -1 if absent.
  ///
  /// This replaces a `static const contentsTabIndex = 2`, which was only ever
  /// correct for adminNavItems. In userNavItems and trainerNavItems index 2 is
  /// Gyms and Contents sits at 3, so every reel suspend/resume gate fired on
  /// exactly the wrong tab — audio started on Gyms and stopped on Contents.
  int indexOfTab(NavItemId id) => NavItemModel.indexOf(navItems, id);

  int get contentsTabIndex => indexOfTab(NavItemId.contents);
  int get clientsTabIndex => indexOfTab(NavItemId.clients);

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (Get.isRegistered<ContentController>()) {
          ContentController.to.reel.pauseActive();
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
    // Suspend/resume reel via its proper API — keeps isPlaying in sync,
      // kills audio AND the hallucinating pause button when leaving Contents tab
      try {
        if (Get.isRegistered<ContentController>()) {
          final cc = ContentController.to;
          if (index == contentsTabIndex) {
            cc.reel.resume(contents: cc.contents).catchError((_) {});
          } else {
            cc.reel.suspend().catchError((_) {});
          }
        }
      } catch (_) {}
      // The live Contents tab is contents_screen.dart, whose players are not
      // owned by ContentController. Because tabs live in an IndexedStack their
      // State is never disposed on a tab change, so leaving the tab has to stop
      // them explicitly or the audio follows the user onto the dashboard.
      try {
        if (index != contentsTabIndex &&
            Get.isRegistered<VideoPlaybackManager>()) {
          Get.find<VideoPlaybackManager>().exitVideoModule();
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
    final target = contentsTabIndex;
    if (target < 0) return;
    onChange(target);
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
