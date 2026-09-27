import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/workout_model.dart';
import 'package:share_plus/share_plus.dart';

class WorkoutCompletionSummary {
  const WorkoutCompletionSummary({
    required this.workoutId,
    required this.title,
    required this.durationMinutes,
    required this.completedSets,
    required this.completedExercises,
    this.volumePounds,
  });

  final String workoutId;
  final String title;
  final int durationMinutes;
  final int completedSets;
  final int completedExercises;
  final int? volumePounds;

  factory WorkoutCompletionSummary.fromWorkout(
    WorkoutModel workout, {
    required int fallbackDurationMinutes,
  }) {
    final exercises = <WorkoutExerciseModel>[
      ...?workout.aiPlan?.mainWork,
      ...?workout.aiPlan?.accessories,
      ...?workout.aiPlan?.finisher,
    ];
    final completed = exercises
        .where((exercise) => exercise.isCompleted == true)
        .toList();
    final tracked = completed.isEmpty ? exercises : completed;
    final setCount = tracked.fold<int>(
      0,
      (total, exercise) =>
          total + (exercise.completedSets ?? exercise.sets ?? 0),
    );

    var volume = 0.0;
    var hasVolume = false;
    for (final exercise in tracked) {
      final weight = _singleNumber(exercise.actualWeight);
      final reps = _exactReps(exercise.reps);
      if (weight == null || reps == null) continue;
      hasVolume = true;
      volume += weight * reps * (exercise.completedSets ?? exercise.sets ?? 0);
    }

    final focus = workout.focusArea
        ?.map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .join(' & ');
    return WorkoutCompletionSummary(
      workoutId: workout.id ?? '',
      title: focus == null || focus.isEmpty ? 'Workout' : focus,
      durationMinutes:
          workout.actualDurationMinutes ?? fallbackDurationMinutes,
      completedSets: setCount,
      completedExercises: tracked.length,
      volumePounds: hasVolume ? volume.round() : null,
    );
  }

  static double? _singleNumber(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final match = RegExp(r'^\s*(\d+(?:\.\d+)?)').firstMatch(value);
    return match == null ? null : double.tryParse(match.group(1)!);
  }

  static int? _exactReps(String? value) {
    if (value == null || !RegExp(r'^\s*\d+\s*$').hasMatch(value)) return null;
    return int.tryParse(value.trim());
  }

  String get shareText {
    final parts = <String>[
      'I completed my $title workout with P2P Fit Tech AI.',
      '$durationMinutes min',
      '$completedSets sets',
      '$completedExercises exercises',
      if (volumePounds != null) '$volumePounds lb volume',
    ];
    return parts.join(' • ');
  }
}

class WorkoutCompletionScreen extends StatefulWidget {
  const WorkoutCompletionScreen({super.key, required this.summary});

  final WorkoutCompletionSummary summary;

  @override
  State<WorkoutCompletionScreen> createState() =>
      _WorkoutCompletionScreenState();
}

class _WorkoutCompletionScreenState extends State<WorkoutCompletionScreen> {
  XFile? _photo;

  Color get _orange => Theme.of(context).colorScheme.primary;

