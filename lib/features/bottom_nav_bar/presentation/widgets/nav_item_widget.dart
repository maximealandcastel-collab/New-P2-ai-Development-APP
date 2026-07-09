import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/data/models/nav_item_model.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';

class BottomNavItem extends StatefulWidget {
  final NavItemModel navItem;
  final int index;

  const BottomNavItem({
    super.key,
    required this.navItem,
    required this.index,
  });

  @override
  State<BottomNavItem> createState() => _BottomNavItemState();
}

class _BottomNavItemState extends State<BottomNavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  bool _wasSelected = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.85,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.85,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = BottomNavBarController.to;
      final isSelected = controller.selectedIndex == widget.index;

      if (isSelected && !_wasSelected) {
        _controller.forward(from: 0);
      }
      _wasSelected = isSelected;

      final Color selectedColor =
          widget.index == 2 ? AppColors.textWhite : AppColors.textPrimary;
      final Color iconColor =
          isSelected ? selectedColor : AppColors.textSecondary;

      return IgnorePointer(
        child: ScaleTransition(
          scale: _scale,
          child: SizedBox(
            width: 56.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<Color?>(
                  tween: ColorTween(end: iconColor),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  builder: (context, color, child) {
                    return SvgPicture.asset(
                      widget.navItem.icon,
                      width: 24.w,
                      height: 24.h,
                      colorFilter: ColorFilter.mode(
                        color ?? iconColor,
                        BlendMode.srcIn,
                      ),
                    );
                  },
                ),
                SizedBox(height: 3.h),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  style: TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 11.sp,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? selectedColor
                        : AppColors.textSecondary,
                  ),
                  child: Text(widget.navItem.label),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
