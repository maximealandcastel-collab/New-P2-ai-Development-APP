import 'dart:async';
import 'dart:math';
import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:pler_to_pler_app/features/trainer/createExercisePlan/presentation/screen/create_exercise_plan_screen.dart';
import 'package:pler_to_pler_app/routes/app_routes.dart';
import 'package:pler_to_pler_app/services/api_urls.dart';
import 'package:pler_to_pler_app/services/network/api_client.dart';

// ─── Entry point ─────────────────────────────────────────────────────────────
class WorkoutFinderFlow extends StatefulWidget {
  const WorkoutFinderFlow({super.key});

  @override
  State<WorkoutFinderFlow> createState() => _WorkoutFinderFlowState();
}

class _WorkoutFinderFlowState extends State<WorkoutFinderFlow> {
  int _step = 0; // 0-based (0..5)
  final int _totalSteps = 6;

  // ── Step 1: Goals
  final List<String> _goals = [
    'Build Muscle', 'Lose Fat', 'Improve Mobility', 'Improve Posture',
    'Pain Relief', 'Increase Strength', 'Flexibility', 'Endurance',
    'Low Impact', 'Just Get Started (beginner-friendly)',
  ];
  final Set<String> _selectedGoals = {};

  // ── Step 2: Focus areas
  final List<String> _areas = [
    'Chest', 'Back', 'Shoulders', 'Legs', 'Abs/Core',
    'Full body', 'Lower back', 'Neck',
  ];
  final Set<String> _selectedAreas = {};

  // ── Step 3: Location
  final List<String> _locations = ['Home', 'Gym', 'Office', 'Outdoor'];
  final Set<String> _selectedLocations = {};

  // ── Step 4: Equipment
  final List<String> _equipment = [
    'Dumbbells', 'Resistance Bands', 'Cable Machine', 'Treadmill',
    'Bench', 'Others', 'No equipment',
  ];
  final Set<String> _selectedEquipment = {};

  // ── Step 5: Intensity & Duration
  String _intensity = 'Medium';
  double _duration = 10;

  String _slug(String v) => v
      .toLowerCase()
      .replaceAll('/', '_')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');

  void _next() {
    if (_step < _totalSteps - 1) setState(() => _step++);
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  void _skip() => _next();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(step: _step, total: _totalSteps, onBack: _back, onSkip: _skip),
            Expanded(child: _buildStep()),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _SelectionStep(
          title: 'Choose Your Goals',
          subtitle: 'What you want to achieve from the workout',
          options: _goals,
          selected: _selectedGoals,
          onToggle: (v) => setState(() =>
          _selectedGoals.contains(v) ? _selectedGoals.remove(v) : _selectedGoals.add(v)),
          onNext: _next,
        );
      case 1:
        return _SelectionStep(
          title: 'Which areas do you want to focus on?',
          subtitle: 'Which area of your body you want to improve from the exercise.',
          options: _areas,
          selected: _selectedAreas,
          onToggle: (v) => setState(() =>
          _selectedAreas.contains(v) ? _selectedAreas.remove(v) : _selectedAreas.add(v)),
          onNext: _next,
        );
      case 2:
        return _SelectionStep(
          title: 'Where are you working out today?',
          subtitle: 'What you want to achieve from the workout',
          options: _locations,
          selected: _selectedLocations,
          onToggle: (v) => setState(() =>
          _selectedLocations.contains(v) ? _selectedLocations.remove(v) : _selectedLocations.add(v)),
          onNext: _next,
        );
      case 3:
        return _SelectionStep(
          title: 'What equipment do you have available?',
          subtitle: "What workout you can do with available equipment's",
          options: _equipment,
          selected: _selectedEquipment,
          onToggle: (v) => setState(() =>
          _selectedEquipment.contains(v) ? _selectedEquipment.remove(v) : _selectedEquipment.add(v)),
          onNext: _next,
        );
      case 4:
        return _IntensityDurationStep(
          intensity: _intensity,
          duration: _duration,
          onIntensityChanged: (v) => setState(() => _intensity = v),
          onDurationChanged: (v) => setState(() => _duration = v),
          onNext: _next,
        );
      case 5:
        return _LoadingStep(
          payload: {
            "goal": _selectedGoals.isEmpty
                ? ["general_fitness"]
                : _selectedGoals.map(_slug).toList(),
            "focusArea": _selectedAreas.isEmpty
                ? ["full_body"]
                : _selectedAreas.map(_slug).toList(),
            "workout_environment": _selectedLocations.isEmpty
                ? ["home"]
                : _selectedLocations.map(_slug).toList(),
            "equipment_availablity": _selectedEquipment.isEmpty
                ? ["no_equipment"]
                : _selectedEquipment.map(_slug).toList(),
            "workout_intensity": [_intensity.toLowerCase()],
            "duration": _duration.toInt(),
            "date": DateTime.now().toIso8601String().split('T').first,
          },
        );
      default:
        return const SizedBox();
    }
  }
}

