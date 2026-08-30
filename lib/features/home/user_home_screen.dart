import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_gym_model.dart';
import 'package:pler_to_pler_app/features/gyms/services/gym_location_service.dart';
import 'package:pler_to_pler_app/features/home/presentation/controllers/user_home_controller.dart';
import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/widgets/app_bar.dart';

// ─────────────────────────────────────────────────────────────────────────────
// User Home — matches design:
// greeting bar → Daily workout progress (week strip) → Gyms near you →
// Generate Workout Split banner → Today's overview → Today's assigned workout
// ─────────────────────────────────────────────────────────────────────────────

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiating the controller is the whole point of this line.
    //
    // UserHomeController is registered lazyPut, and nothing in the app ever
    // resolved it — so its onInit never ran and loadData() never fired. That is
    // why this screen showed a permanent "0% / Maintain Physique / Full Body"
    // and why the greeting sat on "Hi there!": loadData() is what fetches
    // today's overview AND calls ProfileController.loadData(), which populates
    // the name FeedAppBar reads.
    final c = Get.find<UserHomeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFFF6B35),
          onRefresh: c.refresh,
          child: SingleChildScrollView(
            // Needed for pull-to-refresh: without it a short page has nothing
            // to drag against.
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FeedAppBar(),
                _SectionTitle('Daily workout progress'),
                const _WeekStrip(),
                SizedBox(height: 16.h),
                const _GymsCard(),
                SizedBox(height: 16.h),
                const _GenerateWorkoutBanner(),
                SizedBox(height: 16.h),
                _SectionTitle("Today's overview"),
                _TodaysOverviewCard(c: c),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Section title ────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }
}

