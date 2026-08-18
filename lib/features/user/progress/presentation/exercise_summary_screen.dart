import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math';

import 'package:pler_to_pler_app/widgets/app_bar.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class ExerciseSummaryScreen extends StatefulWidget {
  const ExerciseSummaryScreen({super.key});

  @override
  State<ExerciseSummaryScreen> createState() => _ExerciseSummaryScreenState();
}

class _ExerciseSummaryScreenState extends State<ExerciseSummaryScreen> {
  int _activityTab = 0; // 0 = Activity, 1 = Upcoming

  final List<_BarData> _weekData = const [
    _BarData(day: 'Sun', value: 0.35),
    _BarData(day: 'Mon', value: 0.45),
    _BarData(day: 'Mon', value: 1.0, isHighlighted: true, label: '45 min'),
    _BarData(day: 'Wed', value: 0.40),
    _BarData(day: 'Thu', value: 0.30),
    _BarData(day: 'Tue', value: 0.25),
    _BarData(day: 'Sun', value: 0.20),
  ];

  final List<_ActivityItem> _activities = const [
    _ActivityItem(
      title: 'Daily running',
      date: 'Mar 14, 2026 · 2:30 PM',
      status: _ActivityStatus.completed,
    ),
    _ActivityItem(
      title: 'Meditation',
      date: 'Aug 19, 2024 · 9:15 AM',
      status: _ActivityStatus.missed,
    ),
    _ActivityItem(
      title: 'Daily running',
      date: 'Dec 1, 2023 · 11:45 AM',
      status: _ActivityStatus.completed,
    ),
    _ActivityItem(
      title: 'Meditation',
      date: 'Nov 20, 2023 · 8:00 AM',
      status: _ActivityStatus.missed,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 30.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App bar
              FeedAppBar(),
              SizedBox(height: 20.h),

              // Exercise summary card
              _ExerciseSummaryCard(weekData: _weekData),
              SizedBox(height: 16.h),

              // Stats row
              _StatsRow(),
              SizedBox(height: 16.h),

              // Calories intake card
              _CaloriesIntakeCard(),
              SizedBox(height: 16.h),

              // Activity / Upcoming tabs + list
              _ActivitySection(
                selectedTab: _activityTab,
                onTabChanged: (i) => setState(() => _activityTab = i),
                activities: _activities,
              ),
              SizedBox(height: 50.h,)
            ],
          ),
        ),
      ),
    );
  }
}


// ─── Exercise Summary Card ────────────────────────────────────────────────────
class _BarData {
  final String day;
  final double value; // 0.0 - 1.0
  final bool isHighlighted;
  final String? label;

  const _BarData({
    required this.day,
    required this.value,
    this.isHighlighted = false,
    this.label,
  });
}

class _ExerciseSummaryCard extends StatelessWidget {
  final List<_BarData> weekData;

  const _ExerciseSummaryCard({required this.weekData});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Exercise summary',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
              Row(
                children: [
                  _IconBtn(icon: Icons.bar_chart, active: true),
                  SizedBox(width: 6.w),
                  _IconBtn(icon: Icons.calendar_today_outlined, active: false),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // Duration + trend
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('45min',
                  style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w800, color: Colors.black)),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.arrow_upward, size: 13.sp, color: const Color(0xFF4CAF50)),
                      Text('5.3%',
                          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF4CAF50), fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Text('Total Exercised this weak',
                      style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade400)),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Bar chart
          SizedBox(
            // height: 110.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: weekData.map((d) => _Bar(data: d)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final _BarData data;

  const _Bar({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxHeight = 80.h;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (data.label != null) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(data.label!,
                  style: TextStyle(fontSize: 9.sp, color: Colors.white, fontWeight: FontWeight.w600)),
            ),
            SizedBox(height: 4.h),
          ],
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 28.w,
            height: maxHeight * data.value,
            decoration: BoxDecoration(
              color: data.isHighlighted ? const Color(0xFFFF7A00) : const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          SizedBox(height: 6.h),
          Text(data.day,
              style: TextStyle(
                fontSize: 10.sp,
                color: data.isHighlighted ? Colors.black : Colors.grey.shade400,
                fontWeight: data.isHighlighted ? FontWeight.w600 : FontWeight.w400,
              )),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final bool active;

  const _IconBtn({required this.icon, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32.w, height: 32.h,
      decoration: BoxDecoration(
        color: active ? Colors.black : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(icon, size: 16.sp, color: active ? Colors.white : Colors.black54),
    );
  }
}

// ─── Stats Row ────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          _StatCard(
            icon: Icons.fitness_center,
            iconColor: const Color(0xFF4CAF50),
            label: 'Workout\nConsistency',
            value: '87%',
          ),
          SizedBox(width: 10.w),
          _StatCard(
            icon: Icons.local_fire_department,
            iconColor: const Color(0xFFFF7A00),
            label: 'Calories\nBurned',
            value: '3,240 kcal',
            valueSize: 16,
          ),
          SizedBox(width: 10.w),
          _StatCard(
            icon: Icons.directions_run,
            iconColor: const Color(0xFF2196F3),
            label: 'Exercise\nduration',
            value: '450 min',
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final double valueSize;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22.sp, color: iconColor),
            SizedBox(height: 8.h),
            Text(label,
                style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500, height: 1.4)),
            SizedBox(height: 6.h),
            Text(value,
                style: TextStyle(
                  fontSize: valueSize.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                )),
          ],
        ),
      ),
    );
  }
}

