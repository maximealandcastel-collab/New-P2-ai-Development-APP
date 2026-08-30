import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:pler_to_pler_app/widgets/app_bar.dart';

// ─── Models ───────────────────────────────────────────────────────────────────
class WorkoutItem {
  final String title;
  final String trainer;
  final int minutes;
  final int exerciseSteps;
  final String imageUrl;

  const WorkoutItem({
    required this.title,
    required this.trainer,
    required this.minutes,
    required this.exerciseSteps,
    required this.imageUrl,
  });
}

class TaskItem {
  final String label;
  final double current;
  final double total;
  final String displayCurrent;
  final String displayTotal;

  const TaskItem({
    required this.label,
    required this.current,
    required this.total,
    required this.displayCurrent,
    required this.displayTotal,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class WorkoutPlansScreen extends StatefulWidget {
  const WorkoutPlansScreen({super.key});

  @override
  State<WorkoutPlansScreen> createState() => _WorkoutPlansScreenState();
}

class _WorkoutPlansScreenState extends State<WorkoutPlansScreen> {
  int _selectedDay = DateTime.now().weekday - 1; // 0 = Mon

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  final List<TaskItem> _tasks = const [
    TaskItem(label: 'Daily pushup', current: 15, total: 20, displayCurrent: '15', displayTotal: '20'),
    TaskItem(label: 'Run 1 km', current: 0.15, total: 1.0, displayCurrent: '0.15 km', displayTotal: '1 km'),
    TaskItem(label: 'Stretch', current: 5, total: 10, displayCurrent: '5 min', displayTotal: '10 min'),
  ];

  final WorkoutItem _assignedWorkout = const WorkoutItem(
    title: '20 Upper Body Exercises',
    trainer: 'Maxime Castel',
    minutes: 20,
    exerciseSteps: 6,
    imageUrl: 'https://images.unsplash.com/photo-1581009137042-c552e485697a?w=400&q=80',
  );

  final List<WorkoutItem> _savedWorkouts = const [
    WorkoutItem(
      title: 'Light Full Body',
      trainer: 'Maxime Castel',
      minutes: 20,
      exerciseSteps: 6,
      imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400&q=80',
    ),
    WorkoutItem(
      title: '20 Upper Body Exercises',
      trainer: 'Maxime Castel',
      minutes: 20,
      exerciseSteps: 6,
      imageUrl: 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=400&q=80',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F6),
      body: SafeArea(
        child: Column(
          children: [
            FeedAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(bottom: 32.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.h),
                    // ── Weekly strip
                    _buildWeekStrip(),
                    SizedBox(height: 16.h),
                    // ── Task progress
                    _buildTaskCard(),
                    SizedBox(height: 20.h),
                    // ── Assigned workout
                    _sectionLabel('Assigned for today'),
                    SizedBox(height: 8.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: _WorkoutCard(
                        item: _assignedWorkout,
                        onTap: () => _showUnavailable(
                          'Starting a workout is not available for this plan yet.',
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    // ── Saved
                    _sectionLabel('Saved workouts'),
                    SizedBox(height: 8.h),
                    ..._savedWorkouts.map((w) => Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
                          child: _WorkoutCard(
                            item: w,
                            onTap: () => _showUnavailable(
                              'Opening saved workout details is not available yet.',
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Week strip — same compact style as home screen ─────────────────────────
  Widget _buildWeekStrip() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_days.length, (i) {
          final isSelected = i == _selectedDay;
          final today = i == DateTime.now().weekday - 1;
          return GestureDetector(
            onTap: () => setState(() => _selectedDay = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 44.w,
              height: 64.h,
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.transparent,
                borderRadius: BorderRadius.circular(10.r),
                border: isSelected
                    ? null
                    : Border.all(
                        color: today
                            ? const Color(0xFFFF6B35).withOpacity(0.5)
                            : Colors.grey.shade200,
                        width: 1,
                      ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _days[i].substring(0, 1),
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white70 : Colors.grey.shade400,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${_dayNumber(i)}',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    width: 4.w,
                    height: 4.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? Colors.white.withOpacity(0.5)
                          : (today ? const Color(0xFFFF6B35) : Colors.transparent),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  int _dayNumber(int weekdayIndex) {
    final now = DateTime.now();
    final currentWeekday = now.weekday - 1;
    final diff = weekdayIndex - currentWeekday;
    return now.day + diff;
  }

  void _showUnavailable(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // ── Task progress card ─────────────────────────────────────────────────────
  Widget _buildTaskCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Progress",
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.black),
          ),
          SizedBox(height: 14.h),
          ..._tasks.map((t) => _TaskRow(task: t)),
          SizedBox(height: 4.h),
          GestureDetector(
            onTap: () => _showUnavailable('All tasks are not available yet.'),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10.r),
              ),
              alignment: Alignment.center,
              child: Text(
                'View all tasks',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Text(
        text,
        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.black87),
      ),
    );
  }
}

// ─── Task row ─────────────────────────────────────────────────────────────────
class _TaskRow extends StatelessWidget {
  final TaskItem task;
  const _TaskRow({required this.task});

  @override
  Widget build(BuildContext context) {
    final progress = (task.current / task.total).clamp(0.0, 1.0);
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(task.label,
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: Colors.black87)),
              Text('${task.displayCurrent} / ${task.displayTotal}',
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade400)),
            ],
          ),
          SizedBox(height: 5.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5.h,
              backgroundColor: const Color(0xFFEEEEEE),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Workout card ─────────────────────────────────────────────────────────────
class _WorkoutCard extends StatelessWidget {
  final WorkoutItem item;
  final VoidCallback onTap;

  const _WorkoutCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
        children: [
          // Thumbnail with fade-in
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              width: 52.w,
              height: 52.w,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 280),
              placeholder: (_, __) => Container(
                width: 52.w,
                height: 52.w,
                color: const Color(0xFFEEEEEE),
              ),
              errorWidget: (_, __, ___) => Container(
                width: 52.w,
                height: 52.w,
                color: const Color(0xFFEEEEEE),
                child: Icon(Icons.fitness_center, color: Colors.grey.shade400, size: 20.sp),
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3.h),
                Text(
                  item.trainer,
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
                ),
                SizedBox(height: 5.h),
                Row(
                  children: [
                    _meta(Icons.timer_outlined, '${item.minutes} min'),
                    SizedBox(width: 10.w),
                    _meta(Icons.repeat_rounded, '${item.exerciseSteps} steps'),
                  ],
                ),
              ],
            ),
          ),

          Icon(Icons.chevron_right_rounded, size: 20.sp, color: Colors.black26),
        ],
        ),
      ),
    );
  }

  Widget _meta(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 11.sp, color: Colors.grey.shade400),
        SizedBox(width: 3.w),
        Text(text, style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade400)),
      ],
    );
  }
}
