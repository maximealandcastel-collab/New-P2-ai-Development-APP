import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/services/tenant_brand_service.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/data/models/nav_fab_model.dart';

class NavFabWidget {
  static Future<void> show(BuildContext context, List<NavFabModel> items) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final closeBottom = safeBottom + 92.h;
    final menuBottom = closeBottom + 48.h + 32.h;

    return showCupertinoDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.58),
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(onTap: Get.back),
            ),
            Positioned(
              left: 24.w,
              right: 24.w,
              bottom: menuBottom,
              child: Column(
                spacing: 10.h,
                mainAxisSize: MainAxisSize.min,
                children: items.map(_buildMenuItem).toList(),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: closeBottom,
              child: Center(
                child: Material(
                  color: TenantBrandService.to.isWhiteLabeled
                      ? TenantBrandService.to.primaryColor
                      : Colors.white,
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: Get.back,
                    tooltip: 'Close actions',
                    constraints: BoxConstraints(minWidth: 48.r, minHeight: 48.r),
                    icon: Icon(
                      Icons.close_rounded,
                      size: 22.sp,
                      color: TenantBrandService.to.isWhiteLabeled
                          ? Colors.white
                          : const Color(0xFF24252A),
                    ),
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
    final tenant = TenantBrandService.to;
    final foreground = tenant.isWhiteLabeled
        ? Colors.white
        : const Color(0xFF24252A);
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 260.w),
      child: Material(
        color: tenant.isWhiteLabeled ? tenant.primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(17.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(17.r),
          onTap: () {
            Get.back();
            item.onTap();
          },
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: 52.h),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17.r),
              border: tenant.isWhiteLabeled
                  ? null
                  : Border.all(color: const Color(0xFFECECEF)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32.r,
                  height: 32.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tenant.isWhiteLabeled
                        ? Colors.white.withValues(alpha: 0.16)
                        : const Color(0xFFFFF1E9),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    item.icon,
                    width: 17.r,
                    height: 17.r,
                    colorFilter: ColorFilter.mode(
                      tenant.isWhiteLabeled
                          ? Colors.white
                          : const Color(0xFFF47724),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                SizedBox(width: 11.w),
                Expanded(
                  child: Text(
                    item.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      height: 1.2,
                      fontWeight: AppFontWeight.body,
                      color: foreground,
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 19.r,
                  color: tenant.isWhiteLabeled
                      ? Colors.white.withValues(alpha: 0.8)
                      : const Color(0xFF848993),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
