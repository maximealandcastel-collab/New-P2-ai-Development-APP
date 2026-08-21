import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/data/models/nav_item_model.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/widgets/nav_fab_widget.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/widgets/nav_item_widget.dart';

/// BottomNavBar
///
/// Uses BackdropFilter (frosted glass) instead of liquid_glass_renderer.
/// liquid_glass_renderer's LiquidGlass layer consumed all pointer events,
/// making every tab tap a no-op. BackdropFilter is transparent to touches.
class BottomNavBar extends StatelessWidget {
  final List<NavItemModel> navItems;

  const BottomNavBar({super.key, required this.navItems});

  Widget _buildNavTapTarget(
    BottomNavBarController controller,
    int index,
    NavItemModel navItem,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (controller.selectedIndex != index) {
          HapticFeedback.selectionClick();
          controller.onChange(index);
        }
      },
      child: BottomNavItem(index: index, navItem: navItem),
    );
  }

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              // Smooth frosted-glass white — matches the photo 2 UX direction
              color: Colors.white.withOpacity(0.78),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavTapTarget(controller, 0, navItems[0]),
                _buildNavTapTarget(controller, 1, navItems[1]),
                // Centre FAB
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => NavFabWidget.show(context, controller.fabItems),
                  child: Assets.icons.addButton.svg(height: 48.h, width: 48.w),
                ),
                _buildNavTapTarget(controller, 2, navItems[2]),
                _buildNavTapTarget(controller, 3, navItems[3]),
                if (navItems.length > 4)
                  _buildNavTapTarget(controller, 4, navItems[4]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
