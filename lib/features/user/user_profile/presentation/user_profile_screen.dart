import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:pler_to_pler_app/features/user/achievements/data/achievement_service.dart';
import 'package:pler_to_pler_app/features/user/achievements/data/achievement_unlock.dart';
import 'package:pler_to_pler_app/features/user/achievements/presentation/achievements_screen.dart';
import 'package:pler_to_pler_app/widgets/custom_network_image.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  int _tabIndex = 0;
  int _filterIndex = 0;
  bool _communityLiked = false;
  bool _communitySaved = false;
  AchievementOverview? _achievementOverview;
  Object? _achievementError;
  bool _loadingAchievements = true;

  static const _tabs = ['Community', 'My Progress', 'Challenges', 'Activity'];
  static const _filters = ['All Posts', 'Workouts', 'Meals', 'Progress', 'Motivation'];

  Color get _orange => Theme.of(context).colorScheme.primary;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    if (mounted) {
      setState(() {
        _loadingAchievements = true;
        _achievementError = null;
      });
    }
    try {
      final overview = await AchievementService.getOverview();
      if (!mounted) return;
      setState(() {
        _achievementOverview = overview;
        _achievementError = null;
        _loadingAchievements = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _achievementError = error;
        _loadingAchievements = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ProfileController.to;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      body: Obx(() {
        final user = controller.userData;
        final name = _displayName(user?.preferredName, user?.firstName);
        final bio = _nonEmpty(user?.bio) ??
            'Your fitness story starts here. Share progress, stay accountable.';
        final goal = _formatGoal(user?.primaryGoal);
        final workoutCount = user?.workoutHistory?.length ?? 0;
        final trainingDays = user?.trainingDaysPerWeek ?? 0;

        return RefreshIndicator(
          color: _orange,
          onRefresh: () async {
            await Future.wait([
              controller.refresh(),
              _loadAchievements(),
            ]);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: _ProfileHero(
                  name: name,
                  profilePicture: user?.profilePicture,
                  selectedPicture: controller.selectedProfilePicture,
                  orange: _orange,
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 120.h),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _StatsRow(
                      orange: _orange,
                      workoutCount: workoutCount,
                      trainingDays: trainingDays,
                      hasGoal: goal != 'Set your first goal',
                    ),
                    SizedBox(height: 16.h),
                    _ProfileDetails(
                      bio: bio,
                      goal: goal,
                      fitnessLevel: _formatGoal(user?.fitnessLevel),
                      orange: _orange,
                    ),
                    SizedBox(height: 18.h),
                    _TabBar(
                      tabs: _tabs,
                      selected: _tabIndex,
                      orange: _orange,
                      onChanged: (value) => setState(() => _tabIndex = value),
                    ),
                    SizedBox(height: 14.h),
                    if (_tabIndex == 0) ...[
                      _Composer(
                        name: name,
                        profilePicture: user?.profilePicture,
                        selectedPicture: controller.selectedProfilePicture,
                        orange: _orange,
                      ),
                      SizedBox(height: 14.h),
                      _FilterBar(
                        filters: _filters,
                        selected: _filterIndex,
                        orange: _orange,
                        onChanged: (value) => setState(() => _filterIndex = value),
                      ),
                      SizedBox(height: 16.h),
                      _CommunityFoundationCard(
                        name: name,
                        category: _filters[_filterIndex],
                        orange: _orange,
                        liked: _communityLiked,
                        saved: _communitySaved,
                        onLike: () => setState(() => _communityLiked = !_communityLiked),
                        onSave: () => setState(() => _communitySaved = !_communitySaved),
                      ),
                    ] else if (_tabIndex == 2)
                      _ChallengesPanel(
                        role: user?.role,
                        overview: _achievementOverview,
                        fallbackSplitCount: workoutCount,
                        loading: _loadingAchievements,
                        hasError: _achievementError != null,
                        orange: _orange,
                        onRetry: _loadAchievements,
                      )
                    else
                      _TabEmptyState(
                        title: _tabs[_tabIndex],
                        orange: _orange,
                      ),
                  ]),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  static String _displayName(String? preferred, String? firstName) =>
      _nonEmpty(preferred) ?? _nonEmpty(firstName) ?? 'P2P Member';

  static String? _nonEmpty(String? value) {
    final clean = value?.trim();
    return clean == null || clean.isEmpty ? null : clean;
  }

  static String _formatGoal(String? value) {
    final clean = _nonEmpty(value);
    if (clean == null) return 'Set your first goal';
    return clean
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.name,
    required this.profilePicture,
    required this.selectedPicture,
    required this.orange,
  });

  final String name;
  final String? profilePicture;
  final dynamic selectedPicture;
  final Color orange;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 178.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFF111111), const Color(0xFF542000), orange],
              stops: const [0, .58, 1],
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28.r)),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroButton(icon: Icons.arrow_back_ios_new_rounded, onTap: Get.back),
                  const Spacer(),
                  Column(
                    children: [
                      Text('P2P', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: AppFontWeight.title, letterSpacing: -.6)),
                      Text('FIT TECH AI', style: TextStyle(color: Colors.white70, fontSize: 8.sp, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                    ],
                  ),
                  const Spacer(),
                  _HeroButton(
                    icon: Icons.notifications_none_rounded,
                    onTap: () => Get.toNamed(AppRoute.notificationsScreen),
                  ),
                  SizedBox(width: 8.w),
                  _HeroButton(
                    icon: Icons.settings_outlined,
                    onTap: () => Get.toNamed(AppRoute.settingsScreen),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(18.w, 116.h, 18.w, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.all(4.r),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: CustomNetworkImage(
                  height: 92.r,
                  width: 92.r,
                  boxShape: BoxShape.circle,
                  imageFile: selectedPicture,
                  imageUrl: profilePicture,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Good to see you,', style: TextStyle(fontSize: 12.sp, color: Colors.white70, fontWeight: FontWeight.w500)),
                      SizedBox(height: 2.h),
                      Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 24.sp, height: 1, color: Colors.white, fontWeight: AppFontWeight.section, letterSpacing: -.5)),
                      SizedBox(height: 7.h),
                      Text('Stronger every day', style: TextStyle(fontSize: 11.sp, color: Colors.white70, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 5.h),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.r),
                  child: InkWell(
                    onTap: () => Get.toNamed(AppRoute.profileInformationScreen),
                    borderRadius: BorderRadius.circular(22.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.edit_outlined, size: 15.sp, color: Colors.black87),
                        SizedBox(width: 6.w),
                        Text('Edit', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 222.h),
      ],
    );
  }
}

