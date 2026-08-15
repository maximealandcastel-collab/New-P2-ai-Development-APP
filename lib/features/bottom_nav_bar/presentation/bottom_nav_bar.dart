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
class BottomNavBarMain extends StatelessWidget {
  const BottomNavBarMain({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = BottomNavBarController.to;

    return Obx(() {
      final isAdmin = Get.isRegistered<AdminModeService>() &&
          AdminModeService.to.isAdmin;
      final viewUser = isAdmin && AdminModeService.to.viewAsUser;

      // Active nav items for the bottom bar UI only — not for IndexedStack
      final activeItems = (isAdmin && !viewUser)
          ? NavItemModel.adminNavItems
          : NavItemModel.userNavItems;

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
                // User stack — always mounted, invisible when admin mode active
                Offstage(
                  offstage: isAdmin && !viewUser,
                  child: IndexedStack(
                    index: ctrl.userIndex,
                    children:
                        NavItemModel.userNavItems.map((e) => e.screen).toList(),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: BottomNavBar(navItems: activeItems),
          ),

          // ── Admin | User segmented toggle pill ──────────────────────
          if (isAdmin)
            Positioned(
              top: MediaQuery.of(context).padding.top + 6,
              left: 0,
              right: 0,
              child: Center(
                // Opaque wrapper: absorbs ALL touches inside the pill bounding
                // box so gaps between the two side buttons never pass through.
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.all(3.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.40),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Admin side ──────────────────────────────────
                        GestureDetector(
                          onTap: viewUser
                              ? () {
                                  if (kDebugMode) {
                                    debugPrint('[MODE] Admin selected');
                                  }
                                  AdminModeService.to.setViewAsUser(false);
                                  ctrl.switchToAdmin();
                                }
                              : () {}, // already on Admin — absorb tap
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            padding: EdgeInsets.symmetric(
                                horizontal: 18.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: viewUser
                                  ? Colors.transparent
                                  : const Color(0xFFFF6B1A),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              'Admin',
                              style: TextStyle(
                                color:
                                    viewUser ? Colors.white38 : Colors.white,
                                fontSize: 12.sp,
                                fontWeight: viewUser
                                    ? FontWeight.w500
                                    : FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                        // ── User side ───────────────────────────────────
                        GestureDetector(
                          onTap: !viewUser
                              ? () {
                                  if (kDebugMode) {
                                    debugPrint('[MODE] User selected');
                                  }
                                  AdminModeService.to.setViewAsUser(true);
                                  ctrl.switchToUser();
                                }
                              : () {}, // already on User — absorb tap
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            padding: EdgeInsets.symmetric(
                                horizontal: 18.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: viewUser
                                  ? const Color(0xFFFF6B1A)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              'User',
                              style: TextStyle(
                                color:
                                    viewUser ? Colors.white : Colors.white38,
                                fontSize: 12.sp,
                                fontWeight: viewUser
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}
