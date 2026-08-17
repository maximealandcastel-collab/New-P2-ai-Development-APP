import 'package:flutter/material.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/anam/presentation/arguments/anam_call_args.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/trainer_details_model.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/controllers/subscribe_controller.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/screens/widgets/trainer_profile_shimmer.dart';

// ─── Theme ────────────────────────────────────────────────────────────────────
const _orange  = Color(0xFFF97316);
const _bg      = Color(0xFFF9FAFB);

class TrainerProfileScreen extends StatefulWidget {
  const TrainerProfileScreen({super.key});
  @override
  State<TrainerProfileScreen> createState() => _TrainerProfileScreenState();
}

class _TrainerProfileScreenState extends State<TrainerProfileScreen>
    with SingleTickerProviderStateMixin {
  final String? trainerID = Get.arguments as String?;
  final _ctrl = SubscribeController.to;
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.fetchDetails(trainerID ?? '');
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  bool get _isSubscribed {
    try {
      final sub = ProfileController.to.userData?.subscribedTrainer;
      return sub?.sId != null && sub!.sId == trainerID;
    } catch (_) {
      return false;
    }
  }

  String _tier(TrainerDetailsModel? t) {
    final price = t?.subscriptionPrice?.paid ?? 0;
    if (price >= 49) return 'Elite';
    if (price >= 29) return 'Pro';
    return 'Standard';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loading = _ctrl.detailsLoadingState == LoadingState.initial ||
          _ctrl.detailsLoadingState == LoadingState.loading;
      final trainer = _ctrl.trainerDetails;

      if (loading) {
        return Scaffold(
          backgroundColor: _bg,
          body: SafeArea(
            child: Column(children: TrainerProfileShimmer.contentSlivers()
                .map((s) => SliverToBoxAdapter(child: s) as Widget)
                .toList()),
          ),
        );
      }

      return Scaffold(
        backgroundColor: _bg,
        extendBodyBehindAppBar: true,
        body: DefaultTabController(
          length: 3,
          child: NestedScrollView(
            headerSliverBuilder: (ctx, _) => [
              _HeroSliver(trainer: trainer, tier: _tier(trainer)),
            ],
            body: Column(
              children: [
                // ── Subscription / Book banner ───────────────────────────
                _isSubscribed
                    ? _SubBanner(trainer: trainer)
                    : _BookBanner(trainer: trainer, trainerID: trainerID),
                // ── 4 stat squares ───────────────────────────────────────
                _StatRow(),
                // ── Tab bar ──────────────────────────────────────────────
                _ProfileTabBar(tabs: _tabs),
                // ── Tab content ──────────────────────────────────────────
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      _OverviewTab(trainer: trainer),
                      _ProgramsTab(),
                      _ReviewsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // ── Sticky bottom bar ────────────────────────────────────────────
        bottomNavigationBar: _BottomBar(trainer: trainer, trainerID: trainerID),
      );
    });
  }
}

// ─── Hero Image Sliver ────────────────────────────────────────────────────────

class _HeroSliver extends StatelessWidget {
  final TrainerDetailsModel? trainer;
  final String tier;
  const _HeroSliver({required this.trainer, required this.tier});

  @override
  Widget build(BuildContext context) {
    final name = trainer?.name ?? '';
    final specialty = trainer?.specialty ?? '';
    final photo = trainer?.profileImage ?? '';

    return SliverAppBar(
      expandedHeight: 290.h,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      leading: GestureDetector(
        onTap: Get.back,
        child: Container(
          margin: EdgeInsets.all(8.r),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Icon(Icons.arrow_back_ios_new_rounded, size: 16.sp, color: Colors.black),
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.all(8.r),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: IconButton(
            icon: Icon(Icons.chat_bubble_outline_rounded, size: 18.sp, color: Colors.black),
            onPressed: () {},
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Photo
            photo.isNotEmpty
                ? Image.network(photo, fit: BoxFit.cover, alignment: Alignment.topCenter,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]))
                : Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1F2937), Color(0xFF374151)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
            // Gradient overlay
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.4, 0.7, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
            // Name / tier info at bottom
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: 16.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(children: [
                    _TierBadge(tier: tier),
                    SizedBox(width: 8.w),
                    _RatingPill(),
                  ]),
                  SizedBox(height: 8.h),
                  Text(name,
                      style: TextStyle(color: Colors.white, fontSize: 30.sp, fontWeight: FontWeight.w800)),
                  SizedBox(height: 4.h),
                  Text(
                    '$tier Trainer${specialty.isNotEmpty ? " · $specialty" : ""} · 10yr exp',
                    style: TextStyle(color: Colors.white70, fontSize: 13.sp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TierBadge extends StatelessWidget {
  final String tier;
  const _TierBadge({required this.tier});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      decoration: BoxDecoration(color: _orange, borderRadius: BorderRadius.circular(20.r)),
      child: Text(tier, style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w700)),
    );
  }
}

class _RatingPill extends StatelessWidget {
  const _RatingPill();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.star_rounded, color: _orange, size: 14.sp),
        SizedBox(width: 3.w),
        Text('4.9', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.black)),
      ]),
    );
  }
}