  Future<void> _takePhoto() async {
    final photo = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 88,
      maxWidth: 1800,
    );
    if (photo != null && mounted) setState(() => _photo = photo);
  }

  Future<void> _share() async {
    await SharePlus.instance.share(
      ShareParams(
        text: widget.summary.shareText,
        files: _photo == null ? const [] : <XFile>[_photo!],
        subject: 'Workout complete',
      ),
    );
  }

  void _finishPrivate() {
    if (Get.isRegistered<BottomNavBarController>()) {
      BottomNavBarController.to.resetIndex();
    }
    Get.offAllNamed(AppRoute.bottonNavBar);
  }

  Future<void> _openProfile() async {
    if (Get.isRegistered<ProfileController>()) {
      await ProfileController.to.refresh();
    }
    Get.offAllNamed(AppRoute.bottonNavBar);
    Get.toNamed(AppRoute.userProfileScreen);
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    final metrics = <_CompletionMetric>[
      if (summary.volumePounds != null)
        _CompletionMetric(
          icon: Icons.fitness_center_rounded,
          value: _withCommas(summary.volumePounds!),
          unit: 'lb',
          label: 'Volume',
        ),
      _CompletionMetric(
        icon: Icons.timer_outlined,
        value: '${summary.durationMinutes}',
        unit: 'min',
        label: 'Time',
      ),
      _CompletionMetric(
        icon: Icons.layers_outlined,
        value: '${summary.completedSets}',
        unit: '',
        label: 'Sets',
      ),
    ];

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8F9),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 28.h),
            children: [
              Row(
                children: [
                  Image.asset('assets/images/app_logo.png', height: 42.h),
                  const Spacer(),
                  IconButton.filledTonal(
                    onPressed: _finishPrivate,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              SizedBox(height: 28.h),
              Text(
                'WORKOUT',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.sp,
                  letterSpacing: 4,
                  color: const Color(0xFF77777F),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Complete',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34.sp,
                  height: 1,
                  color: const Color(0xFF17171B),
                  fontWeight: AppFontWeight.section,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '${summary.title} is saved to your workout history.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF73737B),
                ),
              ),
              SizedBox(height: 24.h),
              Container(
                padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D1D21),
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: _orange.withValues(alpha: .13),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    for (var i = 0; i < metrics.length; i++) ...[
                      if (i > 0)
                        Container(
                          height: 58.h,
                          width: 1,
                          color: Colors.white.withValues(alpha: .12),
                        ),
                      Expanded(child: _MetricTile(metric: metrics[i], orange: _orange)),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 14.h),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                child: InkWell(
                  onTap: _takePhoto,
                  borderRadius: BorderRadius.circular(20.r),
                  child: Container(
                    height: 126.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: const Color(0xFFE7E7EA)),
                      image: _photo == null
                          ? null
                          : DecorationImage(
                              image: FileImage(File(_photo!.path)),
                              fit: BoxFit.cover,
                            ),
                    ),
                    child: _photo == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 44.r,
                                height: 44.r,
                                decoration: BoxDecoration(
                                  color: _orange.withValues(alpha: .1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.camera_alt_outlined, color: _orange),
                              ),
                              SizedBox(height: 8.h),
                              Text('Add a finish photo', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
                            ],
                          )
                        : Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: EdgeInsets.all(9.r),
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                child: Icon(Icons.camera_alt_outlined, color: Colors.white, size: 18.sp),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: const Color(0xFFE8E8EB)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42.r,
                      height: 42.r,
                      decoration: BoxDecoration(
                        color: _orange.withValues(alpha: .1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.insights_rounded, color: _orange),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your result is real', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                          SizedBox(height: 3.h),
                          Text(
                            'Only metrics logged during this workout are shown. Your completed-workout count updates automatically.',
                            style: TextStyle(fontSize: 10.sp, height: 1.35, color: const Color(0xFF707078)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 22.h),
              FilledButton.icon(
                onPressed: _share,
                icon: const Icon(Icons.ios_share_rounded),
                label: const Text('Share Progress'),
                style: FilledButton.styleFrom(
                  backgroundColor: _orange,
                  foregroundColor: Colors.white,
                  minimumSize: Size.fromHeight(54.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
                  textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openProfile,
                      icon: const Icon(Icons.person_outline_rounded),
                      label: const Text('View Profile'),
                      style: _secondaryButtonStyle(),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _finishPrivate,
                      icon: const Icon(Icons.lock_outline_rounded),
                      label: const Text('Keep Private'),
                      style: _secondaryButtonStyle(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  ButtonStyle _secondaryButtonStyle() => OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF333338),
        minimumSize: Size.fromHeight(48.h),
        side: const BorderSide(color: Color(0xFFDCDCE0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        textStyle: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600),
      );

  static String _withCommas(int value) {
    final digits = value.toString();
    return digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
  }
}

class _CompletionMetric {
  const _CompletionMetric({required this.icon, required this.value, required this.unit, required this.label});
  final IconData icon;
  final String value;
  final String unit;
  final String label;
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.metric, required this.orange});
  final _CompletionMetric metric;
  final Color orange;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(metric.icon, color: orange, size: 22.sp),
          SizedBox(height: 8.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: metric.value, style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: AppFontWeight.section)),
                  if (metric.unit.isNotEmpty)
                    TextSpan(text: ' ${metric.unit}', style: TextStyle(color: Colors.white70, fontSize: 10.sp, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text(metric.label.toUpperCase(), style: TextStyle(color: Colors.white54, fontSize: 8.sp, letterSpacing: 1.2)),
        ],
      );
}