// ─── Calories Intake Card ─────────────────────────────────────────────────────
class _CaloriesIntakeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Calories intake',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400)),
          SizedBox(height: 6.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('1450/2470',
                  style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w800, color: Colors.black)),
              const Spacer(),
              // Donut chart
              _DonutChart(progress: 1450 / 2470),
            ],
          ),
          SizedBox(height: 16.h),

          // Macros
          _MacroRow(emoji: '🥩', label: 'Protein', value: '78/193g', color: const Color(0xFFFF5252)),
          SizedBox(height: 10.h),
          _MacroRow(emoji: '🥕', label: 'Carbs', value: '67/315g', color: const Color(0xFFFFB300)),
          SizedBox(height: 10.h),
          _MacroRow(emoji: '🥑', label: 'Fat', value: '24/75g', color: const Color(0xFFB0BEC5)),
        ],
      ),
    );
  }
}

class _DonutChart extends StatelessWidget {
  final double progress;

  const _DonutChart({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52.w,
      height: 52.w,
      child: CustomPaint(
        painter: _DonutPainter(progress: progress),
        child: Center(
          child: Icon(Icons.local_fire_department, size: 20.sp, color: const Color(0xFFFF7A00)),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double progress;

  _DonutPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;
    const strokeWidth = 6.0;

    // Track
    canvas.drawCircle(
      center, radius,
      Paint()
        ..color = const Color(0xFFEEEEEE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Progress arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * progress,
      false,
      Paint()
        ..color = const Color(0xFFFF7A00)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.progress != progress;
}

class _MacroRow extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;

  const _MacroRow({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: TextStyle(fontSize: 16.sp)),
        SizedBox(width: 8.w),
        Text(label, style: TextStyle(fontSize: 13.sp, color: Colors.black87, fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 13.sp, color: Colors.black54, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ─── Activity Section ─────────────────────────────────────────────────────────
enum _ActivityStatus { completed, missed }

class _ActivityItem {
  final String title;
  final String date;
  final _ActivityStatus status;

  const _ActivityItem({required this.title, required this.date, required this.status});
}

class _ActivitySection extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChanged;
  final List<_ActivityItem> activities;

  const _ActivitySection({
    required this.selectedTab,
    required this.onTabChanged,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          // Tab switcher
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
            ),
            child: Row(
              children: ['Activity', 'Upcoming'].asMap().entries.map((e) {
                final isSelected = e.key == selectedTab;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTabChanged(e.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black : Colors.transparent,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        e.value,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 12.h),

          // Activity list
          ...activities.map((a) => _ActivityTile(item: a)),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final _ActivityItem item;

  const _ActivityTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isCompleted = item.status == _ActivityStatus.completed;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black)),
                SizedBox(height: 4.h),
                Text(item.date,
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade400)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: isCompleted ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.cancel,
                  size: 13.sp,
                  color: isCompleted ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
                ),
                SizedBox(width: 4.w),
                Text(
                  isCompleted ? 'Completed' : 'Missed',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
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