// ─── Subscription / Book Banners ──────────────────────────────────────────────

class _SubBanner extends StatelessWidget {
  final TrainerDetailsModel? trainer;
  const _SubBanner({required this.trainer});

  @override
  Widget build(BuildContext context) {
    final price = trainer?.subscriptionPrice?.paid ?? 49;
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
      color: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Container(
            width: 42.w, height: 42.w,
            decoration: BoxDecoration(color: _orange, shape: BoxShape.circle),
            child: Icon(Icons.check_circle_outline, color: Colors.white, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("You're Subscribed",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14.sp)),
              Text('Renews next month · \$${price.toStringAsFixed(0)}/mo',
                  style: TextStyle(color: Colors.white54, fontSize: 11.sp)),
            ]),
          ),
          Text('Manage', style: TextStyle(color: _orange, fontWeight: FontWeight.w700, fontSize: 13.sp)),
        ],
      ),
    );
  }
}

class _BookBanner extends StatelessWidget {
  final TrainerDetailsModel? trainer;
  final String? trainerID;
  const _BookBanner({required this.trainer, required this.trainerID});

  @override
  Widget build(BuildContext context) {
    final price = trainer?.subscriptionPrice?.paid ?? 19.99;
    return Container(
      color: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 42.w, height: 42.w,
            decoration: BoxDecoration(color: _orange, shape: BoxShape.circle),
            child: Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Start Training Today',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14.sp)),
              Text('Full access · \$${price.toStringAsFixed(2)}/mo',
                  style: TextStyle(color: Colors.white54, fontSize: 11.sp)),
            ]),
          ),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoute.subscribeSelectScreen, arguments: trainerID),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(color: _orange, borderRadius: BorderRadius.circular(20.r)),
              child: Text('Book', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.sp)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stats Row ────────────────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  const _StatRow();

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem('🔥', '7', 'Streak', const Color(0xFFFFF7ED), const Color(0xFFFED7AA)),
      _StatItem('📈', '85%', 'Progress', const Color(0xFFF0FDF4), const Color(0xFFBBF7D0)),
      _StatItem('📅', '4/5', 'Sessions', const Color(0xFFEFF6FF), const Color(0xFFBFDBFE)),
      _StatItem('🏆', '120', 'Points', const Color(0xFFFAF5FF), const Color(0xFFE9D5FF)),
    ];
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      child: Row(
        children: items.map((s) => Expanded(child: _StatCard(s: s))).toList(),
      ),
    );
  }
}

class _StatItem {
  final String emoji, value, label;
  final Color bg, border;
  const _StatItem(this.emoji, this.value, this.label, this.bg, this.border);
}