// ─── Week strip ───────────────────────────────────────────────────────────────
class _WeekStrip extends StatelessWidget {
  const _WeekStrip();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return SizedBox(
      height: 72.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: labels.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, i) {
          final day = monday.add(Duration(days: i));
          final isToday = day.day == now.day && day.month == now.month;
          return Container(
            width: 50.w,   // compact square proportions
            decoration: BoxDecoration(
              color: isToday ? const Color(0xFFFF6B35) : Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: isToday
                  ? null
                  : Border.all(color: const Color(0xFFE8E8E8), width: 1.2),
              boxShadow: isToday
                  ? [BoxShadow(color: const Color(0xFFFF6B35).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isToday ? Colors.white70 : Colors.black45,
                    fontWeight: AppFontWeight.body,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${day.day}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    // Today stays heavier than the rest, just less shouty than
                    // the previous w700/w500 pair. The colour and the filled
                    // orange chip already carry the selection.
                    fontWeight:
                        isToday ? AppFontWeight.label : AppFontWeight.emphasis,
                    color: isToday ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Gyms near you ───────────────────────────────────────────────────────────
/// Nearest gyms from the app's real gym catalogue.
///
/// This used to be three hardcoded tuples — invented names ("StrongFit
/// Downtown", "Iron Pulse Gym"), invented distances ("0.8 km away") and stock
/// Unsplash photos — none of which corresponded to anything in the Gyms tab. It
/// now reads `EnterpriseGymModel.partners`, the same catalogue that tab uses,
/// and sorts it with the same `GymLocationService.sortByDistance`, so the two
/// screens agree and the distances are real.
///
/// Stateful because the sort depends on a location fix that arrives
/// asynchronously; until then the unsorted catalogue is shown rather than a
/// spinner, since the names and photos are correct either way.
class _GymsCard extends StatefulWidget {
  const _GymsCard();

  @override
  State<_GymsCard> createState() => _GymsCardState();
}

class _GymsCardState extends State<_GymsCard> {
  List<EnterpriseGymModel> _gyms = List.from(EnterpriseGymModel.partners);

  @override
  void initState() {
    super.initState();
    _sortByLocation();
  }

  Future<void> _sortByLocation() async {
    final pos = await GymLocationService().getCurrentPosition();
    if (pos == null || !mounted) return; // permission denied or no fix
    setState(() {
      _gyms = GymLocationService()
          .sortByDistance(List.from(EnterpriseGymModel.partners), pos);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Gyms',
                  style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black)),
              GestureDetector(
                onTap: () => BottomNavBarController.to.onChange(2),
                child: Text('Near Gym',
                    style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFFF6B35))),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 172.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              // Three nearest, matching the original card's density.
              itemCount: _gyms.length < 3 ? _gyms.length : 3,
              separatorBuilder: (_, __) => SizedBox(width: 12.w),
              itemBuilder: (context, i) {
                final gym = _gyms[i];
                final name = gym.name;
                final photo = gym.imageUrl;
                // Empty until a location fix lands, so fall back to the gym's
                // city rather than showing a bare pin icon with nothing after it.
                final distance = gym.distanceLabel.isNotEmpty
                    ? gym.distanceLabel
                    : gym.city;
                return SizedBox(
                  width: 142.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: CachedNetworkImage(
                          imageUrl: photo,
                          height: 75.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          fadeInDuration: const Duration(milliseconds: 280),
                          placeholder: (_, __) => Container(
                            height: 75.h,
                            color: const Color(0xFFE8E8E8),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            height: 75.h,
                            color: const Color(0xFF2B2B2B),
                            child: Icon(Icons.fitness_center,
                                color: Colors.white38, size: 30.sp),
                          ),
                        ),
                      ),
                      SizedBox(height: 5.h),
                      SizedBox(
                            width: double.infinity,
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 12.sp, color: Colors.black54),
                          SizedBox(width: 2.w),
                          Flexible(
                                child: Text(
                                  distance,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.black45,
                                  ),
                                ),
                              ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      // Was a hardcoded grey "Disable" chip on every card — the
                      // same word regardless of the gym, and not a state the
                      // app has. Shows the gym's actual standing instead, using
                      // the same isOwnGym/isActivated flags the Gyms tab reads,
                      // so a gym that has not signed is not presented as one
                      // the user can walk into.
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: gym.isOwnGym
                              ? const Color(0xFFFF6B35)
                              : gym.isActivated
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFF9E9E9E),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                            gym.isOwnGym
                                ? 'Your Gym'
                                : gym.isActivated
                                    ? 'Partner'
                                 : gym.statusLabel,
                            style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Generate Workout Split banner ───────────────────────────────────────────
// Dark/orange — matches Screenshot 1 (approved source of truth).
// Left: "GENERATE / WORKOUT SPLIT" + description + teal CTA button + P2P badge.
// Right: battle-ropes photo fading in.
class _GenerateWorkoutBanner extends StatelessWidget {
  const _GenerateWorkoutBanner();

  static const _ropePhoto =
      'https://images.unsplash.com/photo-1549060279-7e168fcee0c2'
      '?w=500&h=220&fit=crop&crop=center&q=80';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // workoutScreen is the registered generator that actually reaches
      // WorkoutController.generateWorkout(). The previous target,
      // workoutFinderFlow, only exists in the abandoned lib/routes table and
      // was never registered, so tapping this crashed on a null unknownRoute.
      onTap: () => Get.toNamed(AppRoute.workoutScreen),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        // minHeight, not a fixed height. At the old 158.h the text column below
        // needed ~166 and the card shipped with a visible black-and-yellow
        // "BOTTOM OVERFLOWED BY 8.4 PIXELS" banner across it on a real device.
        //
        // The Stack sizes itself to its one non-positioned child (the text
        // Padding), and the photo and gradients are all Positioned with
        // top:0/bottom:0, so they stretch to whatever height that produces.
        // Dropping the hard height therefore lets the card fit its own content,
        // while minHeight keeps the intended proportions when the content is
        // shorter. It also means a larger system font size grows the card
        // instead of overflowing it.
        constraints: BoxConstraints(minHeight: 190.h),
        // width matters as much as height here. A Stack sizes to its only
        // non-positioned child — the text column — so without this the card
        // hugged the text and rendered about half the screen wide, wedged
        // between two full-width sections. Every other layer is Positioned
        // against the card's edges (photo right:0 width 230.w, dark overlay
        // left:0 width 230.w, badge left:130.w), so at that width they all
        // overlapped and the photo was squashed behind the copy. The layout was
        // written for a full-width card; it just never got one.
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: const Color(0xFF1A1A1A),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Stack(
            children: [
              // ── Battle-ropes photo — right side, fades in from right ──
              Positioned(
                right: 0, top: 0, bottom: 0,
                width: 230.w,
                child: ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.transparent, Colors.white],
                    stops: [0.0, 0.42],
                  ).createShader(b),
                  blendMode: BlendMode.dstIn,
                  child: CachedNetworkImage(
                    imageUrl: _ropePhoto,
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 350),
                    placeholder: (_, __) => const ColoredBox(color: Color(0xFF2A2A2A)),
                    errorWidget: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
              // ── Dark overlay left — keeps text readable ───────────────
              Positioned(
                left: 0, top: 0, bottom: 0, width: 230.w,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1A1A1A), Colors.transparent],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
              // ── Subtle orange warm tint on left ───────────────────────
              Positioned(
                left: 0, top: 0, bottom: 0, width: 160.w,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0x22FF6B35), Colors.transparent],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
              // ── P2P badge (sits between text and photo) ───────────────
              Positioned(
                left: 130.w, top: 16.h,
                child: Container(
                  width: 42.r, height: 42.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B35).withOpacity(0.45),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Deliberately left at w900, unlike the rest of this
                      // screen. This is 9sp inside a 42px circle — micro-type
                      // needs the extra weight to stay legible at all, and the
                      // lighter scale turns it to mush.
                      Text('P2P',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.sp,
                            fontWeight: AppFontWeight.display,
                            letterSpacing: 0.3,
                          )),
                      Text('AI',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 7.sp,
                            fontWeight: AppFontWeight.label,
                          )),
                    ],
                  ),
                ),
              ),
              // ── Text content ─────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 18.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Generate',
                      style: TextStyle(
                        color: const Color(0xFFFF6B35),
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                    Text(
                      'Workout\nsplit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.05,
                        letterSpacing: -0.1,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Get a custom workout plan\ntailored to your goals.',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10.sp,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    // Teal CTA — matches Screenshot 1
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 11.w, vertical: 7.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00BCD4),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome,
                              color: Colors.white, size: 11.sp),
                          SizedBox(width: 5.w),
                          Text(
                            'Generate Workout Split',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(Icons.arrow_forward,
                              color: Colors.white, size: 11.sp),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Today's overview card ────────────────────────────────────────────────────
class _TodaysOverviewCard extends StatelessWidget {
  final UserHomeController c;
  const _TodaysOverviewCard({required this.c});

  /// The API returns these as lists (a workout can have several goals or focus
  /// areas). Joins them for display and title-cases the snake_case values the
  /// backend sends, e.g. `upper_body` -> `Upper Body`.
  static String _fmt(List<String>? values, String fallback) {
    if (values == null || values.isEmpty) return fallback;
    return values
        .map((v) => v
            .split(RegExp(r'[_\s]+'))
            .where((w) => w.isNotEmpty)
            .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
            .join(' '))
        .join(', ');
  }

  // Obx(_content): the observable is read inside _content(), which is CALLED
  // from the closure. Obx(() => SomeWidget(...)) would register nothing —
  // see rule 10 in HANDOFF.md.
  @override
  Widget build(BuildContext context) => Obx(_content);

  Widget _content() {
    final o = c.todayOverview.value;
    final pct = (o?.completionPercentage ?? 0).clamp(0, 100);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          // Circular progress
          SizedBox(
            width: 80.w,
            height: 80.w,
            child: CustomPaint(
              painter: _CircleProgressPainter(progress: pct / 100),
              child: Center(
                child: Text(
                  '$pct%',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 20.w),
          // Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // The fallbacks are the strings this card used to show
                // unconditionally, so a user with no workout today sees what
                // they saw before rather than empty rows.
                _OverviewRow(
                  color: const Color(0xFFFFAB4C),
                  icon: Icons.track_changes,
                  label: 'Goal',
                  value: _fmt(o?.goal, 'Maintain Physique'),
                ),
                SizedBox(height: 12.h),
                _OverviewRow(
                  color: const Color(0xFF5B9BD5),
                  icon: Icons.accessibility_new,
                  label: 'Focus Area',
                  value: _fmt(o?.focusArea, 'Full Body'),
                ),
                SizedBox(height: 12.h),
                _OverviewRow(
                  color: const Color(0xFF72C472),
                  icon: Icons.bolt,
                  label: 'Intensity',
                  value: _fmt(o?.workoutIntensity, 'Medium'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewRow extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final String value;
  const _OverviewRow(
      {required this.color,
      required this.icon,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16.sp),
        ),
        SizedBox(width: 10.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 10.5.sp,
                    color: Colors.black45,
                    fontWeight: FontWeight.w400)),
            Text(value,
                style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}

class _CircleProgressPainter extends CustomPainter {
  final double progress;
  const _CircleProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    final bgPaint = Paint()
      ..color = const Color(0xFFEDEDED)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    final fgPaint = Paint()
      ..color = const Color(0xFFFF6B35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_CircleProgressPainter old) => old.progress != progress;
}