class _HeroButton extends StatelessWidget {
  const _HeroButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white.withValues(alpha: .14),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: EdgeInsets.all(9.r),
            child: Icon(icon, color: Colors.white, size: 18.sp),
          ),
        ),
      );
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.orange, required this.workoutCount, required this.trainingDays, required this.hasGoal});
  final Color orange;
  final int workoutCount;
  final int trainingDays;
  final bool hasGoal;

  @override
  Widget build(BuildContext context) {
    final stats = [
      (Icons.fitness_center_rounded, '$workoutCount', 'Workouts'),
      (Icons.calendar_today_rounded, '$trainingDays', 'Days/week'),
      (Icons.local_fire_department_rounded, '0', 'Streak'),
      (Icons.track_changes_rounded, hasGoal ? '1' : '0', 'Goals'),
    ];
    return Row(
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          if (i > 0) SizedBox(width: 8.w),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 13.h, horizontal: 4.w),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: const Color(0xFFEEEEF0))),
              child: Column(children: [
                Icon(stats[i].$1, color: orange, size: 18.sp),
                SizedBox(height: 5.h),
                Text(stats[i].$2, style: TextStyle(fontSize: 17.sp, fontWeight: AppFontWeight.section, color: const Color(0xFF171717))),
                SizedBox(height: 2.h),
                Text(stats[i].$3, maxLines: 1, style: TextStyle(fontSize: 8.5.sp, color: const Color(0xFF88888E), fontWeight: FontWeight.w500)),
              ]),
            ),
          ),
        ],
      ],
    );
  }
}

class _ProfileDetails extends StatelessWidget {
  const _ProfileDetails({required this.bio, required this.goal, required this.fitnessLevel, required this.orange});
  final String bio;
  final String goal;
  final String fitnessLevel;
  final Color orange;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18.r), border: Border.all(color: const Color(0xFFEEEEF0))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('About me', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: const Color(0xFF171717))),
            const Spacer(),
            GestureDetector(onTap: () => Get.toNamed(AppRoute.profileInformationScreen), child: Text('Edit', style: TextStyle(fontSize: 11.sp, color: orange, fontWeight: FontWeight.w600))),
          ]),
          SizedBox(height: 7.h),
          Text(bio, style: TextStyle(fontSize: 12.sp, height: 1.4, color: const Color(0xFF55555B))),
          SizedBox(height: 14.h),
          Wrap(spacing: 8.w, runSpacing: 8.h, children: [
            _GoalChip(icon: Icons.track_changes_rounded, text: goal, orange: orange),
            if (fitnessLevel != 'Set your first goal') _GoalChip(icon: Icons.bolt_rounded, text: fitnessLevel, orange: orange),
          ]),
        ]),
      );
}

