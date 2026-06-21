import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/home/widgets/feed_app_bar.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';


// ─────────────────────────────────────────────────────────────────────────────

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroBanner(),
              SizedBox(height: 20.h),
              _DailyToDoSection(),
              SizedBox(height: 20.h),
              _MotivationCards(),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Hero Banner ─────────────────────────────────────────────────────────────
class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 160.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Stack(
        children: [
          // Background texture / subtle pattern
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: CustomPaint(painter: _DotPatternPainter()),
            ),
          ),

          // Text + button
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Leverage power of ai to find\nworkout that fits your needs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 16.h),
                CustomButton(
                  label: 'Find exercise plan',
                  onPressed: () {
                    Get.toNamed(AppRoute.workoutFinderFlow);
                  },
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  radius: 24,
                ),
              ],
            ),
          ),

          // Athlete image (replace AssetImage with your asset)
          Positioned(
            right: -10.w,
            bottom: 0,
            child: SizedBox(
              height: 155.h,
              child: Image.network(
                'https://i.imgur.com/placeholder.png', // replace with your asset: AssetImage('assets/images/athlete.png')
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => SizedBox(
                  width: 110.w,
                  child: Icon(Icons.directions_run,
                      size: 90.sp, color: Colors.white24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Daily To-Do Section ──────────────────────────────────────────────────────
class _DailyToDoSection extends StatelessWidget {
  final List<_TaskItem> tasks = const [
    _TaskItem(
      label: 'Daily pushup',
      current: 15,
      total: 20,
      unit: '',
      displayCurrent: '15',
      displayTotal: '20',
    ),
    _TaskItem(
      label: 'Run  1 km',
      current: 0.15,
      total: 1.0,
      unit: 'km',
      displayCurrent: '0.15km',
      displayTotal: '1km',
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Daily to do ',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                      ),
                    ),
                    TextSpan(
                      text: '(5/24)',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Task list
          ...tasks.map((t) => _TaskRow(task: t)).toList(),

          SizedBox(height: 12.h),

          // View all button
          GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12.r),
              ),
              alignment: Alignment.center,
              child: Text(
                'View all',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskItem {
  final String label;
  final double current;
  final double total;
  final String unit;
  final String displayCurrent;
  final String displayTotal;

  const _TaskItem({
    required this.label,
    required this.current,
    required this.total,
    required this.unit,
    required this.displayCurrent,
    required this.displayTotal,
  });
}

class _TaskRow extends StatelessWidget {
  final _TaskItem task;

  const _TaskRow({required this.task});

  @override
  Widget build(BuildContext context) {
    final progress = (task.current / task.total).clamp(0.0, 1.0);

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label + value
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                task.label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${task.displayCurrent}/${task.displayTotal}',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7.h,
              backgroundColor: const Color(0xFFEEEEEE),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFFF6B35),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Motivation Cards ─────────────────────────────────────────────────────────
class _MotivationCards extends StatelessWidget {
  final List<_CardData> cards = const [
    _CardData(
      headline: 'Get up.\nMove.\nTransform',
      imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400',
    ),
    _CardData(
      headline: 'Every\nRep\nCounts',
      imageUrl: 'https://images.unsplash.com/photo-1581009137042-c552e485697a?w=400',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: cards
            .map(
              (c) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: c == cards.last ? 0 : 10.w,
              ),
              child: _MotivationCard(data: c),
            ),
          ),
        )
            .toList(),
      ),
    );
  }
}

class _CardData {
  final String headline;
  final String imageUrl;

  const _CardData({required this.headline, required this.imageUrl});
}

class _MotivationCard extends StatelessWidget {
  final _CardData data;

  const _MotivationCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: SizedBox(
        height: 200.h,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.network(
              data.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF1A1A2E),
              ),
            ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.65),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.headline,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18.sp,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _ShareButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.white30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.reply, color: Colors.white, size: 16.sp),
            SizedBox(width: 6.w),
            Text(
              'Share',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Subtle dot pattern painter ───────────────────────────────────────────────
class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 18.0;
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}