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

          // ── Admin toggle pill — always visible when admin is signed in ─────
          if (isAdmin)
            Positioned(
              top: MediaQuery.of(context).padding.top + 6,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    AdminModeService.to.setViewAsUser(!AdminModeService.to.viewAsUser);
                    BottomNavBarController.to.resetIndex();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                    decoration: BoxDecoration(
                      color: viewUser
                          ? const Color(0xFFFF6B1A)
                          : const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(20.r),
                      border: viewUser
                          ? null
                          : Border.all(
                              color: const Color(0xFFFF6B1A), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          viewUser
                              ? Icons.shield_rounded
                              : Icons.swap_horiz_rounded,
                          color: viewUser
                              ? Colors.white
                              : const Color(0xFFFF6B1A),
                          size: 13.sp,
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          viewUser ? 'Admin Preview' : 'Admin Mode',
                          style: TextStyle(
                            color: viewUser
                                ? Colors.white
                                : const Color(0xFFFF6B1A),
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          width: 1,
                          height: 12.h,
                          color: viewUser ? Colors.white38 : Colors.white24,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          viewUser ? 'Back to Admin' : 'Preview as User',
                          style: TextStyle(
                            color: viewUser ? Colors.white : Colors.white70,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(Icons.arrow_forward_ios_rounded,
                            color: viewUser ? Colors.white : Colors.white54,
                            size: 9.sp),
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