class _GoalChip extends StatelessWidget {
  const _GoalChip({required this.icon, required this.text, required this.orange});
  final IconData icon;
  final String text;
  final Color orange;
  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 8.h),
        decoration: BoxDecoration(color: orange.withValues(alpha: .08), borderRadius: BorderRadius.circular(20.r)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 14.sp, color: orange), SizedBox(width: 5.w), Text(text, style: TextStyle(fontSize: 10.sp, color: const Color(0xFF4B2A18), fontWeight: FontWeight.w600))]),
      );
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.tabs, required this.selected, required this.orange, required this.onChanged});
  final List<String> tabs;
  final int selected;
  final Color orange;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE4E4E7)))),
        child: Row(children: [for (var i = 0; i < tabs.length; i++) Expanded(child: InkWell(onTap: () => onChanged(i), child: Container(padding: EdgeInsets.only(bottom: 10.h), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: i == selected ? orange : Colors.transparent, width: 2.5))), child: Text(tabs[i], textAlign: TextAlign.center, style: TextStyle(fontSize: 10.5.sp, color: i == selected ? const Color(0xFF171717) : const Color(0xFF9A9AA0), fontWeight: i == selected ? FontWeight.w600 : FontWeight.w500)))))]),
      );
}

class _Composer extends StatelessWidget {
  const _Composer({required this.name, required this.profilePicture, required this.selectedPicture, required this.orange});
  final String name;
  final String? profilePicture;
  final dynamic selectedPicture;
  final Color orange;
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        child: InkWell(
          onTap: () => Get.toNamed(AppRoute.beforeAfterScreen),
          borderRadius: BorderRadius.circular(18.r),
          child: Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(18.r), border: Border.all(color: const Color(0xFFE9E9EC))),
            child: Row(children: [
              CustomNetworkImage(height: 36.r, width: 36.r, boxShape: BoxShape.circle, imageFile: selectedPicture, imageUrl: profilePicture),
              SizedBox(width: 9.w),
              Expanded(child: Text("What's on your mind, $name?", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.sp, color: const Color(0xFF9A9AA0)))),
              Icon(Icons.add_photo_alternate_outlined, size: 20.sp, color: const Color(0xFF606066)),
              SizedBox(width: 10.w),
              Container(width: 34.r, height: 34.r, decoration: BoxDecoration(color: orange, shape: BoxShape.circle), child: Icon(Icons.add_rounded, color: Colors.white, size: 22.sp)),
            ]),
          ),
        ),
      );
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.filters, required this.selected, required this.orange, required this.onChanged});
  final List<String> filters;
  final int selected;
  final Color orange;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 36.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (_, __) => SizedBox(width: 8.w),
          itemBuilder: (_, i) => ChoiceChip(
            label: Text(filters[i]),
            selected: selected == i,
            onSelected: (_) => onChanged(i),
            showCheckmark: false,
            labelStyle: TextStyle(fontSize: 10.sp, color: selected == i ? Colors.white : const Color(0xFF45454A), fontWeight: FontWeight.w600),
            selectedColor: orange,
            backgroundColor: Colors.white,
            side: BorderSide(color: selected == i ? orange : const Color(0xFFE6E6E9)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
            padding: EdgeInsets.symmetric(horizontal: 9.w),
          ),
        ),
      );
}

class _CommunityFoundationCard extends StatelessWidget {
  const _CommunityFoundationCard({required this.name, required this.category, required this.orange, required this.liked, required this.saved, required this.onLike, required this.onSave});
  final String name;
  final String category;
  final Color orange;
  final bool liked;
  final bool saved;
  final VoidCallback onLike;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r), border: Border.all(color: const Color(0xFFE8E8EB))),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: 155.h,
            width: double.infinity,
            padding: EdgeInsets.all(18.r),
            decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [const Color(0xFF171717), const Color(0xFF312018), orange])),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .12), borderRadius: BorderRadius.circular(20.r)), child: Text(category, style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.w600))),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.people_alt_outlined, color: Colors.white, size: 28.sp),
                SizedBox(height: 8.h),
                Text('Your community feed lives here', style: TextStyle(color: Colors.white, fontSize: 17.sp, fontWeight: AppFontWeight.section)),
                SizedBox(height: 3.h),
                Text('Real member progress. No stock content.', style: TextStyle(color: Colors.white70, fontSize: 10.5.sp)),
              ]),
            ]),
          ),
          Padding(
            padding: EdgeInsets.all(14.r),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: TextStyle(fontSize: 12.sp, fontWeight: AppFontWeight.section)),
              SizedBox(height: 4.h),
              Text('Share a workout, meal, milestone, or transformation to start the conversation.', style: TextStyle(fontSize: 11.sp, height: 1.35, color: const Color(0xFF5D5D63))),
              SizedBox(height: 13.h),
              Row(children: [
                _PostAction(icon: liked ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: liked ? orange : null, label: 'Like', onTap: onLike),
                SizedBox(width: 18.w),
                _PostAction(icon: Icons.chat_bubble_outline_rounded, label: 'Comment', onTap: () => Get.snackbar('Community', 'Comments become available when a post is live.')),
                const Spacer(),
                _PostAction(icon: saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: saved ? orange : null, label: 'Save', onTap: onSave),
              ]),
            ]),
          ),
        ]),
      );
}

