import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/user/achievements/data/achievement_service.dart';
import 'package:pler_to_pler_app/features/user/achievements/presentation/compact_achievement_sheet.dart';
import 'package:pler_to_pler_app/features/user/contents/presentations/feed_screen.dart';
import 'package:pler_to_pler_app/services/api_urls.dart';
import 'package:pler_to_pler_app/services/logger.dart';
import 'package:pler_to_pler_app/services/network/api_client.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// AI PLAN RESULT — shown after "Finding best workout plan for you"
// Orange header → Warm up → Main Work (expandable exercise cards) → Cool down →
// Nutrition Tip → This Week Focus → duration/check-in → Watch Video → Session Start
// TODO(backend): populate from the AI plan generation response (POST /workout/plan).
// ═══════════════════════════════════════════════════════════════════════════════

class PlanExercise {
  final String name;
  final String muscleGroup;
  final String sets;
  final String reps;
  final String rest;
  final String rpe;
  final List<PlanStep> steps;

  const PlanExercise({
    required this.name,
    required this.muscleGroup,
    required this.sets,
    required this.reps,
    required this.rest,
    required this.rpe,
    required this.steps,
  });
}

class PlanStep {
  final String instruction;
  final String tip;

  const PlanStep({required this.instruction, required this.tip});
}

class WorkoutPhaseStep {
  final String instruction;
  final String duration;

  const WorkoutPhaseStep({
    required this.instruction,
    required this.duration,
  });
}

class AiPlanResultScreen extends StatefulWidget {
  const AiPlanResultScreen({super.key});

  @override
  State<AiPlanResultScreen> createState() => _AiPlanResultScreenState();
}

