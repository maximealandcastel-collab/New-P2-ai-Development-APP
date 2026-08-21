import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:pler_to_pler_app/routes/app_routes.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: SingleChildScrollView(
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
              const _TodaysOverviewCard(),
              SizedBox(height: 24.h),
            ],
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
          fontSize: 17.sp,
          fontWeight: FontWeight.w600,
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
        padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${day.day}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
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
class _GymsCard extends StatelessWidget {
  const _GymsCard();

  static const _gyms = [
    (
      'StrongFit Downtown',
      '0.8 km away',
      'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=300&h=160&fit=crop&q=80',
    ),
    (
      'Iron Pulse Gym',
      '1.2 km away',
      'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=300&h=160&fit=crop&q=80',
    ),
    (
      'Core Strength Hub',
      '2.0 km away',
      'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=300&h=160&fit=crop&q=80',
    ),
  ];

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
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black)),
              GestureDetector(
                onTap: () => BottomNavBarController.to.onChange(2),
                child: Text('Near Gym',
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFF6B35))),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 155.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _gyms.length,
              separatorBuilder: (_, __) => SizedBox(width: 12.w),
              itemBuilder: (context, i) {
                final (name, distance, photo) = _gyms[i];
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
                      Text(name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black)),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 12.sp, color: Colors.black54),
                          SizedBox(width: 2.w),
                          Text(distance,
                              style: TextStyle(
                                  fontSize: 11.sp, color: Colors.black54)),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9E9E9E),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text('Disable',
                            style: TextStyle(
                                fontSize: 11.sp, color: Colors.white)),
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
      onTap: () => Get.toNamed(AppRoute.workoutFinderFlow),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        height: 158.h,
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
                      Text('P2P',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          )),
                      Text('AI',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 7.sp,
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                ),
              ),
              // ── Text content ─────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'GENERATE',
                      style: TextStyle(
                        color: const Color(0xFFFF6B35),
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                      ),
                    ),
                    Text(
                      'WORKOUT\nSPLIT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25.sp,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                        letterSpacing: -0.3,
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
                              fontWeight: FontWeight.w700,
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
  const _TodaysOverviewCard();

  @override
  Widget build(BuildContext context) {
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
              painter: _CircleProgressPainter(progress: 0.0),
              child: Center(
                child: Text(
                  '0%',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
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
                _OverviewRow(
                  color: const Color(0xFFFFAB4C),
                  icon: Icons.track_changes,
                  label: 'Goal',
                  value: 'Maintain Physique',
                ),
                SizedBox(height: 12.h),
                _OverviewRow(
                  color: const Color(0xFF5B9BD5),
                  icon: Icons.accessibility_new,
                  label: 'Focus Area',
                  value: 'Full Body',
                ),
                SizedBox(height: 12.h),
                _OverviewRow(
                  color: const Color(0xFF72C472),
                  icon: Icons.bolt,
                  label: 'Intensity',
                  value: 'Medium',
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
                    fontSize: 11.sp,
                    color: Colors.black45,
                    fontWeight: FontWeight.w500)),
            Text(value,
                style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600)),
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