class _PostAction extends StatelessWidget {
  const _PostAction({required this.icon, required this.label, required this.onTap, this.color});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(10.r), child: Padding(padding: EdgeInsets.symmetric(vertical: 5.h), child: Row(children: [Icon(icon, size: 18.sp, color: color ?? const Color(0xFF55555B)), SizedBox(width: 5.w), Text(label, style: TextStyle(fontSize: 9.5.sp, color: color ?? const Color(0xFF55555B), fontWeight: FontWeight.w500))])));
}

class _ChallengesPanel extends StatelessWidget {
  const _ChallengesPanel({
    required this.role,
    required this.overview,
    required this.fallbackSplitCount,
    required this.loading,
    required this.hasError,
    required this.orange,
    required this.onRetry,
  });

  final String? role;
  final AchievementOverview? overview;
  final int fallbackSplitCount;
  final bool loading;
  final bool hasError;
  final Color orange;
  final Future<void> Function() onRetry;

  bool get _isTrainer {
    final normalizedRole = role?.trim().toLowerCase();
    return normalizedRole == 'trainer' || normalizedRole == 'admin';
  }

  AchievementUnlock? get _highestUnlock {
    final unlocks = List<AchievementUnlock>.from(overview?.unlocks ?? const []);
    if (unlocks.isEmpty) return null;
    unlocks.sort((a, b) => a.milestoneValue.compareTo(b.milestoneValue));
    return unlocks.last;
  }