class _AiPlanResultScreenState extends State<AiPlanResultScreen> {
  static final _resultLog = logger(AiPlanResultScreen);
  static final Set<String> _reportedTraceIds = <String>{};
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showPendingUnlocks());
  }

  Future<void> _showPendingUnlocks() async {
    final pending = await AchievementService.getPending();
    if (!mounted || pending.isEmpty) return;
    await CompactAchievementPresenter.showQueue(context, pending);
  }

  Future<void> _completeWorkout(
    Map<String, dynamic>? response,
    Map<String, dynamic>? program,
  ) async {
    if (_isCompleting) return;
    final workoutId = response?['workoutId']?.toString().trim() ?? '';
    if (workoutId.isEmpty) {
      Get.snackbar(
        'Workout not ready',
        'This workout is missing its completion ID. Please reopen it and try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isCompleting = true);
    try {
      final duration =
          (program?['estimatedSessionMinutes'] as num?)?.toInt() ?? 30;
      final completion = await ApiClient.postData(
        ApiUrls.workoutComplete(workoutId),
        {
          'checkInResponse': 'Workout completed in the P2P app.',
          'actualDurationMinutes': duration,
        },
      );
      if (completion.statusCode != 200 || completion.body is! Map) {
        final body = completion.body is Map ? completion.body as Map : null;
        throw Exception(
          body?['message']?.toString() ??
              completion.statusText ??
              'Could not complete this workout.',
        );
      }

      final data = (completion.body as Map)['data'];
      final newlyUnlocked = data is Map
          ? AchievementService.parseUnlocks(data['newlyUnlocked'])
          : const [];
      if (!mounted) return;

      if (newlyUnlocked.isNotEmpty) {
        await CompactAchievementPresenter.showQueue(context, newlyUnlocked);
      } else {
        Get.snackbar(
          'Workout complete',
          'Great work. Your progress has been saved.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
      if (mounted) Get.back(result: const {'workoutCompleted': true});
    } catch (error) {
      if (!mounted) return;
      Get.snackbar(
        'Could not complete workout',
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _isCompleting = false);
    }
  }

  /// Parse exercises from the backend AI plan. Older plans may omit optional
  /// sections, so those sections stay empty instead of showing fake content.
  static List<PlanExercise> _parseExercises(dynamic raw) {
    if (raw is! List || raw.isEmpty) return const [];
    return raw.whereType<Map>().map((e) {
      final steps = (e['steps'] is List)
          ? (e['steps'] as List).whereType<Map>().map((s) {
              return PlanStep(
                instruction: (s['instruction'] ?? s['text'] ?? '').toString(),
                tip: (s['tip'] ?? s['tips'] ?? '').toString(),
              );
            }).toList()
          : <PlanStep>[];
      return PlanExercise(
        name: (e['exerciseName'] ?? e['name'] ?? 'Exercise').toString(),
        muscleGroup: (e['muscleGroup'] ?? '').toString(),
        sets: '${e['sets'] ?? 3} sets',
        reps: '${e['reps'] ?? '8-12'} reps',
        rest: 'Rest ${e['restTime'] ?? '60s'}',
        rpe: e['rpe'] != null ? 'RPE ${e['rpe']}' : 'RPE 7-8',
        steps: steps,
      );
    }).toList();
  }

  static List<PlanExercise> _parseMainWork(Map<String, dynamic>? plan) {
    return _parseExercises(plan?['mainWork']);
  }

  static List<WorkoutPhaseStep> _parsePhaseSteps(
    dynamic raw, {
    required List<WorkoutPhaseStep> fallback,
  }) {
    if (raw is! List || raw.isEmpty) return fallback;
    final parsed = raw.whereType<Map>().map((step) {
      return WorkoutPhaseStep(
        instruction: (step['instruction'] ?? step['text'] ?? '').toString(),
        duration: (step['duration'] ?? '').toString(),
      );
    }).where((step) => step.instruction.trim().isNotEmpty).toList();
    return parsed.isEmpty ? fallback : parsed;
  }

  static Widget _exerciseList(List<PlanExercise> exercises) {
    return Column(
      children: [
        for (int i = 0; i < exercises.length; i++) ...[
          _ExerciseCard(exercise: exercises[i]),
          if (i != exercises.length - 1) SizedBox(height: 14.h),
        ],
      ],
    );
  }

  static Widget _phaseStepList(List<WorkoutPhaseStep> steps) {
    return Column(
      children: [
        for (int i = 0; i < steps.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == steps.length - 1 ? 0 : 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 25.w,
                  height: 25.w,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDEBD9),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      color: const Color(0xFFF57C1F),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        steps[i].instruction,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                      if (steps[i].duration.trim().isNotEmpty) ...[
                        SizedBox(height: 3.h),
                        Text(
                          steps[i].duration,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static List<WorkoutPhaseStep> _fallbackWarmUp() {
    return const [
      WorkoutPhaseStep(
        instruction: 'Easy cardio to raise your temperature',
        duration: '3 minutes',
      ),
      WorkoutPhaseStep(
        instruction: 'Dynamic mobility for the joints and muscles you will train',
        duration: '2 minutes',
      ),
      WorkoutPhaseStep(
        instruction: 'One light rehearsal set of the first movement',
        duration: '1 minute',
      ),
    ];
  }

  static List<WorkoutPhaseStep> _fallbackCoolDown() {
    return const [
      WorkoutPhaseStep(
        instruction: 'Slow breathing and an easy walk to bring your heart rate down',
        duration: '2 minutes',
      ),
      WorkoutPhaseStep(
        instruction: 'Gentle static stretches for the trained muscle groups',
        duration: '3 minutes',
      ),
      WorkoutPhaseStep(
        instruction: 'Drink water and note any discomfort before leaving',
        duration: '1 minute',
      ),
    ];
  }

  static List<PlanExercise> _parseOptionalExercises(dynamic raw) {
    return _parseExercises(raw);
  }

  @override
  Widget build(BuildContext context) {
    final response = Get.arguments is Map<String, dynamic>
        ? Get.arguments as Map<String, dynamic>
        : null;
    final plan = response?['aiPlan'] is Map
        ? Map<String, dynamic>.from(response!['aiPlan'] as Map)
        : response;
    final program = response?['program'] is Map
        ? Map<String, dynamic>.from(response!['program'] as Map)
        : response?['weeklyProgram'] is Map
            ? Map<String, dynamic>.from(response!['weeklyProgram'] as Map)
            : null;
    final selectedSplit = response?['selectedSplit'] is Map
        ? Map<String, dynamic>.from(response!['selectedSplit'] as Map)
        : null;
    final programWorkouts = program?['workouts'] is List
        ? (program!['workouts'] as List)
            .whereType<Map>()
            .map((day) => Map<String, dynamic>.from(day))
            .toList()
        : <Map<String, dynamic>>[];
    final traceId = response?['_workoutTraceId']?.toString() ?? '';
    final hasRenderableProgram = program != null &&
        programWorkouts.isNotEmpty &&
        programWorkouts.every((day) {
          final exercises = day['exercises'];
          return exercises is List && exercises.isNotEmpty;
        });
    if (!hasRenderableProgram) {
      _resultLog.e('[WORKOUT_GENERATION][render_rejected] ${{
        if (traceId.isNotEmpty) 'traceId': traceId,
        'reason': 'program_missing_or_empty',
        'workoutCount': programWorkouts.length,
      }}');
      return const _InvalidProgramScreen();
    }
    if (traceId.isNotEmpty && _reportedTraceIds.add(traceId)) {
      _resultLog.i('[WORKOUT_GENERATION][render_started] ${{
        'traceId': traceId,
        'workoutCount': programWorkouts.length,
      }}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _resultLog.i('[WORKOUT_GENERATION][render_completed] ${{
          'traceId': traceId,
          'workoutCount': programWorkouts.length,
        }}');
      });
    }
    final mainWork = _parseMainWork(plan);
    final accessories = _parseOptionalExercises(plan?['accessories']);
    final finisher = _parseOptionalExercises(plan?['finisher']);
    final warmUp = _parsePhaseSteps(
      plan?['warmUp'],
      fallback: _fallbackWarmUp(),
    );
    final coolDown = _parsePhaseSteps(
      plan?['coolDown'],
      fallback: _fallbackCoolDown(),
    );
    final focusList = (plan?['thisWeekFocus'] is List)
        ? (plan!['thisWeekFocus'] as List).map((e) => e.toString()).toList()
        : const ['Chest'];
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PlanHeader(
                      date: dateStr,
                      title: (program?['name'] ?? 'Your Workout Plan').toString(),
                      subtitle: (plan?['coachNote'] as String?) ??
                          "Your trainer built today's session around your focus.",
                    ),
                    if (program != null) ...[
                      SizedBox(height: 16.h),
                      _ProgramOverviewCard(
                        splitName:
                            (selectedSplit?['name'] ?? program['name']).toString(),
                        schedule: program['weeklySchedule'] is List
                            ? (program['weeklySchedule'] as List)
                                .map((day) => day.toString())
                                .toList()
                            : const [],
                        daysPerWeek:
                            (program['daysPerWeek'] as num?)?.toInt() ??
                                programWorkouts.length,
                        duration:
                            (program['estimatedSessionMinutes'] as num?)?.toInt() ??
                                30,
                        goal: (program['goal'] ?? '').toString(),
                        experience:
                            (program['experienceLevel'] ?? '').toString(),
                      ),
                      for (final day in programWorkouts) ...[
                        SizedBox(height: 16.h),
                        _ProgramDayCard(
                          day: (day['day'] as num?)?.toInt() ?? 1,
                          title: (day['title'] ?? 'Workout').toString(),
                          muscleGroups: day['muscleGroups'] is List
                              ? (day['muscleGroups'] as List)
                                  .map((item) => item.toString())
                                  .toList()
                              : const [],
                          duration:
                              (day['estimatedDurationMinutes'] as num?)?.toInt() ??
                                  30,
                          exercises: _parseExercises(day['exercises']),
                          warmUp: _parsePhaseSteps(
                            day['warmUp'],
                            fallback: _fallbackWarmUp(),
                          ),
                          coolDown: _parsePhaseSteps(
                            day['coolDown'],
                            fallback: _fallbackCoolDown(),
                          ),
                          cardioGuidance:
                              (day['cardioGuidance'] ?? '').toString(),
                        ),
                      ],
                      SizedBox(height: 16.h),
                      _ProgramGuidanceCard(
                        progression:
                            (program['progression'] is Map
                                    ? program['progression']['guidance']
                                    : null)
                                ?.toString() ??
                            '',
                        recovery:
                            (program['recovery'] is Map
                                    ? program['recovery']['guidance']
                                    : null)
                                ?.toString() ??
                            '',
                        cardio:
                            (program['cardio'] is Map
                                    ? program['cardio']['guidance']
                                    : null)
                                ?.toString() ??
                            '',
                      ),
                    ],
                    SizedBox(height: 16.h),
                    _SectionCard(
                      title: program == null ? 'Warm up' : 'Start Day 1 — Warm up',
                      child: _phaseStepList(warmUp),
                    ),
                    SizedBox(height: 16.h),
                    _SectionCard(
                      title: 'Main Work',
                      child: _exerciseList(mainWork),
                    ),
                    if (accessories.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      _SectionCard(
                        title: 'Accessories',
                        child: _exerciseList(accessories),
                      ),
                    ],
                    if (finisher.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      _SectionCard(
                        title: 'Finisher',
                        child: _exerciseList(finisher),
                      ),
                    ],
                    SizedBox(height: 16.h),
                    _SectionCard(
                      title: 'Cool down',
                      child: _phaseStepList(coolDown),
                    ),
                    SizedBox(height: 16.h),
                    _InfoCard(
                      title: 'Nutrition Tip',
                      body: (plan?['nutritionTip'] as String?) ??
                          'Stay hydrated and spread protein evenly across meals to support recovery.',
                    ),
                    SizedBox(height: 16.h),
                    _WeekFocusCard(focus: focusList.join(', ')),
                    SizedBox(height: 16.h),
                    _CheckInCard(
                      duration:
                          (plan?['estimatedDurationMinutes'] as num?)?.toInt() ??
                              20,
                      question: (plan?['checkInQuestion'] as String?) ??
                          "Did you complete today's session? What loads did you use and how hard was it (RPE 1-10)? Any pain or equipment issues?",
                    ),
                    SizedBox(height: 20.h),
                    _WatchVideoButton(onTap: () {
                      Get.to(() => const FeedScreen());
                    }),
                  ],
                ),
              ),
            ),
            // ── Sticky Workout Completion ──
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
              child: SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
                  onPressed: _isCompleting
                      ? null
                      : () => _completeWorkout(response, program),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF57C1F),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                  ),
                  child: _isCompleting
                      ? SizedBox(
                          width: 22.w,
                          height: 22.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Complete Workout',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvalidProgramScreen extends StatelessWidget {
  const _InvalidProgramScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  color: const Color(0xFFF57C1F),
                  size: 44.sp,
                ),
                SizedBox(height: 14.h),
                Text(
                  'Your workout could not be displayed',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'The workout service returned an empty or incomplete plan. '
                  'Please go back and try generating it again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.4,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 20.h),
                FilledButton(
                  onPressed: () => Get.back(),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFF57C1F),
                  ),
                  child: const Text('Go back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgramOverviewCard extends StatelessWidget {
  final String splitName;
  final List<String> schedule;
  final int daysPerWeek;
  final int duration;
  final String goal;
  final String experience;

  const _ProgramOverviewCard({
    required this.splitName,
    required this.schedule,
    required this.daysPerWeek,
    required this.duration,
    required this.goal,
    required this.experience,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Split',
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFFF57C1F),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            splitName,
            style: TextStyle(
              fontSize: 20.sp,
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _Chip('$daysPerWeek days/week'),
              _Chip('$duration min/session'),
              if (experience.trim().isNotEmpty) _Chip(experience),
              if (goal.trim().isNotEmpty) _Chip(goal),
            ],
          ),
          if (schedule.isNotEmpty) ...[
            SizedBox(height: 14.h),
            for (int i = 0; i < schedule.length; i++)
              Padding(
                padding: EdgeInsets.only(bottom: i == schedule.length - 1 ? 0 : 7.h),
                child: Row(
                  children: [
                    Container(
                      width: 24.w,
                      height: 24.w,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFDEBD9),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: const Color(0xFFF57C1F),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(width: 9.w),
                    Expanded(
                      child: Text(
                        schedule[i],
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _ProgramDayCard extends StatefulWidget {
  final int day;
  final String title;
  final List<String> muscleGroups;
  final int duration;
  final List<PlanExercise> exercises;
  final List<WorkoutPhaseStep> warmUp;
  final List<WorkoutPhaseStep> coolDown;
  final String cardioGuidance;

  const _ProgramDayCard({
    required this.day,
    required this.title,
    required this.muscleGroups,
    required this.duration,
    required this.exercises,
    required this.warmUp,
    required this.coolDown,
    required this.cardioGuidance,
  });

  @override
  State<_ProgramDayCard> createState() => _ProgramDayCardState();
}

class _ProgramDayCardState extends State<_ProgramDayCard> {
  bool _expanded = false;

  Widget _phaseSteps(List<WorkoutPhaseStep> steps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int index = 0; index < steps.length; index++)
          Padding(
            padding: EdgeInsets.only(bottom: index == steps.length - 1 ? 0 : 7.h),
            child: Text(
              '${index + 1}. ${steps[index].instruction} — ${steps[index].duration}',
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF57C1F),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '${widget.day}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        '${widget.duration} min • ${widget.exercises.length} exercises',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
          if (widget.muscleGroups.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              widget.muscleGroups.join(', '),
              style: TextStyle(
                color: const Color(0xFFF57C1F),
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (_expanded) ...[
            SizedBox(height: 16.h),
            Text(
              'Warm up',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8.h),
            _phaseSteps(widget.warmUp),
            SizedBox(height: 16.h),
            for (int i = 0; i < widget.exercises.length; i++) ...[
              _ExerciseCard(exercise: widget.exercises[i]),
              if (i != widget.exercises.length - 1) SizedBox(height: 12.h),
            ],
            SizedBox(height: 16.h),
            Text(
              'Cool down',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8.h),
            _phaseSteps(widget.coolDown),
            if (widget.cardioGuidance.trim().isNotEmpty) ...[
              SizedBox(height: 14.h),
              Text(
                widget.cardioGuidance,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _ProgramGuidanceCard extends StatelessWidget {
  final String progression;
  final String recovery;
  final String cardio;

  const _ProgramGuidanceCard({
    required this.progression,
    required this.recovery,
    required this.cardio,
  });

  @override
  Widget build(BuildContext context) {
    final sections = <MapEntry<String, String>>[
      MapEntry('Progression', progression),
      MapEntry('Recovery', recovery),
      MapEntry('Cardio', cardio),
    ].where((section) => section.value.trim().isNotEmpty).toList();
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Program Guidance',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12.h),
          for (int i = 0; i < sections.length; i++) ...[
            Text(
              sections[i].key,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFF57C1F),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              sections[i].value,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade700,
                height: 1.45,
              ),
            ),
            if (i != sections.length - 1) SizedBox(height: 12.h),
          ],
        ],
      ),
    );
  }
}

// ─── Orange header ────────────────────────────────────────────────────────────
class _PlanHeader extends StatelessWidget {
  final String date;
  final String title;
  final String subtitle;

  const _PlanHeader(
      {required this.date, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF57C1F),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(date,
              style: TextStyle(color: Colors.white, fontSize: 13.sp)),
          SizedBox(height: 6.h),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            subtitle,
            style: TextStyle(
                color: Colors.white, fontSize: 14.sp, height: 1.4),
          ),
        ],
      ),
    );
  }
}

// ─── White section card ───────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 14.h),
          child,
        ],
      ),
    );
  }
}

