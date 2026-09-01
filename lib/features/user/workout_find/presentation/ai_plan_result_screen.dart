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
  final String id;
  final String name;
  final String muscleGroup;
  final int setCount;
  final String sets;
  final String reps;
  final String rest;
  final String rpe;
  final List<PlanStep> steps;

  const PlanExercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.setCount,
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
  bool _isStarting = false;
  bool _isStarted = false;
  bool _isCompleting = false;
  DateTime? _startedAt;
  final Set<String> _completedExerciseIds = <String>{};
  final Set<String> _exerciseRequestsInFlight = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPendingUnlocks();
      _resumeSession();
    });
  }

  Future<void> _showPendingUnlocks() async {
    try {
      final pending = await AchievementService.getPending();
      if (!mounted || pending.isEmpty) return;
      await CompactAchievementPresenter.showQueue(context, pending);
    } catch (error) {
      _resultLog.w('Could not load pending achievements: $error');
    }
  }

  String _workoutId(Map<String, dynamic>? response) =>
      response?['workoutId']?.toString().trim() ?? '';

  Set<String> _completedIdsFromWorkout(dynamic workout) {
    if (workout is! Map || workout['aiPlan'] is! Map) return const <String>{};
    final plan = workout['aiPlan'] as Map;
    final completed = <String>{};
    for (final section in const ['mainWork', 'accessories', 'finisher']) {
      final exercises = plan[section];
      if (exercises is! List) continue;
      for (final exercise in exercises.whereType<Map>()) {
        final id = (exercise['exerciseId'] ?? exercise['_id'] ?? '')
            .toString()
            .trim();
        if (id.isNotEmpty && exercise['isCompleted'] == true) {
          completed.add(id);
        }
      }
    }
    return completed;
  }

  Future<void> _resumeSession() async {
    final response = Get.arguments is Map<String, dynamic>
        ? Get.arguments as Map<String, dynamic>
        : null;
    final workoutId = _workoutId(response);
    if (workoutId.isEmpty) return;
    final result = await ApiClient.getData(ApiUrls.workoutById(workoutId));
    if (!mounted || result.statusCode != 200 || result.body is! Map) return;
    final workout = (result.body as Map)['data'];
    if (workout is! Map) return;
    final status = workout['status']?.toString();
    final startedAt = DateTime.tryParse('${workout['startedAt']}');
    setState(() {
      _isStarted = status == 'in_progress';
      if (_isStarted) {
        _startedAt = startedAt?.toLocal() ?? DateTime.now();
      }
      _completedExerciseIds
        ..clear()
        ..addAll(_completedIdsFromWorkout(workout));
    });
  }

  String _apiMessage(dynamic body, String fallback) {
    if (body is Map && body['message']?.toString().trim().isNotEmpty == true) {
      return body['message'].toString();
    }
    return fallback;
  }

  Future<void> _startWorkout(Map<String, dynamic>? response) async {
    if (_isStarting || _isStarted) return;
    final workoutId = _workoutId(response);
    if (workoutId.isEmpty) {
      Get.snackbar(
        'Workout not ready',
        'This workout is missing its session ID. Please generate it again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isStarting = true);
    try {
      final result = await ApiClient.patchData(
        ApiUrls.workoutStart(workoutId),
        const <String, dynamic>{},
      );
      if (result.statusCode != 200) {
        throw Exception(
          _apiMessage(
            result.body,
            result.statusText ?? 'Could not start this workout.',
          ),
        );
      }
      final data = result.body is Map ? (result.body as Map)['data'] : null;
      final serverStartedAt =
          data is Map ? DateTime.tryParse('${data['startedAt']}') : null;
      final completedIds = _completedIdsFromWorkout(data);
      if (!mounted) return;
      setState(() {
        _isStarted = true;
        _startedAt = serverStartedAt?.toLocal() ?? DateTime.now();
        _completedExerciseIds
          ..clear()
          ..addAll(completedIds);
      });
      Get.snackbar(
        'Workout started',
        'Complete each exercise, then finish your session.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (error) {
      if (!mounted) return;
      Get.snackbar(
        'Could not start workout',
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  Future<void> _completeExercise(
    Map<String, dynamic>? response,
    PlanExercise exercise,
  ) async {
    if (!_isStarted ||
        exercise.id.isEmpty ||
        _completedExerciseIds.contains(exercise.id) ||
        _exerciseRequestsInFlight.contains(exercise.id)) {
      return;
    }
    final workoutId = _workoutId(response);
    if (workoutId.isEmpty) return;

    setState(() => _exerciseRequestsInFlight.add(exercise.id));
    try {
      final result = await ApiClient.patchData(
        ApiUrls.workoutExerciseComplete(workoutId, exercise.id),
        <String, dynamic>{
          'completedSets': exercise.setCount,
        },
      );
      if (result.statusCode != 200) {
        throw Exception(
          _apiMessage(
            result.body,
            result.statusText ?? 'Could not save this exercise.',
          ),
        );
      }
      if (!mounted) return;
      setState(() => _completedExerciseIds.add(exercise.id));
    } catch (error) {
      if (!mounted) return;
      Get.snackbar(
        'Exercise not saved',
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() => _exerciseRequestsInFlight.remove(exercise.id));
      }
    }
  }

  Future<String?> _collectCheckIn(String question) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Finish your workout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question),
            SizedBox(height: 14.h),
            TextField(
              controller: controller,
              autofocus: true,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'How did the session feel?',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _completeWorkout(
    Map<String, dynamic>? response,
    List<PlanExercise> exercises,
    String checkInQuestion,
  ) async {
    if (_isCompleting) return;
    if (!_isStarted || _startedAt == null) {
      Get.snackbar(
        'Start your workout first',
        'Tap Start Workout before completing the session.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final trackableExercises =
        exercises.where((exercise) => exercise.id.isNotEmpty).toList();
    if (trackableExercises.length != exercises.length) {
      Get.snackbar(
        'Workout cannot be tracked',
        'One or more exercises are missing tracking information. Please generate the workout again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final remaining = trackableExercises
        .where((exercise) => !_completedExerciseIds.contains(exercise.id))
        .length;
    if (remaining > 0) {
      Get.snackbar(
        'Finish every exercise',
        '$remaining exercise${remaining == 1 ? '' : 's'} remaining.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final checkIn = await _collectCheckIn(checkInQuestion);
    if (!mounted || checkIn == null) return;
    if (checkIn.isEmpty) {
      Get.snackbar(
        'Check-in required',
        'Add a short note about how the workout felt.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final workoutId = _workoutId(response);
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
      final duration = DateTime.now()
          .difference(_startedAt!)
          .inMinutes
          .clamp(1, 600)
          .toInt();
      final completion = await ApiClient.postData(
        ApiUrls.workoutComplete(workoutId),
        {
          'checkInResponse': checkIn,
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
        id: (e['exerciseId'] ?? e['_id'] ?? '').toString(),
        name: (e['exerciseName'] ?? e['name'] ?? 'Exercise').toString(),
        muscleGroup: (e['muscleGroup'] ?? '').toString(),
        setCount: (e['sets'] as num?)?.toInt() ?? 3,
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

  Widget _exerciseList(
    List<PlanExercise> exercises,
    Map<String, dynamic>? response,
  ) {
    return Column(
      children: [
        for (int i = 0; i < exercises.length; i++) ...[
          _ExerciseCard(
            exercise: exercises[i],
            showCompletionControl: true,
            sessionStarted: _isStarted,
            completed: _completedExerciseIds.contains(exercises[i].id),
            saving: _exerciseRequestsInFlight.contains(exercises[i].id),
            onComplete: () => _completeExercise(response, exercises[i]),
          ),
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
    final sessionExercises = <PlanExercise>[
      ...mainWork,
      ...accessories,
      ...finisher,
    ];
    final completedExerciseCount = sessionExercises
        .where(
          (exercise) =>
              exercise.id.isNotEmpty &&
              _completedExerciseIds.contains(exercise.id),
        )
        .length;
    final allExercisesCompleted = sessionExercises.isNotEmpty &&
        completedExerciseCount == sessionExercises.length;
    final checkInQuestion = (plan?['checkInQuestion'] as String?) ??
        "How did today's session feel? Include loads, effort, pain, or equipment issues.";
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
                    _SessionProgressCard(
                      started: _isStarted,
                      completedExercises: completedExerciseCount,
                      totalExercises: sessionExercises.length,
                    ),
                    SizedBox(height: 16.h),
                    _SectionCard(
                      title: program == null ? 'Warm up' : 'Start Day 1 — Warm up',
                      child: _phaseStepList(warmUp),
                    ),
                    SizedBox(height: 16.h),
                    _SectionCard(
                      title: 'Main Work',
                      child: _exerciseList(mainWork, response),
                    ),
                    if (accessories.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      _SectionCard(
                        title: 'Accessories',
                        child: _exerciseList(accessories, response),
                      ),
                    ],
                    if (finisher.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      _SectionCard(
                        title: 'Finisher',
                        child: _exerciseList(finisher, response),
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
                      question: checkInQuestion,
                    ),
                    SizedBox(height: 20.h),
                    _WatchVideoButton(onTap: () {
                      Get.to(() => const FeedScreen());
                    }),
                  ],
                ),
              ),
            ),
            // ── Sticky Workout Lifecycle ──
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
              child: SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
                  onPressed: _isStarting ||
                          _isCompleting ||
                          _exerciseRequestsInFlight.isNotEmpty
                      ? null
                      : !_isStarted
                          ? () => _startWorkout(response)
                          : allExercisesCompleted
                              ? () => _completeWorkout(
                                    response,
                                    sessionExercises,
                                    checkInQuestion,
                                  )
                              : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF57C1F),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                  ),
                  child: _isStarting || _isCompleting
                      ? SizedBox(
                          width: 22.w,
                          height: 22.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          !_isStarted
                              ? 'Start Workout'
                              : allExercisesCompleted
                                  ? 'Complete Workout'
                                  : '$completedExerciseCount/${sessionExercises.length} Exercises Complete',
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

class _SessionProgressCard extends StatelessWidget {
  final bool started;
  final int completedExercises;
  final int totalExercises;

  const _SessionProgressCard({
    required this.started,
    required this.completedExercises,
    required this.totalExercises,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        totalExercises == 0 ? 0.0 : completedExercises / totalExercises;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: started ? const Color(0xFFFFF5EA) : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: started ? const Color(0xFFF6D1AD) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                started ? Icons.timer_outlined : Icons.play_circle_outline,
                color: const Color(0xFFF57C1F),
                size: 22.sp,
              ),
              SizedBox(width: 9.w),
              Expanded(
                child: Text(
                  started ? 'Workout in progress' : 'Ready to begin',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$completedExercises/$totalExercises',
                style: TextStyle(
                  color: const Color(0xFFF57C1F),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7.h,
              backgroundColor: const Color(0xFFF0E7DE),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFFF57C1F)),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            started
                ? 'Mark each exercise complete as you train.'
                : 'Tap Start Workout below to begin tracking.',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12.sp,
            ),
          ),
        ],
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
  final bool showCompletionControl;
  final bool sessionStarted;
  final bool completed;
  final bool saving;
  final VoidCallback? onComplete;

  const _ExerciseCard({
    required this.exercise,
    this.showCompletionControl = false,
    this.sessionStarted = false,
    this.completed = false,
    this.saving = false,
    this.onComplete,
  });

  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  bool _expanded = false;

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
              if (widget.showCompletionControl)
                GestureDetector(
                  onTap: !widget.sessionStarted ||
                          widget.completed ||
                          widget.saving ||
                          e.id.isEmpty
                      ? null
                      : widget.onComplete,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
                    decoration: BoxDecoration(
                      color: widget.completed
                          ? Colors.green
                          : widget.sessionStarted && e.id.isNotEmpty
                              ? const Color(0xFFF57C1F)
                              : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: widget.saving
                        ? SizedBox(
                            width: 14.w,
                            height: 14.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            widget.completed
                                ? 'Completed'
                                : widget.sessionStarted
                                    ? 'Mark Completed'
                                    : 'Start First',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
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
