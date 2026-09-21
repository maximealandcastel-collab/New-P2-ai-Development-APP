import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:pler_to_pler_app/features/user/meal_plan/presentation/meal_plan_screen.dart';
import 'package:pler_to_pler_app/features/user/rate_my_peel/presentation/rate_my_peel_screen.dart';

/// Native dashboard feature cards.
///
/// The supplied artwork is used only as supporting imagery on the right. All
/// visible labels and buttons are real Flutter controls, so these read and
/// behave like app cards instead of screenshots.
class FeatureCardsRow extends StatelessWidget {
  const FeatureCardsRow({super.key});

  static const _mealPlanAsset = 'assets/images/meal_plan_banner.jpg';
  static const _rateMyPeelAsset = 'assets/images/rate_my_peel_banner.jpg';

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
              eyebrow: 'FUEL PROGRESS',
              title: 'MEAL',
              accentTitle: 'PLAN',
              description: 'Nutrition for your goals.',
              actionLabel: 'View Plan',
              icon: Icons.restaurant_menu_rounded,
              imageAlignment: Alignment.centerRight,
              onTap: () => Get.to(() => const MealPlanScreen()),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _FeatureCard(
              assetPath: _rateMyPeelAsset,
              semanticLabel: 'Rate My Peel',
              eyebrow: 'TRACK TRANSFORM',
              title: 'RATE MY',
              accentTitle: 'PEEL',
              description: 'Visual body analysis.',
              actionLabel: 'Scan Now',
              icon: Icons.photo_camera_outlined,
              imageAlignment: Alignment.centerRight,
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
    required this.eyebrow,
    required this.title,
    required this.accentTitle,
    required this.description,
    required this.actionLabel,
    required this.icon,
    required this.imageAlignment,
    required this.onTap,
  });

  final String assetPath;
  final String semanticLabel;
  final String eyebrow;
  final String title;
  final String accentTitle;
  final String description;
  final String actionLabel;
  final IconData icon;
  final Alignment imageAlignment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final radius = BorderRadius.circular(16.r);

    return Semantics(
      button: true,
      label: '$semanticLabel. $description $actionLabel.',
      child: AspectRatio(
        aspectRatio: 1.24,
        child: Material(
          color: const Color(0xFF080808),
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            splashColor: Colors.white.withOpacity(0.08),
            highlightColor: Colors.white.withOpacity(0.04),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  bottom: 0,
                  width: 102.w,
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.cover,
                    alignment: imageAlignment,
                    filterQuality: FilterQuality.high,
                    gaplessPlayback: true,
                    excludeFromSemantics: true,
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFF080808),
                        Color(0xFF080808),
                        Color(0xF2080808),
                        Color(0x8A080808),
                        Color(0x08080808),
                      ],
                      stops: [0, 0.43, 0.58, 0.78, 1],
                    ),
                    border: Border.fromBorderSide(
                      BorderSide(color: Color(0x33FF6A00), width: 0.8),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10.w, 9.h, 8.w, 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 26.r,
                            height: 26.r,
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(8.r),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withOpacity(0.24),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(icon, color: Colors.white, size: 15.r),
                          ),
                          SizedBox(width: 7.w),
                          Expanded(
                            child: Text(
                              eyebrow,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.68),
                                fontSize: 7.5.sp,
                                height: 1.05,
                                fontWeight: AppFontWeight.label,
                                letterSpacing: 1.15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          height: 0.98,
                          fontWeight: AppFontWeight.display,
                          letterSpacing: -0.25,
                        ),
                      ),
                      Text(
                        accentTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: accent,
                          fontSize: 15.sp,
                          height: 1.02,
                          fontWeight: AppFontWeight.display,
                          letterSpacing: -0.25,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.72),
                          fontSize: 8.5.sp,
                          height: 1.15,
                          fontWeight: AppFontWeight.body,
                        ),
                      ),
                      const Spacer(),
                      _NativeActionPill(
                        label: actionLabel,
                        accent: accent,
                        onTap: onTap,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NativeActionPill extends StatelessWidget {
  const _NativeActionPill({
    required this.label,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.black.withOpacity(0.72),
        borderRadius: BorderRadius.circular(999.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999.r),
          child: Container(
            constraints: BoxConstraints(minWidth: 92.w),
            height: 27.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(color: accent.withOpacity(0.88), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9.5.sp,
                      height: 1,
                      fontWeight: AppFontWeight.label,
                    ),
                  ),
                ),
                SizedBox(width: 7.w),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: accent,
                  size: 14.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