class _NumberedItem extends StatelessWidget {
  final int index;
  final String text;
  final String highlight;

  const _NumberedItem(
      {required this.index, required this.text, required this.highlight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$index.',
              style:
                  TextStyle(fontSize: 14.sp, color: Colors.grey.shade600)),
          SizedBox(width: 8.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  height: 1.4,
                ),
                children: [
                  TextSpan(text: '$text — '),
                  TextSpan(
                    text: highlight,
                    style: const TextStyle(color: Color(0xFFF57C1F)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Expandable exercise card ─────────────────────────────────────────────────
class _ExerciseCard extends StatefulWidget {
  final PlanExercise exercise;

  const _ExerciseCard({required this.exercise});

  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  bool _expanded = false;
  bool _completed = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.exercise;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  e.name,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF7A3B1E),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _completed = !_completed),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
                  decoration: BoxDecoration(
                    color: _completed
                        ? Colors.green
                        : const Color(0xFFF57C1F),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    _completed ? 'Completed' : 'Mark Completed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Muscle group: ${e.muscleGroup}',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _Chip(e.sets),
              _Chip(e.reps),
              _Chip(e.rest),
              _Chip(e.rpe),
            ],
          ),
          SizedBox(height: 6.h),
          if (_expanded) ...[
            SizedBox(height: 8.h),
            for (int i = 0; i < e.steps.length; i++) ...[
              _StepItem(index: i + 1, step: e.steps[i]),
              SizedBox(height: 10.h),
            ],
          ],
          Center(
            child: GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: EdgeInsets.all(6.w),
                child: Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 26.sp,
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

class _Chip extends StatelessWidget {
  final String label;

  const _Chip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13.sp,
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final int index;
  final PlanStep step;

  const _StepItem({required this.index, required this.step});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$index.',
                style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black)),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                step.instruction,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: 22.w, top: 3.h),
          child: Text(
            'Tip: ${step.tip}',
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFFF57C1F),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Nutrition tip / plain info card ──────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final String title;
  final String body;

  const _InfoCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            body,
            style: TextStyle(
                fontSize: 15.sp, color: Colors.grey.shade600, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _WeekFocusCard extends StatelessWidget {
  final String focus;

  const _WeekFocusCard({required this.focus});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Week Focus',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFDEBD9),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              focus,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFFF57C1F),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckInCard extends StatelessWidget {
  final int duration;
  final String question;

  const _CheckInCard({required this.duration, required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Duration in min: $duration',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFF57C1F),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            question,
            style: TextStyle(
                fontSize: 15.sp, color: Colors.black87, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _WatchVideoButton extends StatelessWidget {
  final VoidCallback onTap;

  const _WatchVideoButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF5A623),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.r),
          ),
        ),
        child: Text(
          'Watch Video',
          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
