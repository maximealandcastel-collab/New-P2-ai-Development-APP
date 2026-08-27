import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/services/admin_mode_service.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/widgets/bottom_nav_bar.dart';

/// BottomNavBarMain
///
/// ARCHITECTURE NOTE — one stack, not two:
/// This used to mount an admin stack and a user stack side by side, hiding the
/// inactive one with Offstage, so that toggling Admin ↔ User preserved state.
/// That had three defects, because Offstage and IndexedStack both *build* all
/// their children and only skip painting:
///   • In admin mode ctrl.navItems also returns adminNavItems, so the same five
///     screens were mounted twice at once — two ContentsScreen feeds, two sets
///     of video players, doubled network traffic.
///   • Every plain subscriber mounted AdminDashboardScreen, whose onInit fires
///     admin API calls. There is no isAdmin gate inside that screen.
///   • The user stack's child list swapped identity on each toggle anyway, so
///     the state preservation it was built for did not actually hold.
///
/// A single IndexedStack over the active set mounts each screen exactly once.
/// Per-mode tab position is still preserved — the controller keeps separate
/// _adminIndex and _userIndex values.
///
/// ROLE-AWARE NAV:
/// ctrl.navItems resolves the correct tab set per role:
///   trainer    → trainerNavItems (Home · Clients · Gyms · Contents · Request · Messages)
///   subscriber → userNavItems    (Home · History · Gyms · Contents · Trainer)
///   affiliate  → userNavItems + Earnings tab
///   admin      → adminNavItems   (trainer tabs + Admin analytics)
class BottomNavBarMain extends StatelessWidget {
  const BottomNavBarMain({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = BottomNavBarController.to;

    return Obx(() {
      final isAdmin = Get.isRegistered<AdminModeService>() &&
          AdminModeService.to.isAdmin;
      final adminMode = isAdmin && !AdminModeService.to.viewAsUser;

      final activeItems = ctrl.navItems;
      final rawIndex = adminMode ? ctrl.adminIndex : ctrl.userIndex;
      // Nav sets differ in length, so a preserved index from the other mode can
      // fall outside this one. IndexedStack throws on an out-of-range index.
      final activeIndex = rawIndex.clamp(0, activeItems.length - 1);

      return Scaffold(
        key: const ValueKey('bottomNavMainScaffold'),
        extendBody: true,
        backgroundColor: AppColors.backgroundLight,
        body: IndexedStack(
          key: ValueKey(adminMode ? 'adminStack' : 'userStack'),
          index: activeIndex,
          children: activeItems.map((e) => e.screen).toList(),
        ),
        bottomNavigationBar: BottomNavBar(navItems: activeItems),
      );
    });
  }
}