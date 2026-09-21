import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/user/meal_plan/presentation/meal_plan_screen.dart';
import 'package:pler_to_pler_app/features/user/rate_my_peel/presentation/rate_my_peel_screen.dart';

/// Compact companion cards for the subscriber dashboard.
///
/// Both source banners share the same wide aspect ratio. Keeping that ratio
/// here prevents the artwork and typography from looking stretched or muddy,
/// while a small dark inset keeps every label away from the rounded corners.
class FeatureCardsRow extends StatelessWidget {
  const FeatureCardsRow({super.key});

  static const _mealPlanAsset = 'assets/images/meal_plan_banner.jpg';
  static const _rateMyPeelAsset = 'assets/images/rate_my_peel_banner.jpg';
  static const _bannerAspectRatio = 582 / 373;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _FeatureCard(
              assetPath: _mealPlanAsset,
              semanticLabel: 'Meal Plan',
              onTap: () => Get.to(() => const MealPlanScreen()),
            ),
          ),
          SizedBox(width: 10.w),
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
    final outerRadius = BorderRadius.circular(16.r);
    final imageRadius = BorderRadius.circular(13.r);
    final accent = Theme.of(context).colorScheme.primary;

    return Semantics(
      button: true,
      label: semanticLabel,
      child: AspectRatio(
        aspectRatio: FeatureCardsRow._bannerAspectRatio,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF090909),
            borderRadius: outerRadius,
            border: Border.all(
              color: accent.withOpacity(0.20),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: outerRadius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              borderRadius: outerRadius,
              splashColor: Colors.white.withOpacity(0.08),
              highlightColor: Colors.white.withOpacity(0.04),
              child: Padding(
                padding: EdgeInsets.all(3.r),
                child: ClipRRect(
                  borderRadius: imageRadius,
                  child: Image.asset(
                    assetPath,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    filterQuality: FilterQuality.high,
                    gaplessPlayback: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
