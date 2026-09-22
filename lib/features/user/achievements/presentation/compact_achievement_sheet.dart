import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/features/user/achievements/data/achievement_service.dart';
import 'package:pler_to_pler_app/features/user/achievements/data/achievement_unlock.dart';
import 'package:share_plus/share_plus.dart';

class CompactAchievementPresenter {
  const CompactAchievementPresenter._();

  static Future<void> showQueue(
    BuildContext context,
    List<AchievementUnlock> achievements,
  ) async {
    for (final achievement in achievements) {
      if (!context.mounted) return;
      await HapticFeedback.mediumImpact();
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: 0.58),
        builder: (_) => _CompactAchievementSheet(achievement: achievement),
      );
      await AchievementService.markPresented(achievement.achievementId);
    }
  }
}

class _CompactAchievementSheet extends StatelessWidget {
  final AchievementUnlock achievement;

  const _CompactAchievementSheet({required this.achievement});

  static const _dark = Color(0xFF0A0B0E);

  List<Color> get _metallicColors => switch (achievement.tier) {
        'advanced_pro' => const [
            Color(0xFFFFE9B0),
            Color(0xFFF5B942),
            Color(0xFF8A5C1C),
          ],
        'pro' => const [
            Color(0xFFF4F6F9),
            Color(0xFFC7CDD6),
            Color(0xFF5F6570),
          ],
        _ => const [
            Color(0xFFF2C29A),
            Color(0xFFC97C4D),
            Color(0xFF6E4123),
          ],
      };

  Color get _accent => _metallicColors[1];

  Future<void> _share(BuildContext context) async {
    await HapticFeedback.lightImpact();
    await Share.share(achievement.shareCopy);
    await AchievementService.markShared(achievement.achievementId);
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 590.h),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _dark,
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: _accent.withValues(alpha: 0.18),
                blurRadius: 34,
                spreadRadius: 1,
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(22.w, 14.h, 22.w, 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  'NEW ACHIEVEMENT',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.56),
                    fontSize: 10.sp,
                    fontWeight: AppFontWeight.section,
                    letterSpacing: 1.6,
                  ),
                ),
                SizedBox(height: 12.h),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: reduceMotion ? 1 : 0.82, end: 1),
                  duration: reduceMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 520),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) =>
                      Transform.scale(scale: scale, child: child),
                  child: Semantics(
                    label: '${achievement.name} trophy',
                    image: true,
                    child: Container(
                      width: 78.w,
                      height: 78.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _accent.withValues(alpha: 0.08),
                        boxShadow: [
                          BoxShadow(
                            color: _accent.withValues(alpha: 0.22),
                            blurRadius: 26,
                          ),
                        ],
                      ),
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _metallicColors,
                        ).createShader(bounds),
                        child: Icon(
                          Icons.emoji_events_rounded,
                          color: Colors.white,
                          size: 50.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  achievement.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _accent,
                    fontSize: 13.sp,
                    fontWeight: AppFontWeight.title,
                    letterSpacing: 1.1,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  achievement.headline,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: AppFontWeight.section,
                    height: 1.08,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  achievement.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.70),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 14.h),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 7.w,
                  runSpacing: 7.h,
                  children: [
                    _AchievementChip(label: '+${achievement.xpAwarded} XP'),
                    _AchievementChip(
                      label:
                          '${achievement.badgeCount}/${achievement.totalCoreBadges} badges',
                    ),
                    _AchievementChip(label: 'Workout #${achievement.workoutCount}'),
                  ],
                ),
                if (achievement.nextMilestone != null) ...[
                  SizedBox(height: 12.h),
                  Text(
                    'Next trophy at ${achievement.nextMilestone} workouts',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.48),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                SizedBox(height: 18.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _share(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.20),
                          ),
                          minimumSize: Size.fromHeight(46.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                        ),
                        child: const Text('Share'),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: FilledButton.styleFrom(
                          backgroundColor: _accent,
                          foregroundColor: _dark,
                          minimumSize: Size.fromHeight(46.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                        ),
                        child: const Text('Continue'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AchievementChip extends StatelessWidget {
  final String label;

  const _AchievementChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.78),
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}