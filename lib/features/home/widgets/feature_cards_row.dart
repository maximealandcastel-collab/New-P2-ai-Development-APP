import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/user/meal_plan/presentation/meal_plan_screen.dart';
import 'package:pler_to_pler_app/features/user/rate_my_peel/presentation/rate_my_peel_screen.dart';

/// The two primary feature cards shown on the subscriber home screen.
///
/// This is the Flutter implementation of the supplied FeatureCards JSX. The
/// cards use an explicit height so the Row always receives a bounded vertical
/// constraint and cannot collapse or become visually insignificant.
class FeatureCardsRow extends StatelessWidget {
  const FeatureCardsRow({super.key});

  static const _mealPlanAsset = 'assets/images/meal_plan_banner.jpg';
  static const _rateMyPeelAsset = 'assets/images/rate_my_peel_banner.jpg';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: SizedBox(
        height: 220.h,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _FeatureCard(
                assetPath: _mealPlanAsset,
                semanticLabel: 'Meal Plan',
                onTap: () => Get.to(() => const MealPlanScreen()),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _FeatureCard(
                assetPath: _rateMyPeelAsset,
                semanticLabel: 'Rate My Peel',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const RateMyPeelScreen(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.assetPath,
    required this.semanticLabel,
    required this.onTap,
  });

  final String assetPath;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16.r);

    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: const Color(0xFF090909),
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Ink.image(
            image: AssetImage(assetPath),
            fit: BoxFit.cover,
            alignment: Alignment.center,
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}