class _StatCard extends StatelessWidget {
  final _StatItem s;
  const _StatCard({required this.s});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3.w),
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: s.bg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: s.border),
      ),
      child: Column(children: [
        Text(s.emoji, style: TextStyle(fontSize: 18.sp)),
        SizedBox(height: 4.h),
        Text(s.value, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: Colors.black)),
        Text(s.label, style: TextStyle(fontSize: 10.sp, color: const Color(0xFF6B7280))),
      ]),
    );
  }
}

// ─── Tab Bar ──────────────────────────────────────────────────────────────────

class _ProfileTabBar extends StatelessWidget {
  final TabController tabs;
  const _ProfileTabBar({required this.tabs});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: tabs,
        labelColor: Colors.black,
        unselectedLabelColor: const Color(0xFF9CA3AF),
        labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp),
        indicatorColor: _orange,
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.label,
        tabs: const [Tab(text: 'Overview'), Tab(text: 'Programs'), Tab(text: 'Reviews')],
      ),
    );
  }
}

// ─── Overview Tab ─────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final TrainerDetailsModel? trainer;
  const _OverviewTab({required this.trainer});

  @override
  Widget build(BuildContext context) {
    final name = trainer?.name?.split(' ').first ?? 'Trainer';
    final bio = trainer?.bio ?? 'Expert trainer dedicated to helping you reach your fitness goals. Specializing in personalized programs built for real, lasting results.';
    final tags = trainer?.trainingStyleTags ?? ['HIIT', 'Strength', 'Fat Loss', 'Nutrition Coaching'];
    final certs = trainer?.certifications ?? ['NASM Certified Personal Trainer', 'Precision Nutrition Level 1 Coach', '10 years coaching experience'];

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      children: [
        SizedBox(height: 20.h),
        // About
        _SectionTitle('About $name'),
        SizedBox(height: 8.h),
        Text(bio, style: TextStyle(fontSize: 14.sp, color: const Color(0xFF374151), height: 1.6)),
        SizedBox(height: 24.h),
        // Specialties
        _SectionTitle('Specialties'),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: tags.map((t) => _TagChip(t)).toList(),
        ),
        SizedBox(height: 24.h),
        // This Week's Plan
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SectionTitle("This Week's Plan"),
            Text('View All >', style: TextStyle(fontSize: 13.sp, color: _orange, fontWeight: FontWeight.w600)),
          ],
        ),
        SizedBox(height: 10.h),
        _WeeklyPlanCard(),
        SizedBox(height: 24.h),
        // Next Available Sessions
        _SectionTitle('Next Available Sessions'),
        SizedBox(height: 10.h),
        _SessionRow(day: 'THU', date: '16', title: 'Live Training Session', sub: 'Upper Body Focus · 7:00 PM EST'),
        SizedBox(height: 8.h),
        _SessionRow(day: 'SAT', date: '18', title: 'Check-In Call', sub: 'Progress Review · 30 min'),
        SizedBox(height: 24.h),
        // Credentials
        _SectionTitle('Credentials'),
        SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: certs.asMap().entries.map((e) {
              return Column(children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  child: Row(children: [
                    Icon(Icons.check_circle_outline, color: _orange, size: 18.sp),
                    SizedBox(width: 10.w),
                    Expanded(child: Text(e.value, style: TextStyle(fontSize: 13.sp, color: Colors.black))),
                  ]),
                ),
                if (e.key < certs.length - 1)
                  Divider(height: 1, color: const Color(0xFFF3F4F6), indent: 42.w),
              ]);
            }).toList(),
          ),
        ),
        SizedBox(height: 100.h),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800, color: Colors.black));
}

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip(this.label);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: _orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _orange.withValues(alpha: 0.25)),
      ),
      child: Text(label, style: TextStyle(fontSize: 12.sp, color: _orange, fontWeight: FontWeight.w600)),
    );
  }
}

