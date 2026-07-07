import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/data/models/nav_item_model.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class BottomNavItem extends StatelessWidget {
  final NavItemModel navItem;
  final int index;

  const BottomNavItem({
    super.key,
    required this.navItem,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = BottomNavBarController.to;
      final isSelected = controller.selectedIndex == index;

      final Color selectedColor =
      index == 2 ? AppColors.textWhite : AppColors.textPrimary;
      return GestureDetector(
        onTap: () => controller.onChange(index),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 56.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                navItem.icon,
                width: 24.w,
                height: 24.h,
                colorFilter: ColorFilter.mode(
                  isSelected ? selectedColor : AppColors.textSecondary,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(height: 3.h),
              CustomText(
                text: navItem.label,
                fontSize: 11.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? selectedColor : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      );
    });
  }
}