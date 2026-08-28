import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/data/models/nav_fab_model.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class NavFabWidget {
  static Future<void> show(BuildContext context, List<NavFabModel> items) {
    final bottomOffset = MediaQuery.paddingOf(context).bottom + 44.h;

    return showCupertinoDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(onTap: Get.back),
            ),
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: bottomOffset + 44.h,
              child: Column(
                spacing: 6.h,
                mainAxisSize: MainAxisSize.min,
                children: items.map(_buildMenuItem).toList(),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: bottomOffset - 24.h,
              child: Center(
                child: GestureDetector(
                  onTap: Get.back,
                  child: CustomContainer(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    paddingAll: 11.r,
                    child: const Icon(Icons.clear, color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildMenuItem(NavFabModel item) {
    return CustomContainer(
      width: 245.w,
      color: Colors.white,
      radiusAll: 12.r,
      paddingAll: 10.r,
      onTap: () {
        Get.back();
        item.onTap();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(item.icon, width: 24.w, height: 24.h),
          Flexible(
            child: CustomText(
              left: 4.w,
              fontSize: 16.sp,
              fontWeight: AppFontWeight.label,
              text: item.label,
            ),
          ),
        ],
      ),
    );
  }
}
