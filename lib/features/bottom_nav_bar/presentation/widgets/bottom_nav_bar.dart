import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/data/models/nav_item_model.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/widgets/nav_fab_widget.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/widgets/nav_item_widget.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';

class BottomNavBar extends StatelessWidget {
  final List<NavItemModel> navItems;

  const BottomNavBar({super.key, required this.navItems});

  @override
  Widget build(BuildContext context) {
    final controller = BottomNavBarController.to;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        12.w,
        0,
        12.w,
        MediaQuery.of(context).padding.bottom + 8.h,
      ),
      child: LiquidGlassLayer(
        settings: LiquidGlassSettings(
          blur: 3,
          glassColor: Colors.black.withValues(alpha: 0.06),
        ),
        child: LiquidGlass(
          shape: LiquidRoundedSuperellipse(borderRadius: 16.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                BottomNavItem(index: 0, navItem: navItems[0]),
                BottomNavItem(index: 1, navItem: navItems[1]),

                // Centre FAB
                GestureDetector(
                  onTap: () => NavFabWidget.show(context, controller.fabItems),
                  child: Assets.icons.addButton.svg(height: 48.h, width: 48.w),
                ),

                BottomNavItem(index: 2, navItem: navItems[2]),
                BottomNavItem(index: 3, navItem: navItems[3]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
