import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/features/user/achievements/data/achievement_service.dart';
import 'package:pler_to_pler_app/features/user/achievements/data/achievement_unlock.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  AchievementOverview? _overview;
  Object? _error;

  static const _background = Color(0xFFF2F2F2);
  static const _ink = Color(0xFF171717);
  static const _muted = Color(0xFF777777);
  static const _gold = Color(0xFFD2A23A);
  static const _goldSoft = Color(0xFFFFF4D9);

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    if (mounted) {
      setState(() => _error = null);
    }
    try {
      final overview = await AchievementService.getOverview();
      if (!mounted) return;
      setState(() {
        _overview = overview;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded, color: _ink),
        ),
        title: Text(
          'Achievements',
          style: TextStyle(
            color: _ink,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: _overview == null && _error == null
          ? const Center(
              child: CircularProgressIndicator(color: _gold),
            )
          : _error != null
              ? _ErrorState(onRetry: _loadAchievements)
              : RefreshIndicator(
                  color: _gold,
                  onRefresh: _loadAchievements,
                  child: _AchievementContent(overview: _overview!),
                ),
    );
  }
}

class _AchievementContent extends StatelessWidget {
  final AchievementOverview overview;

  const _AchievementContent({required this.overview});

  static const _ink = Color(0xFF171717);
  static const _muted = Color(0xFF777777);
  static const _gold = Color(0xFFD2A23A);
  static const _goldSoft = Color(0xFFFFF4D9);
  static const _orange = Color(0xFFFF6B35);

  @override
  Widget build(BuildContext context) {
    final definitions = overview.definitions;
    final unlockIds = overview.unlocks.map((unlock) => unlock.achievementId).toSet();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 28.h),
      children: [
        _ProgressHero(overview: overview),
        SizedBox(height: 22.h),
        if (overview.unlocks.isNotEmpty) ...[
          _SectionHeading(
            title: 'Your trophies',
            subtitle: 'Milestones you have earned along the way.',
          ),
          SizedBox(height: 10.h),
          for (final unlock in overview.unlocks) ...[
            _EarnedAchievementCard(unlock: unlock),
            SizedBox(height: 10.h),
          ],
          SizedBox(height: 8.h),
        ],
        _SectionHeading(
          title: 'Achievement roadmap',
          subtitle: overview.unlocks.isEmpty
              ? 'Every workout moves you closer to the next tier.'
              : 'Keep showing up to unlock the next badge.',
        ),
        SizedBox(height: 10.h),
        const _StreakInfoCard(),
        SizedBox(height: 10.h),
        for (final definition in definitions) ...[
          _RoadmapCard(
            definition: definition,
            isEarned: unlockIds.contains(definition.achievementId),
            workoutCount: overview.workoutCount,
          ),
          SizedBox(height: 10.h),
        ],
        if (definitions.isEmpty)
          const _NoRoadmapState(),
      ],
    );
  }
}

class _StreakInfoCard extends StatelessWidget {
  const _StreakInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EE),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFF5E3C2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFFFE9C4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: Color(0xFFE39A22),
              size: 21,
            ),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How streaks work',
                  style: TextStyle(
                    color: const Color(0xFF171717),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Your streak grows on consecutive training days. Trophy tiers '
                  'and XP are awarded from your lifetime completed workouts.',
                  style: TextStyle(
                    color: const Color(0xFF777777),
                    fontSize: 10.5.sp,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressHero extends StatelessWidget {
  final AchievementOverview overview;

  const _ProgressHero({required this.overview});

  static const _ink = Color(0xFF171717);
  static const _muted = Color(0xFF777777);
  static const _gold = Color(0xFFD2A23A);
  static const _goldSoft = Color(0xFFFFF4D9);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFEAEAEA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 58.w,
                height: 58.w,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: _goldSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: _gold,
                  size: 34,
                ),
              ),
              SizedBox(width: 13.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      overview.unlocks.isEmpty
                          ? 'Your journey starts here'
                          : '${overview.badgeCount} badge${overview.badgeCount == 1 ? '' : 's'} earned',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      overview.nextMilestone == null
                          ? 'You have unlocked every core tier.'
                          : '${overview.nextMilestone! - overview.workoutCount} workouts to your next badge',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 12.sp,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  value: '${overview.workoutCount}',
                  label: 'Workouts',
                ),
              ),
              _MetricDivider(),
              Expanded(
                child: _Metric(
                  value: '${overview.currentStreak}',
                  label: 'Day streak',
                ),
              ),
              _MetricDivider(),
              Expanded(
                child: _Metric(
                  value: '${overview.badgeCount}/${overview.definitions.length}',
                  label: 'Badges',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String value;
  final String label;

  const _Metric({required this.value, required this.label});

  static const _ink = Color(0xFF171717);
  static const _muted = Color(0xFF777777);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: _ink,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          label,
          style: TextStyle(
            color: _muted,
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _MetricDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28.h,
      color: const Color(0xFFE7E7E7),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeading({required this.title, required this.subtitle});

  static const _ink = Color(0xFF171717);
  static const _muted = Color(0xFF777777);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: _ink,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          subtitle,
          style: TextStyle(
            color: _muted,
            fontSize: 11.sp,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _EarnedAchievementCard extends StatelessWidget {
  final AchievementUnlock unlock;

  const _EarnedAchievementCard({required this.unlock});

  static const _gold = Color(0xFFD2A23A);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFF0E2BD)),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _gold.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: _gold,
              size: 27,
            ),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unlock.name,
                  style: TextStyle(
                    color: const Color(0xFF171717),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  unlock.headline,
                  style: TextStyle(
                    color: const Color(0xFF777777),
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+${unlock.xpAwarded} XP',
            style: TextStyle(
              color: _gold,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoadmapCard extends StatelessWidget {
  final AchievementDefinition definition;
  final bool isEarned;
  final int workoutCount;

  const _RoadmapCard({
    required this.definition,
    required this.isEarned,
    required this.workoutCount,
  });

  static const _gold = Color(0xFFD2A23A);
  static const _ink = Color(0xFF171717);
  static const _muted = Color(0xFF777777);

  @override
  Widget build(BuildContext context) {
    final remaining =
        (definition.milestoneValue - workoutCount).clamp(0, definition.milestoneValue);
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isEarned ? const Color(0xFFFFFCF5) : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isEarned ? const Color(0xFFF0E2BD) : const Color(0xFFEAEAEA),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isEarned ? _gold.withOpacity(0.14) : const Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEarned ? Icons.emoji_events_rounded : Icons.lock_outline_rounded,
              color: isEarned ? _gold : const Color(0xFFAAAAAA),
              size: 22,
            ),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        definition.name,
                        style: TextStyle(
                          color: _ink,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      isEarned
                          ? 'Unlocked'
                          : '${definition.milestoneValue} workouts',
                      style: TextStyle(
                        color: isEarned ? _gold : _muted,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  definition.description,
                  style: TextStyle(
                    color: _muted,
                    fontSize: 11.sp,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Text(
                      '+${definition.xpAwarded} XP',
                      style: TextStyle(
                        color: _gold,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (!isEarned && remaining > 0) ...[
                      SizedBox(width: 8.w),
                      Text(
                        '$remaining to go',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoRoadmapState extends StatelessWidget {
  const _NoRoadmapState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: const Text('Your achievement roadmap will appear here soon.'),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              color: const Color(0xFFD2A23A),
              size: 42.sp,
            ),
            SizedBox(height: 12.h),
            Text(
              'Achievements are taking a moment to load.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}