class _WeeklyPlanCard extends StatelessWidget {
  const _WeeklyPlanCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        color: Colors.black,
      ),
      child: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              gradient: LinearGradient(
                colors: [Colors.grey[800]!, Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Tag
          Positioned(
            top: 12.h,
            left: 12.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text('HIIT Strength', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11.sp)),
                Text('Day 3 · Upper Body', style: TextStyle(color: Colors.white70, fontSize: 10.sp)),
              ]),
            ),
          ),
          // Play button
          Center(
            child: Container(
              width: 48.r, height: 48.r,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
              child: Icon(Icons.play_arrow_rounded, color: Colors.black, size: 28.sp),
            ),
          ),
          // Duration + Preview
          Positioned(
            bottom: 12.h,
            left: 14.w,
            right: 14.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('25:30', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.sp)),
                Text('Preview', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.sp)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  final String day, date, title, sub;
  const _SessionRow({required this.day, required this.date, required this.title, required this.sub});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w, height: 48.w,
            decoration: BoxDecoration(
              color: _orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(day, style: TextStyle(color: _orange, fontSize: 9.sp, fontWeight: FontWeight.w600)),
              Text(date, style: TextStyle(color: _orange, fontSize: 18.sp, fontWeight: FontWeight.w800)),
            ]),
          ),
          SizedBox(width: 14.w),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.black)),
            Text(sub, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
          ])),
          Icon(Icons.arrow_forward_ios_rounded, size: 14.sp, color: const Color(0xFFD1D5DB)),
        ],
      ),
    );
  }
}

// ─── Programs Tab ─────────────────────────────────────────────────────────────

class _ProgramsTab extends StatelessWidget {
  const _ProgramsTab();
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.r),
      children: [
        _ProgramCard(title: 'Fat Loss Kickstart', duration: '6 weeks', progress: 0.35, started: true),
        SizedBox(height: 12.h),
        _ProgramCard(title: 'HIIT Strength Builder', duration: '8 weeks', progress: 0, started: false),
        SizedBox(height: 12.h),
        _ProgramCard(title: 'Metabolic Conditioning', duration: '4 weeks', progress: 0, started: false),
      ],
    );
  }
}

class _ProgramCard extends StatelessWidget {
  final String title, duration;
  final double progress;
  final bool started;
  const _ProgramCard({required this.title, required this.duration, required this.progress, required this.started});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 60.w, height: 60.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.fitness_center_rounded, color: _orange, size: 24.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.black)),
              Text(duration, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
              SizedBox(height: 6.h),
              if (progress > 0) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: AlwaysStoppedAnimation(_orange),
                    minHeight: 4.h,
                  ),
                ),
              ] else
                Text('Not started', style: TextStyle(fontSize: 11.sp, color: const Color(0xFF9CA3AF))),
            ]),
          ),
          SizedBox(width: 12.w),
          started
              ? ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  ),
                  child: Text('Resume', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700)),
                )
              : ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  ),
                  child: Text('Start', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700)),
                ),
        ],
      ),
    );
  }
}

// ─── Reviews Tab ─────────────────────────────────────────────────────────────

class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.star_border_rounded, size: 48.sp, color: const Color(0xFFD1D5DB)),
          SizedBox(height: 16.h),
          Text('Reviews coming soon', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.black)),
          SizedBox(height: 8.h),
          Text('Be the first to share your experience.', style: TextStyle(fontSize: 13.sp, color: const Color(0xFF9CA3AF)), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

// ─── Sticky Bottom Bar ────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final TrainerDetailsModel? trainer;
  final String? trainerID;
  const _BottomBar({required this.trainer, required this.trainerID});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h + bottomPad),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Get.toNamed(AppRoute.subscribeSelectScreen, arguments: trainerID),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.videocam_rounded, color: Colors.white, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text('Book Live Session', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15.sp)),
                ]),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoute.chatScreen,
                arguments: ChatScreenArgs(
                  displayName: trainer?.name ?? 'Trainer',
                  trainerId: trainerID ?? '',
                  isAnamEnabled: true,
                )),
            child: Container(
              width: 52.r, height: 52.r,
              decoration: BoxDecoration(color: _orange, borderRadius: BorderRadius.circular(16.r)),
              child: Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 22.sp),
            ),
          ),
        ],
      ),
    );
  }
}
