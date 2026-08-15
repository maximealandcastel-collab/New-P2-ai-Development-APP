import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/services/admin_mode_service.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/widgets/bottom_nav_bar.dart';

class BottomNavBarMain extends StatelessWidget {
  const BottomNavBarMain({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = BottomNavBarController.to;
    return Obx(() {
      final items    = controller.navItems;
      final isAdmin  = Get.isRegistered<AdminModeService>() && AdminModeService.to.isAdmin;
      final viewUser = isAdmin && AdminModeService.to.viewAsUser;

      return Stack(
        children: [
          // ── Main scaffold ─────────────────────────────────────────
          Scaffold(
            extendBody: true,
            backgroundColor: AppColors.backgroundLight,
            body: IndexedStack(
              index: controller.selectedIndex,
              children: items.map((e) => e.screen).toList(),
            ),
            bottomNavigationBar: BottomNavBar(navItems: items),
          ),

          // ── Admin Trainer | User segmented toggle ────────────────────────
          if (isAdmin)
            Positioned(
              top: MediaQuery.of(context).padding.top + 6,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  // Opaque hit-test: eat ALL touches in the pill bounding box
                  // so gaps between buttons never pass through to the screen behind
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
                      // ── Trainer side ─────────────────────────────────────
                      GestureDetector(
                        onTap: viewUser
                            ? () {
                                AdminModeService.to.setViewAsUser(false);
                                BottomNavBarController.to.resetIndex();
                              }
                            : () {}, // already on Trainer side — absorb the tap
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
                            'Trainer',
                            style: TextStyle(
                              color: viewUser
                                  ? Colors.white38
                                  : Colors.white,
                              fontSize: 12.sp,
                              fontWeight: viewUser
                                  ? FontWeight.w500
                                  : FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                      // ── User side ────────────────────────────────────────
                      GestureDetector(
                        onTap: !viewUser
                            ? () {
                                AdminModeService.to.setViewAsUser(true);
                                BottomNavBarController.to.resetIndex();
                              }
                            : () {}, // already on User side — absorb the tap
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
                              color: viewUser
                                  ? Colors.white
                                  : Colors.white38,
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
                ), // close GestureDetector(opaque) wrapper
            ),
        ],
      );
    });
  }
}

