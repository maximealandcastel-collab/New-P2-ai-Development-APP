import 'package:pler_to_pler_app/core/themes/p2p_design_tokens.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/services/tenant_brand_service.dart';
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

  /// How many tabs sit to the left of the centre FAB. Splitting the row in
  /// half keeps the FAB centred whether the role has 5 tabs or 6.
  int _fabPosition(int itemCount) => itemCount ~/ 2;

  Widget _buildNavTapTarget(
    BottomNavBarController controller,
    int index,
    NavItemModel navItem,
  ) {
    final isSelected = controller.selectedIndex == index;
    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: navItem.label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (!isSelected) {
              HapticFeedback.selectionClick();
              controller.onChange(index);
            }
          },
          child: SizedBox(
            height: 46.h,
            child: BottomNavItem(index: index, navItem: navItem),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = BottomNavBarController.to;
    final tenant = TenantBrandService.to;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        10.w,
        0,
        10.w,
        MediaQuery.of(context).padding.bottom + 5.h,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22.r),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.035), blurRadius: 12, offset: const Offset(0, 3))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.96),
                borderRadius: BorderRadius.circular(22.r),
                border: Border.all(color: P2PColors.border, width: .8),
              ),
              padding: EdgeInsets.symmetric(vertical: 4.h),
              // Built from navItems.length rather than fixed indices. The old
              // version hardcoded 0-4, which left the 6th tab with no tap target
              // at all — that is trainers' Messages tab and affiliates' Earnings
              // tab, both mounted in the stack but unreachable.
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        for (int i = 0;
                            i < _fabPosition(navItems.length);
                            i++)
                          _buildNavTapTarget(controller, i, navItems[i]),
                      ],
                    ),
                  ),
                  // Equal-width left and right groups keep this geometrically
                  // centered for both five-tab and six-tab role sets.
                  SizedBox(
                    width: 52.w,
                    height: 46.h,
                    child: Semantics(
                      button: true,
                      label: 'Create',
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () =>
                            NavFabWidget.show(context, controller.fabItems),
                        child: Center(
                          child: !P2PAccentPill.appliesToCurrentBrand
                                  ? Container(
                                      height: 42.h,
                                      width: 42.w,
                                      decoration: BoxDecoration(
                                        color: tenant.primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 26.sp,
                                      ),
                                    )
                                  : Container(
                                      height: 42.h,
                                      width: 42.w,
                                      decoration: P2PAccentPill.decoration(
                                        radius: 21.r,
                                        circular: true,
                                      ),
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 26.sp,
                                      ),
                                    ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        for (int i = _fabPosition(navItems.length);
                            i < navItems.length;
                            i++)
                          _buildNavTapTarget(controller, i, navItems[i]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
