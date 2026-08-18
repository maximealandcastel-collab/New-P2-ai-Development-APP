import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import 'package:pler_to_pler_app/custom_assets/assets.gen.dart';
import 'package:pler_to_pler_app/features/common/notification/presentation/screen/notification_screen.dart';
import 'package:pler_to_pler_app/features/profile/profile_screen.dart';
import 'package:pler_to_pler_app/widgets/app_bar.dart';
import 'package:pler_to_pler_app/widgets/custom_app_bar.dart';
import 'package:pler_to_pler_app/widgets/custom_container.dart';
import 'package:pler_to_pler_app/widgets/custom_image_avatar.dart';
import 'package:pler_to_pler_app/widgets/custom_text.dart';

// ─── Model ────────────────────────────────────────────────────────────────────
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
  int _selectedTab = 0; // 0 = Workout plans, 1 = Meal plans
  int _selectedDay = 2; // Wed = index 2

  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<IconData> _dayIcons = [
    Icons.directions_walk,
    Icons.directions_run,
    Icons.self_improvement,
    Icons.directions_walk,
    Icons.mail_outline,
    Icons.directions_run,
    Icons.directions_walk,
  ];

  final List<TaskItem> _tasks = const [
    TaskItem(
      label: 'Daily pushup',
      current: 15, total: 20,
      displayCurrent: '15', displayTotal: '20',
    ),
    TaskItem(
      label: 'Run  1 km',
      current: 0.15, total: 1.0,
      displayCurrent: '0.15km', displayTotal: '1km',
    ),
    TaskItem(
      label: 'Run  1 km',
      current: 0.15, total: 1.0,
      displayCurrent: '0.15km', displayTotal: '1km',
    ),
  ];

  final WorkoutItem _assignedWorkout = const WorkoutItem(
    title: '20 upper body exercise',
    trainer: 'Maxime Castel',
    minutes: 20,
    exerciseSteps: 6,
    imageUrl: 'https://images.unsplash.com/photo-1581009137042-c552e485697a?w=200',
  );

  final List<WorkoutItem> _savedWorkouts = const [
    WorkoutItem(
      title: 'Light full body exercise',
      trainer: 'Maxime Castel',
      minutes: 20,
      exerciseSteps: 6,
      imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=200',
    ),
    WorkoutItem(
      title: '20 upper body exercise',
      trainer: 'Maxime Castel',
      minutes: 20,
      exerciseSteps: 6,
      imageUrl: 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=200',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            FeedAppBar(),
            // ── Tab switcher
            _TabSwitcher(
              selected: _selectedTab,
              onChanged: (i) => setState(() => _selectedTab = i),
            ),
            // ── Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    // Weekly schedule card
                    _WeeklyScheduleCard(
                      days: _days,
                      icons: _dayIcons,
                      selectedDay: _selectedDay,
                      onDaySelected: (i) => setState(() => _selectedDay = i),
                      tasks: _tasks,
                    ),
                    SizedBox(height: 24.h),
                    // Assigned workout
                    _SectionHeader(title: 'Assigned workout for the day'),
                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: _WorkoutCard(item: _assignedWorkout),
                    ),
                    SizedBox(height: 24.h),
                    // Saved workouts
                    _SectionHeader(title: 'Saved workouts'),
                    SizedBox(height: 10.h),
                    ..._savedWorkouts.map(
                          (w) => Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
                        child: _WorkoutCard(item: w),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tab Switcher ─────────────────────────────────────────────────────────────
class _TabSwitcher extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _TabSwitcher({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          _TabItem(
            icon: Icons.fitness_center,
            label: 'Workout plans',
            isSelected: selected == 0,
            onTap: () => onChanged(0),
          ),
          // _TabItem(
          //   icon: Icons.restaurant_menu,
          //   label: 'Meal plans',
          //   isSelected: selected == 1,
          //   onTap: () => onChanged(1),
          // ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18.sp,
                color: isSelected ? Colors.white : Colors.black54,
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Weekly Schedule Card ─────────────────────────────────────────────────────
class _WeeklyScheduleCard extends StatelessWidget {
  final List<String> days;
  final List<IconData> icons;
  final int selectedDay;
  final ValueChanged<int> onDaySelected;
  final List<TaskItem> tasks;

  const _WeeklyScheduleCard({
    required this.days,
    required this.icons,
    required this.selectedDay,
    required this.onDaySelected,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Scheduled to do',
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.black),
          ),
          SizedBox(height: 14.h),

          // Day row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(days.length, (i) {
              final isSelected = i == selectedDay;
              return GestureDetector(
                onTap: () => onDaySelected(i),
                child: Column(
                  children: [
                    Text(
                      days[i],
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.black : Colors.grey,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black : const Color(0xFFF5F5F5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icons[i],
                        size: 18.sp,
                        color: isSelected ? Colors.white : Colors.black54,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),

          SizedBox(height: 18.h),

          // Tasks
          ...tasks.map((t) => _TaskProgressRow(task: t)),

          SizedBox(height: 8.h),

          // View all
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
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskProgressRow extends StatelessWidget {
  final TaskItem task;

  const _TaskProgressRow({required this.task});

  @override
  Widget build(BuildContext context) {
    final progress = (task.current / task.total).clamp(0.0, 1.0);

    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                task.label,
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
              Text(
                '${task.displayCurrent}/${task.displayTotal}',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
              ),
            ],
          ),
          SizedBox(height: 7.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6.h,
              backgroundColor: const Color(0xFFEEEEEE),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF7A00)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );
  }
}

// ─── Workout Card ─────────────────────────────────────────────────────────────
class _WorkoutCard extends StatelessWidget {
  final WorkoutItem item;

  const _WorkoutCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Image.network(
              item.imageUrl,
              width: 58.w,
              height: 58.h,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 58.w,
                height: 58.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.fitness_center, color: Colors.grey.shade400, size: 24.sp),
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
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Trainer ${item.trainer}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
                ),
                SizedBox(height: 5.h),
                Row(
                  children: [
                    _MetaText('${item.minutes} minutes'),
                    _MetaDot(),
                    _MetaText('${item.exerciseSteps} Exercise step'),
                  ],
                ),
              ],
            ),
          ),

          Icon(Icons.more_vert, size: 20.sp, color: Colors.black38),
        ],
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  final String text;
  const _MetaText(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
  );
}

class _MetaDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 5.w),
    child: Container(
      width: 3.w,
      height: 3.w,
      decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
    ),
  );
}