// ─── Top Bar ─────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final int step;
  final int total;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  const _TopBar({
    required this.step,
    required this.total,
    required this.onBack,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 34.w,
              height: 34.h,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Icon(Icons.chevron_left, size: 20.sp),
            ),
          ),
          SizedBox(width: 12.w),

          // Progress segments
          Expanded(
            child: Row(
              children: List.generate(total, (i) {
                final filled = i <= step;
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i < total - 1 ? 4.w : 0),
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: filled ? Colors.black : Colors.black12,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                );
              }),
            ),
          ),

          SizedBox(width: 12.w),
          // Skip
          GestureDetector(
            onTap: onSkip,
            child: Text(
              'Skip',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: AppFontWeight.emphasis,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Generic Selection Step ───────────────────────────────────────────────────
class _SelectionStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final VoidCallback onNext;

  const _SelectionStep({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selected,
    required this.onToggle,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: AppFontWeight.section,
                  color: Colors.black,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),

        // Options
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: options.length,
            separatorBuilder: (_, __) => SizedBox(height: 10.h),
            itemBuilder: (_, i) {
              final opt = options[i];
              final isSelected = selected.contains(opt);
              return _OptionTile(
                label: opt,
                isSelected: isSelected,
                onTap: () => onToggle(opt),
              );
            },
          ),
        ),

        // Next button
        _NextButton(onTap: onNext),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF7A00) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isSelected ? AppFontWeight.label : AppFontWeight.body,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

// ─── Step 5: Intensity & Duration ─────────────────────────────────────────────
class _IntensityDurationStep extends StatelessWidget {
  final String intensity;
  final double duration;
  final ValueChanged<String> onIntensityChanged;
  final ValueChanged<double> onDurationChanged;
  final VoidCallback onNext;

  const _IntensityDurationStep({
    required this.intensity,
    required this.duration,
    required this.onIntensityChanged,
    required this.onDurationChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),
                Text(
                  'Workout Intensity & duration',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: AppFontWeight.section,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'What you want to achieve from the workout',
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
                ),
                SizedBox(height: 28.h),

                // Intensity label
                Text(
                  'Workout Intensity',
                  style: TextStyle(fontSize: 15.sp, fontWeight: AppFontWeight.label),
                ),
                SizedBox(height: 14.h),

                // Intensity selector
                Row(
                  children: ['Easy', 'Medium', 'Hard'].map((level) {
                    final isSelected = intensity == level;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: level == 'Hard' ? 0 : 10.w),
                        child: GestureDetector(
                          onTap: () => onIntensityChanged(level),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.black : Colors.white,
                              borderRadius: BorderRadius.circular(14.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  level == 'Easy'
                                      ? Icons.directions_walk
                                      : level == 'Medium'
                                      ? Icons.directions_run
                                      : Icons.fitness_center,
                                  color: isSelected ? Colors.white : Colors.black54,
                                  size: 24.sp,
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  level,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: AppFontWeight.emphasis,
                                    color: isSelected ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 32.h),

                // Duration label
                Text(
                  'Workout Duration',
                  style: TextStyle(fontSize: 15.sp, fontWeight: AppFontWeight.label),
                ),
                SizedBox(height: 20.h),

                // Duration display
                Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${duration.toInt()}',
                          style: TextStyle(
                            fontSize: 52.sp,
                            fontWeight: AppFontWeight.section,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: ' min',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey,
                            fontWeight: AppFontWeight.body,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8.h),

                // Slider
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3.h,
                    activeTrackColor: Colors.black,
                    inactiveTrackColor: Colors.black12,
                    thumbColor: Colors.black,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 14.r),
                    tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 2.r),
                    activeTickMarkColor: Colors.black,
                    inactiveTickMarkColor: Colors.black26,
                  ),
                  child: Slider(
                    value: duration,
                    min: 5,
                    max: 90,
                    divisions: 17,
                    onChanged: onDurationChanged,
                  ),
                ),
              ],
            ),
          ),
        ),

        _NextButton(onTap: onNext),
      ],
    );
  }
}

