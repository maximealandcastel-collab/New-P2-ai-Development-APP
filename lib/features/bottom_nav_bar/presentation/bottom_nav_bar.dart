import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/services/admin_mode_service.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/data/models/nav_item_model.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/widgets/bottom_nav_bar.dart';

/// BottomNavBarMain
///
/// ARCHITECTURE NOTE — why Offstage:
/// Both the admin stack and the user stack are ALWAYS mounted in the widget
/// tree. Offstage hides the inactive one without unmounting it. This means:
///   • AdminDashboardController.onInit() fires ONCE, never again on toggle.
///   • No API storm when the admin flips between Admin ↔ User mode.
///   • Each mode preserves its own tab position, scroll state, and loaded data.
///
/// ROLE-AWARE NAV:
/// ctrl.navItems resolves the correct tab set per role:
///   trainer  → trainerNavItems  (Home · Clients · Contents · Request · Messages)
///   subscriber → userNavItems   (Home · History · Contents · Trainer)
///   affiliate  → userNavItems + Earnings tab
///   admin      → adminNavItems  (trainer tabs + Admin analytics)
class BottomNavBarMain extends StatelessWidget {
  const BottomNavBarMain({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = BottomNavBarController.to;

    return Obx(() {
      final isAdmin = Get.isRegistered<AdminModeService>() &&
          AdminModeService.to.isAdmin;
      final viewUser = isAdmin && AdminModeService.to.viewAsUser;

      // Role-aware nav items: admin gets adminNavItems; everyone else gets
      // the items the controller resolves for their role (trainer / subscriber
      // / affiliate). This ensures trainers see the Messages tab automatically.
      final activeItems = (isAdmin && !viewUser)
          ? NavItemModel.adminNavItems
          : ctrl.navItems;

      return Stack(
        children: [
          // ── Main scaffold ───────────────────────────────────────────
          Scaffold(
            extendBody: true,
            backgroundColor: AppColors.backgroundLight,
            body: Stack(
              children: [
                // Admin stack — always mounted, invisible when user mode active
                Offstage(
                  offstage: !isAdmin || viewUser,
                  child: IndexedStack(
                    index: ctrl.adminIndex,
                    children:
                        NavItemModel.adminNavItems.map((e) => e.screen).toList(),
                  ),
                ),
                // User stack — role-aware: mounts trainer screens for trainers,
                // subscriber screens for subscribers, etc.
                Offstage(
                  offstage: isAdmin && !viewUser,
                  child: IndexedStack(
                    index: ctrl.userIndex,
                    children: ctrl.navItems.map((e) => e.screen).toList(),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: BottomNavBar(navItems: activeItems),
          ),
        ],
      );
    });
  }
}