import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/user/contents/presentations/feed_screen.dart';

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

class AiPlanResultScreen extends StatelessWidget {
  const AiPlanResultScreen({super.key});

  // Sample plan shown when the backend is unreachable (demo mode).
  static const List<PlanExercise> _sampleMainWork = [
    PlanExercise(
      name: 'Bench Press',
      muscleGroup: 'Chest',
      sets: '4 sets',
      reps: '6-8 reps',
      rest: 'Rest 120s',
      rpe: 'RPE 8-9',
      steps: [
        PlanStep(
          instruction:
              'Lie flat on bench, grip bar slightly wider than shoulder-width',
          tip: 'Keep shoulder blades retracted and pinched together',
        ),
        PlanStep(
          instruction:
              'Unrack the bar and lower it to your mid-chest under control',
          tip: '3-second descent, touch chest lightly',
        ),
        PlanStep(
          instruction:
              'Press the bar back up explosively to full arm extension',
          tip: 'Drive your feet into the floor for stability',
        ),
      ],
    ),
    PlanExercise(
      name: 'Incline Dumbbell Press',
      muscleGroup: 'Chest',
      sets: '3 sets',
      reps: '8-10 reps',
      rest: 'Rest 90s',
      rpe: 'RPE 7-8',
      steps: [
        PlanStep(
          instruction:
              'Set bench to a 30-45 degree incline, dumbbells at shoulder level',
          tip: 'Keep wrists stacked over elbows',
        ),
        PlanStep(
          instruction: 'Press the dumbbells up and slightly together',
          tip: 'Do not let the weights clank at the top',
        ),
      ],
    ),
  ];

  /// Parse the backend AI plan (passed via Get.arguments) or fall back to
  /// the sample plan when running without a backend connection.
  static List<PlanExercise> _parseMainWork(Map<String, dynamic>? plan) {
    final raw = plan?['mainWork'];
    if (raw is! List || raw.isEmpty) return _sampleMainWork;
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

  static String _sectionText(Map<String, dynamic>? plan, String key,
      String fallback) {
    final raw = plan?[key];
    if (raw is List && raw.isNotEmpty && raw.first is Map) {
      final first = raw.first as Map;
      return (first['instruction'] ?? fallback).toString();
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final plan = Get.arguments is Map<String, dynamic>
        ? Get.arguments as Map<String, dynamic>
        : null;
    final mainWork = _parseMainWork(plan);
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
                      title: 'Maintain Physique',
                      subtitle: (plan?['coachNote'] as String?) ??
                          "Your trainer built today's session around your focus.",
                    ),
                    SizedBox(height: 16.h),
                    _SectionCard(
                      title: 'Warm up',
                      child: _NumberedItem(
                        index: 1,
                        text: _sectionText(plan, 'warmUp',
                            '5 minutes light cardio plus dynamic stretching'),
                        highlight: '5 minutes',
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _SectionCard(
                      title: 'Main Work',
                      child: Column(
                        children: [
                          for (int i = 0; i < mainWork.length; i++) ...[
                            _ExerciseCard(exercise: mainWork[i]),
                            if (i != mainWork.length - 1)
                              SizedBox(height: 14.h),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _SectionCard(
                      title: 'Cool down',
                      child: _NumberedItem(
                        index: 1,
                        text: _sectionText(plan, 'coolDown',
                            'Stretch the muscle groups you trained today'),
                        highlight: '5 minutes',
                      ),
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
                              10,
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
            // ── Sticky Session Start ──
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
              child: SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
                  onPressed: () {
                    Get.snackbar(
                      'Session Started!',
                      "Great work — go crush it! Your progress is being tracked.",
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 3),
                    );
                    Future.delayed(const Duration(seconds: 1), () => Get.back());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF57C1F),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                  ),
                  child: Text(
                    'Session Start',
                    style: TextStyle(
                        fontSize: 17.sp, fontWeight: FontWeight.w700),
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