// ─── Step 6: Loading / Finding Plan ──────────────────────────────────────────
class _LoadingStep extends StatefulWidget {
  final Map<String, dynamic> payload;

  const _LoadingStep({required this.payload});

  @override
  State<_LoadingStep> createState() => _LoadingStepState();
}

class _LoadingStepState extends State<_LoadingStep>
        with SingleTickerProviderStateMixin {
      late final AnimationController _ctrl;
      late final Animation<double> _rotation;
      bool _hasNavigated = false;
      bool _isGenerating = false;
      String? _errorMessage;
      Map<String, dynamic>? _generatedPlan;

      static const _steps = [
        'Analyzing your fitness goals…',
        'Building your workout structure…',
        'Personalizing your exercises…',
      ];
      int _stepIndex = 0;
      Timer? _stepTimer;

      // A slightly longer minimum makes the generation feel intentional without
      // holding users after a genuinely slow API response.
      static const _minDisplayMs = 6500;

      @override
      void initState() {
        super.initState();
        _ctrl = AnimationController(
          vsync: this,
          duration: const Duration(seconds: 2),
        )..repeat();
        _rotation = Tween<double>(begin: 0, end: 1).animate(_ctrl);

        _stepTimer = Timer.periodic(const Duration(milliseconds: 2100), (_) {
          if (!mounted || _generatedPlan != null) return;
          if (_stepIndex < _steps.length - 1) {
            setState(() => _stepIndex++);
          }
        });

        _generatePlan();
      }

      String _responseMessage(dynamic body, String fallback) {
        if (body is Map) {
          final message = body['message'] ?? body['error'];
          if (message != null && message.toString().trim().isNotEmpty) {
            return message.toString();
          }
        }
        return fallback;
      }

      Future<void> _generatePlan() async {
        if (_isGenerating) return;
        setState(() {
          _isGenerating = true;
          _errorMessage = null;
          _generatedPlan = null;
          _stepIndex = 0;
        });

        final sw = Stopwatch()..start();
        Map<String, dynamic>? plan;
        String? failureMessage;
        try {
          final createRes =
              await ApiClient.postData(ApiUrls.workoutCreate, widget.payload);
          if (createRes.statusCode != 200 && createRes.statusCode != 201) {
            throw Exception(_responseMessage(
              createRes.body,
              'Could not save your workout preferences.',
            ));
          }

          final workoutId = createRes.body is Map
              ? (createRes.body['data']?['_id'] ?? createRes.body['data']?['id'])
              : null;
          if (workoutId == null) {
            throw Exception('The server did not return a workout ID.');
          }

          final genRes = await ApiClient.postData(
            ApiUrls.workoutGenerate(workoutId.toString()),
            {},
          );
          if (genRes.statusCode != 200 || genRes.body is! Map) {
            throw Exception(_responseMessage(
              genRes.body,
              'Could not generate your workout plan.',
            ));
          }

          final data = genRes.body['data'];
          if (data is Map<String, dynamic>) {
            final rawPlan = data['aiPlan'] ?? data['plan'] ?? data;
            if (rawPlan is Map) {
              plan = Map<String, dynamic>.from(rawPlan);
            }
          }
          if (plan == null) {
            throw Exception('The generated workout plan was empty.');
          }
        } catch (error) {
          failureMessage =
              error.toString().replaceFirst('Exception: ', '').trim();
        }

        final remaining = _minDisplayMs - sw.elapsedMilliseconds;
        if (remaining > 0) await Future.delayed(Duration(milliseconds: remaining));

        if (!mounted || _hasNavigated) return;
        if (plan == null) {
          setState(() {
            _isGenerating = false;
            _errorMessage = failureMessage?.isNotEmpty == true
                ? failureMessage
                : 'Could not generate your plan. Check your connection and try again.';
          });
          return;
        }

        setState(() {
          _isGenerating = false;
          _generatedPlan = plan;
          _stepIndex = _steps.length - 1;
        });
      }

      void _openGeneratedPlan() {
        if (_generatedPlan == null || _hasNavigated) return;
        _hasNavigated = true;
        Get.offNamed(AppRoute.aiPlanResult, arguments: _generatedPlan);
      }

      double get _progressValue {
        if (_generatedPlan != null) return 1;
        if (_stepIndex == 0) return .28;
        if (_stepIndex == 1) return .56;
        return .82;
      }

      @override
      void dispose() {
        _stepTimer?.cancel();
        _ctrl.dispose();
        super.dispose();
      }

      @override
      Widget build(BuildContext context) {
        if (_errorMessage != null) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64.sp,
                    color: Colors.redAccent,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Could not generate your workout plan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: AppFontWeight.section,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade600,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: 28.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isGenerating ? null : _generatePlan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: const Text('Try Again'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'GENERATE',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: AppFontWeight.section,
                  color: const Color(0xFFFF6B35),
                  letterSpacing: 1.8,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'WORKOUT
SPLIT',
                style: TextStyle(
                  fontSize: 34.sp,
                  fontWeight: AppFontWeight.section,
                  color: Colors.black,
                  height: .98,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                _generatedPlan == null
                    ? 'Get a custom workout plan tailored to your goals.'
                    : 'Your personalized workout split is ready to view.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                  height: 1.35,
                ),
              ),
              SizedBox(height: 24.h),
              Container(
                height: 52.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF16C5BC), Color(0xFF0BA9B5)],
                  ),
                  borderRadius: BorderRadius.circular(26.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF16C5BC).withOpacity(.2),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome_rounded,
                          color: Colors.white, size: 18.sp),
                      SizedBox(width: 9.w),
                      Text(
                        _generatedPlan == null
                            ? 'Generating Workout Split'
                            : 'Workout Split Generated',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: AppFontWeight.section,
                        ),
                      ),
                      SizedBox(width: 9.w),
                      Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 18.sp),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 18.h),
              for (int i = 0; i < _steps.length; i++)
                Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: _GenerationStepCard(
                    label: _steps[i],
                    completed: _generatedPlan != null || _stepIndex > i,
                    active: _generatedPlan == null && _stepIndex == i,
                  ),
                ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: AppFontWeight.section,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    '${(_progressValue * 100).round()}%',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: AppFontWeight.section,
                      color: const Color(0xFFFF6B35),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  minHeight: 5.h,
                  value: _progressValue,
                  backgroundColor: const Color(0xFFFFE2D6),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFF6B35),
                  ),
                ),
              ),
              if (_generatedPlan != null) ...[
                SizedBox(height: 22.h),
                Container(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F7EC),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: const Color(0xFFC9EBD1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Your Workout Split Is Ready!',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: AppFontWeight.section,
                          color: const Color(0xFF258B4D),
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        'Your personalized plan is ready to review.',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF4E795A),
                        ),
                      ),
                      SizedBox(height: 14.h),
                      ElevatedButton(
                        onPressed: _openGeneratedPlan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B35),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 13.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('View My Workout Split'),
                            SizedBox(width: 8.w),
                            const Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
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

    class _GenerationStepCard extends StatelessWidget {
      final String label;
      final bool completed;
      final bool active;

      const _GenerationStepCard({
        required this.label,
        required this.completed,
        required this.active,
      });

      @override
      Widget build(BuildContext context) {
        final accent = completed
            ? const Color(0xFF61BD75)
            : active
                ? const Color(0xFFFFB366)
                : const Color(0xFFD5D9D7);
        final icon = completed
            ? Icons.check_rounded
            : active
                ? Icons.tune_rounded
                : Icons.more_horiz_rounded;
        final status = completed
            ? 'Complete'
            : active
                ? 'In progress…'
                : 'Queued';

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE7E9E8)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.035),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  color: accent.withOpacity(.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accent, size: 17.sp),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: AppFontWeight.section,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        color: completed
                            ? const Color(0xFF4B9C5D)
                            : Colors.grey.shade500,
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
    
class _ArcLoaderPainter extends CustomPainter {
  final double progress;

  _ArcLoaderPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Track
    final trackPaint = Paint()
      ..color = Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Arc gradient
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweepAngle = pi * 1.4;
    final startAngle = -pi / 2 + (2 * pi * progress);

    final arcPaint = Paint()
      ..shader = SweepGradient(
        colors: const [Color(0xFFFF7A00), Color(0xFFFFB347)],
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant _ArcLoaderPainter old) =>
      old.progress != progress;
}

// ─── Shared Next Button ───────────────────────────────────────────────────────
class _NextButton extends StatelessWidget {
  final VoidCallback onTap;

  const _NextButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 52.h,
          decoration: BoxDecoration(
            color: const Color(0xFFFF7A00),
            borderRadius: BorderRadius.circular(14.r),
          ),
          alignment: Alignment.center,
          child: Text(
            'Next',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: AppFontWeight.label,
            ),
          ),
        ),
      ),
    );
  }
}