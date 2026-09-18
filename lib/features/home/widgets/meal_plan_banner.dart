import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/themes/brand_colors.dart';
import 'package:pler_to_pler_app/core/utils/constants/image_path.dart';

/// Compact Meal Plan companion card for the existing user Home screen.
/// This widget intentionally changes only the Meal Plan surface.
class MealPlanBanner extends StatelessWidget {
  final EdgeInsetsGeometry? margin;

  const MealPlanBanner({super.key, this.margin});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Meal Plan. Coming soon.',
      hint: 'Personalized nutrition for your goals',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Get.snackbar(
          'Coming Soon',
          'Personalized meal plans are on the way.',
          snackPosition: SnackPosition.BOTTOM,
        ),
        child: Container(
          margin: margin ?? EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: const Color(0xFF090909),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: BrandColors.of(context).primary.withOpacity(0.45),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: AspectRatio(
              aspectRatio: 1.22,
              child: Image.asset(
                ImagePath.mealPlanBanner,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) =>
                    const _MealPlanAssetFallback(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MealPlanAssetFallback extends StatelessWidget {
  const _MealPlanAssetFallback();

  @override
  Widget build(BuildContext context) {
    final orange = BrandColors.of(context).primary;
    return Container(
      color: const Color(0xFF090909),
      padding: EdgeInsets.all(16.w),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: orange.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: orange.withOpacity(0.55)),
                  ),
                  child: Icon(
                    Icons.restaurant_rounded,
                    color: orange,
                    size: 27.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MEAL PLAN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Personalized nutrition\nfor your goals.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10.sp,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Icon(
              Icons.chevron_right_rounded,
              color: orange,
              size: 30.sp,
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: orange.withOpacity(0.8)),
              ),
              child: Text(
                'COMING SOON',
                style: TextStyle(
                  color: orange,
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
