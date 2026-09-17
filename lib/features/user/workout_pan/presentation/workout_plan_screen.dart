import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:pler_to_pler_app/services/api_urls.dart';
import 'package:pler_to_pler_app/services/network/api_client.dart';
import 'package:pler_to_pler_app/widgets/app_bar.dart';

// ─── Models ───────────────────────────────────────────────────────────────────
class WorkoutItem {
  final String id;
  final String title;
  final String trainer;
  final int minutes;
  final int exerciseSteps;
  final String imageUrl;
  final String status;

  const WorkoutItem({
    required this.id,
    required this.title,
    required this.trainer,
    required this.minutes,
    required this.exerciseSteps,
    required this.imageUrl,
    required this.status,
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
  bool _isLoadingWorkouts = true;
  String? _workoutLoadError;
  final Set<String> _deletingWorkoutIds = <String>{};

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  final List<TaskItem> _tasks = const [
    TaskItem(label: 'Daily pushup', current: 15, total: 20, displayCurrent: '15', displayTotal: '20'),
    TaskItem(label: 'Run 1 km', current: 0.15, total: 1.0, displayCurrent: '0.15 km', displayTotal: '1 km'),
    TaskItem(label: 'Stretch', current: 5, total: 10, displayCurrent: '5 min', displayTotal: '10 min'),
  ];

  final WorkoutItem _assignedWorkout = const WorkoutItem(
    id: '',
    title: '20 Upper Body Exercises',
    trainer: 'Maxime Castel',
    minutes: 20,
    exerciseSteps: 6,
    imageUrl: 'https://images.unsplash.com/photo-1581009137042-c552e485697a?w=400&q=80',
    status: 'assigned',
  );

  final List<WorkoutItem> _savedWorkouts = <WorkoutItem>[];

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  List<Map<String, dynamic>> _mapList(dynamic value) {
    if (value is! List) return const <Map<String, dynamic>>[];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  WorkoutItem? _parseWorkout(Map<String, dynamic> workout) {
    final id = (workout['_id'] ?? workout['id'] ?? '').toString().trim();
    if (id.isEmpty) return null;
    final aiPlan = workout['aiPlan'] is Map
        ? Map<String, dynamic>.from(workout['aiPlan'] as Map)
        : const <String, dynamic>{};
    final trainer = workout['trainerId'] is Map
        ? Map<String, dynamic>.from(workout['trainerId'] as Map)
        : const <String, dynamic>{};
    final goals = workout['goal'] is List
        ? (workout['goal'] as List).map((value) => '$value').toList()
        : const <String>[];
    final focusAreas = workout['focusArea'] is List
        ? (workout['focusArea'] as List).map((value) => '$value').toList()
        : const <String>[];
    final exerciseCount = const ['mainWork', 'accessories', 'finisher']
        .fold<int>(
          0,
          (count, section) =>
              count + (aiPlan[section] is List ? (aiPlan[section] as List).length : 0),
        );
    final rawTitle =
        (aiPlan['title'] ?? aiPlan['programName'] ?? '').toString().trim();
    final fallbackTitle = focusAreas.isNotEmpty
        ? '${focusAreas.first.replaceAll('_', ' ')} workout'
        : goals.isNotEmpty
            ? '${goals.first.replaceAll('_', ' ')} workout'
            : 'Saved workout';

    return WorkoutItem(
      id: id,
      title: rawTitle.isEmpty ? fallbackTitle : rawTitle,
      trainer: (trainer['name'] ?? 'P2P AI Trainer').toString(),
      minutes: (workout['duration'] as num?)?.round() ?? 0,
      exerciseSteps: exerciseCount,
      imageUrl: (trainer['profileImage'] ?? '').toString(),
      status: (workout['status'] ?? 'pending').toString(),
    );
  }

  Future<void> _loadWorkouts() async {
    setState(() {
      _isLoadingWorkouts = true;
      _workoutLoadError = null;
    });
    final response = await ApiClient.getData(ApiUrls.workoutList);
    if (!mounted) return;
    if (response.statusCode != 200 || response.body is! Map) {
      setState(() {
        _isLoadingWorkouts = false;
        _workoutLoadError =
            'Could not load your workouts. Pull back into History to retry.';
      });
      return;
    }
    final body = response.body as Map;
    final parsed = _mapList(body['data'])
        .map(_parseWorkout)
        .whereType<WorkoutItem>()
        .toList();
    setState(() {
      _savedWorkouts
        ..clear()
        ..addAll(parsed);
      _isLoadingWorkouts = false;
    });
  }

  Future<void> _deleteWorkout(WorkoutItem workout) async {
    if (_deletingWorkoutIds.contains(workout.id)) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete workout?'),
        content: const Text(
          'This permanently deletes the workout and cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deletingWorkoutIds.add(workout.id));
    final response = await ApiClient.deleteData(
      ApiUrls.workoutDelete(workout.id),
    );
    if (!mounted) return;
    setState(() => _deletingWorkoutIds.remove(workout.id));
    if (response.statusCode == 200) {
      setState(() {
        _savedWorkouts.removeWhere((item) => item.id == workout.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout permanently deleted.')),
      );
      return;
    }
    final message = response.body is Map
        ? (response.body as Map)['message']?.toString()
        : null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message ?? 'Could not delete this workout.')),
    );
  }

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
                    if (_isLoadingWorkouts)
                      const Center(child: CircularProgressIndicator())
                    else if (_workoutLoadError != null)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: TextButton.icon(
                          onPressed: _loadWorkouts,
                          icon: const Icon(Icons.refresh),
                          label: Text(_workoutLoadError!),
                        ),
                      )
                    else if (_savedWorkouts.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: const Text('No saved workouts yet.'),
                      )
                    else
                      ..._savedWorkouts.map((w) => Padding(
                            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
                            child: _WorkoutCard(
                              item: w,
                              deleting: _deletingWorkoutIds.contains(w.id),
                              onDelete: () => _deleteWorkout(w),
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
  final VoidCallback? onDelete;
  final bool deleting;

  const _WorkoutCard({
    required this.item,
    required this.onTap,
    this.onDelete,
    this.deleting = false,
  });

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

          if (onDelete != null)
            IconButton(
              tooltip: 'Delete workout',
              onPressed: deleting ? null : onDelete,
              icon: deleting
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.close_rounded,
                      size: 20.sp,
                      color: Colors.black45,
                    ),
            )
          else
            Icon(
              Icons.chevron_right_rounded,
              size: 20.sp,
              color: Colors.black26,
            ),
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
