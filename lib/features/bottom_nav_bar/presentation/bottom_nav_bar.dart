import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

      // The nav bar is stacked over the body rather than passed to
      // Scaffold.bottomNavigationBar, and extendBody is left false.
      //
      // extendBody: true is the ONLY thing that routes Scaffold.body through
      // _BodyBuilder, which defers building the body to the LAYOUT phase via a
      // LayoutBuilder (see scaffold.dart, _BodyBuilder.build). Once admin mode
      // is active that deferred rebuild stops re-running, so the body kept
      // painting a stale subtree — it still showed TrainerHomeScreen while the
      // nav bar had already moved to another tab. bottomNavigationBar never had
      // the problem because it bypasses _BodyBuilder entirely, which is exactly
      // why only the body went stale.
      //
      // Stacking the bar reproduces the floating-over-content look that
      // extendBody gave us, without the LayoutBuilder indirection. The extra
      // bottom padding is what extendBody used to contribute, so scrollable
      // screens still clear the bar.
      final media = MediaQuery.of(context);
      final navBarHeight = 66.h + media.padding.bottom;

      // The Admin/User pill is an OverlayEntry pinned at top + 6 in the ROOT
      // overlay (see AdminModeService._buildPill), so it paints over whatever
      // the active tab happens to put there. In practice it covered the
      // dashboard greeting and sat directly on the Clients/Balance tab bar,
      // half-hiding the "Clients" label.
      //
      // Same treatment as the nav bar below: hand the body a MediaQuery whose
      // top padding already accounts for the pill, so every SafeArea inside a
      // tab starts below it instead of behind it. Only applied while the pill
      // is actually on screen, which is whenever admin mode is active — note
      // that is isAdmin, not adminMode: the pill shows in both Admin and User
      // views, it is how you switch between them.
      //
      // 82 = the pill's own height (toggle row ~40 + gap + the mode label ~24)
      // plus its 6px offset, rounded up.
      final pillInset = isAdmin ? 82.h : 0.0;

      return Scaffold(
        key: const ValueKey('bottomNavMainScaffold'),
        backgroundColor: AppColors.backgroundLight,
        body: Stack(
          children: [
            Positioned.fill(
              child: MediaQuery(
                data: media.copyWith(
                  padding: media.padding.copyWith(
                    top: media.padding.top + pillInset,
                    bottom: navBarHeight,
                  ),
                ),
                child: IndexedStack(
                  index: activeIndex,
                  children: activeItems.map((e) => e.screen).toList(),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomNavBar(navItems: activeItems),
            ),
          ],
        ),
      );
    });
  }
}