  @override
  Widget build(BuildContext context) {
    if (loading && overview == null) {
      return Container(
        height: 180.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFFE8E8EB)),
        ),
        alignment: Alignment.center,
        child: CircularProgressIndicator(color: orange, strokeWidth: 2.5),
      );
    }

    final splitCount = overview?.workoutCount ?? fallbackSplitCount;
    final badgeCount = overview?.badgeCount ?? 0;
    final streak = overview?.currentStreak ?? 0;
    final topUnlock = _highestUnlock;
    final rankName = topUnlock?.name ?? (splitCount > 0 ? 'Rising Member' : 'Rookie');
    final nextMilestone = overview?.nextMilestone;
    final progress = nextMilestone != null && nextMilestone > 0
        ? (splitCount / nextMilestone).clamp(0, 1).toDouble()
        : (topUnlock == null ? 0.0 : 1.0);
    final remaining = nextMilestone == null ? null : (nextMilestone - splitCount).clamp(0, nextMilestone);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(18.r),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFF171717), const Color(0xFF332315), orange],
            ),
            borderRadius: BorderRadius.circular(22.r),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 56.r,
                    height: 56.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE7A7),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: .5), width: 2),
                    ),
                    child: Icon(Icons.emoji_events_rounded, color: const Color(0xFFB87900), size: 31.sp),
                  ),
                  SizedBox(width: 13.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isTrainer ? 'TRAINER RANKING' : 'MEMBER RANKING',
                          style: TextStyle(color: Colors.white60, fontSize: 8.5.sp, fontWeight: FontWeight.w600, letterSpacing: 1.2),
                        ),
                        SizedBox(height: 3.h),
                        Text(rankName, style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: AppFontWeight.section)),
                        if (topUnlock?.headline.isNotEmpty == true)
                          Text(topUnlock!.headline, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white70, fontSize: 10.sp)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 17.h),
              Row(
                children: [
                  Expanded(child: _ChallengeMetric(icon: Icons.auto_awesome_rounded, value: '$splitCount', label: 'Generated splits')),
                  SizedBox(width: 8.w),
                  Expanded(child: _ChallengeMetric(icon: Icons.military_tech_rounded, value: '$badgeCount', label: 'Badges earned')),
                  SizedBox(width: 8.w),
                  Expanded(child: _ChallengeMetric(icon: Icons.local_fire_department_rounded, value: '$streak', label: 'Day streak')),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      remaining == null ? 'Top rank progress' : '$remaining more split${remaining == 1 ? '' : 's'} to the next trophy',
                      style: TextStyle(color: Colors.white70, fontSize: 9.5.sp, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text('${(progress * 100).round()}%', style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: AppFontWeight.section)),
                ],
              ),
              SizedBox(height: 7.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: LinearProgressIndicator(
                  minHeight: 7.h,
                  value: progress,
                  backgroundColor: Colors.white.withValues(alpha: .15),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFFFD56A)),
                ),
              ),
            ],
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 10.h),
            decoration: BoxDecoration(color: const Color(0xFFFFF4EA), borderRadius: BorderRadius.circular(14.r)),
            child: Row(
              children: [
                Icon(Icons.cloud_off_rounded, color: orange, size: 17.sp),
                SizedBox(width: 8.w),
                Expanded(child: Text('Showing saved activity. Refresh to sync trophies.', style: TextStyle(fontSize: 9.5.sp, color: const Color(0xFF6A4A35)))),
                TextButton(onPressed: () => onRetry(), child: Text('Retry', style: TextStyle(color: orange, fontSize: 10.sp, fontWeight: FontWeight.w600))),
              ],
            ),
          ),
        ],
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r), border: Border.all(color: const Color(0xFFE8E8EB))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Trophies & badges', style: TextStyle(fontSize: 14.sp, fontWeight: AppFontWeight.section, color: const Color(0xFF171717))),
                  const Spacer(),
                  Text('$badgeCount unlocked', style: TextStyle(fontSize: 9.5.sp, color: orange, fontWeight: FontWeight.w600)),
                ],
              ),
              SizedBox(height: 12.h),
              if (overview?.unlocks.isNotEmpty == true)
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: overview!.unlocks.map((unlock) => _BadgeChip(unlock: unlock, orange: orange)).toList(),
                )
              else
                Row(
                  children: [
                    Container(width: 38.r, height: 38.r, decoration: const BoxDecoration(color: Color(0xFFF4F4F5), shape: BoxShape.circle), child: Icon(Icons.lock_outline_rounded, color: const Color(0xFF9A9AA0), size: 18.sp)),
                    SizedBox(width: 10.w),
                    Expanded(child: Text('Generate your first split to begin earning P2P trophies.', style: TextStyle(fontSize: 10.5.sp, height: 1.35, color: const Color(0xFF66666C)))),
                  ],
                ),
              SizedBox(height: 14.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AchievementsScreen())),
                  icon: Icon(Icons.emoji_events_outlined, size: 17.sp),
                  label: const Text('View all achievements'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: orange,
                    side: BorderSide(color: orange.withValues(alpha: .35)),
                    padding: EdgeInsets.symmetric(vertical: 11.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    textStyle: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChallengeMetric extends StatelessWidget {
  const _ChallengeMetric({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .1), borderRadius: BorderRadius.circular(14.r)),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFFFD56A), size: 18.sp),
            SizedBox(height: 4.h),
            Text(value, style: TextStyle(color: Colors.white, fontSize: 17.sp, fontWeight: AppFontWeight.section)),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white60, fontSize: 7.5.sp, fontWeight: FontWeight.w500)),
          ],
        ),
      );
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.unlock, required this.orange});
  final AchievementUnlock unlock;
  final Color orange;

  @override
  Widget build(BuildContext context) => Container(
        constraints: BoxConstraints(maxWidth: 150.w),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(color: orange.withValues(alpha: .08), borderRadius: BorderRadius.circular(14.r)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.workspace_premium_rounded, color: orange, size: 17.sp),
            SizedBox(width: 6.w),
            Flexible(child: Text(unlock.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9.5.sp, fontWeight: FontWeight.w600, color: const Color(0xFF3E2B20)))),
          ],
        ),
      );
}

class _TabEmptyState extends StatelessWidget {
  const _TabEmptyState({required this.title, required this.orange});
  final String title;
  final Color orange;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 34.h),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r), border: Border.all(color: const Color(0xFFE8E8EB))),
        child: Column(children: [
          Container(width: 52.r, height: 52.r, decoration: BoxDecoration(color: orange.withValues(alpha: .1), shape: BoxShape.circle), child: Icon(Icons.insights_rounded, color: orange, size: 25.sp)),
          SizedBox(height: 12.h),
          Text('$title is ready for your journey', textAlign: TextAlign.center, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 5.h),
          Text('Your real activity will appear here as you use P2P Fit Tech AI.', textAlign: TextAlign.center, style: TextStyle(fontSize: 10.5.sp, height: 1.4, color: const Color(0xFF85858B))),
        ]),
      );
}
