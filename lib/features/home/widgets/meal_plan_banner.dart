import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/themes/brand_colors.dart';
import 'package:pler_to_pler_app/core/utils/constants/image_path.dart';

/// Companion meal-plan card on the user home screen. The nutrition/meal-plan
/// feature itself isn't built yet, so tapping surfaces a coming-soon message.
class MealPlanBanner extends StatelessWidget {
  final EdgeInsetsGeometry? margin;

  const MealPlanBanner({super.key, this.margin});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Meal Plan. Coming soon.',
      hint: 'Personalized nutrition plans',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Get.snackbar(
          'Coming Soon',
          'Personalized meal plans are on the way.',
          snackPosition: SnackPosition.BOTTOM,
        ),
        child: Container(
          margin: margin ?? EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16.r),
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
            child: SizedBox(
              height: 132.h,
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
    return Container(
      color: const Color(0xFF101010),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.restaurant_outlined,
            color: BrandColors.of(context).primary,
            size: 22,
          ),
          const SizedBox(width: 10),
          const Text(
            'Meal Plan  ·  COMING SOON',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
