import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:pler_to_pler_app/features/trainer/createExercisePlan/presentation/screen/create_exercise_plan_screen.dart';
import 'package:pler_to_pler_app/routes/app_routes.dart';
import 'package:pler_to_pler_app/services/api_urls.dart';
import 'package:pler_to_pler_app/services/logger.dart';
import 'package:pler_to_pler_app/services/network/api_client.dart';

final workoutGenerationLog = logger(WorkoutFinderFlow);

String _newWorkoutTraceId(String stage) {
  final timestamp = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
  final nonce = Random().nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0');
  return '$stage-$timestamp-$nonce';
}

void _logWorkoutHandoff(
  String traceId,
  String event, [
  Map<String, Object?> details = const {},
]) {
  workoutGenerationLog.i('[WORKOUT_GENERATION][$event] ${{
    'traceId': traceId,
    ...details,
  }}');
}

Map<String, dynamic>? _asStringMap(dynamic value) {
  return value is Map ? Map<String, dynamic>.from(value) : null;
}

class _WorkoutGenerationFailure implements Exception {
  final String code;
  final String userMessage;

  const _WorkoutGenerationFailure(this.code, this.userMessage);

  @override
  String toString() => code;
}

_WorkoutGenerationFailure _responseFailure(
  dynamic response,
  String code,
  String fallbackMessage,
) {
  final body = _asStringMap(response.body);
  final serverMessage = body?['message']?.toString().trim();
  final statusMessage = response.statusText?.toString().trim();
  return _WorkoutGenerationFailure(
    code,
    serverMessage?.isNotEmpty == true
        ? serverMessage!
        : statusMessage?.isNotEmpty == true
            ? statusMessage!
            : fallbackMessage,
  );
}

// ─── Entry point ─────────────────────────────────────────────────────────────
class WorkoutFinderFlow extends StatefulWidget {
  const WorkoutFinderFlow({super.key});

  @override
  State<WorkoutFinderFlow> createState() => _WorkoutFinderFlowState();
}

class _WorkoutFinderFlowState extends State<WorkoutFinderFlow> {
  int _step = 0; // 0-based (0..7)
  final int _totalSteps = 8;
  String? _workoutId;
  List<Map<String, dynamic>> _splitOptions = [];
  String? _selectedSplitId;
  bool _generationInFlight = false;

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
  double _duration = 30;

  String _slug(String v) => v
      .toLowerCase()
      .replaceAll('/', '_')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');

  String _goalValue(String value) => {
        'Build Muscle': 'muscle_gain',
        'Lose Fat': 'weight_loss',
        'Improve Mobility': 'flexibility',
        'Improve Posture': 'maintain_physique',
        'Pain Relief': 'flexibility',
        'Increase Strength': 'strength',
        'Flexibility': 'flexibility',
        'Endurance': 'endurance',
        'Low Impact': 'maintain_physique',
        'Just Get Started (beginner-friendly)': 'maintain_physique',
      }[value] ??
      _slug(value);

  String _focusValue(String value) => {
        'Abs/Core': 'core',
        'Lower back': 'back',
        'Neck': 'shoulders',
      }[value] ??
      _slug(value);

  String _locationValue(String value) =>
      value == 'Gym' ? 'full_gym' : _slug(value);

  String _intensityValue(String value) => {
        'Easy': 'light',
        'Medium': 'moderate',
        'Hard': 'intense',
      }[value] ??
      _slug(value);

  void _next() {
    if (_step < _totalSteps - 1) {
      setState(() {
        _step++;
        if (_step == 5) _generationInFlight = true;
      });
    }
  }

  void _back() {
    if ((_step == 5 || _step == 7) && _generationInFlight) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Generation is in progress. Please wait for this step to finish.',
            ),
            duration: Duration(seconds: 2),
          ),
        );
      return;
    }
    if (_step == 7) {
      setState(() {
        _step = 6;
        _generationInFlight = false;
      });
      return;
    }
    if (_step == 0) {
      Get.back();
      return;
    }
    if (_step >= 5) {
      setState(() {
        _step = 4;
        _workoutId = null;
        _splitOptions = [];
        _selectedSplitId = null;
      });
      return;
    }
    setState(() => _step--);
  }

  void _skip() {
    if (_step < 5) _next();
  }

  Map<String, dynamic> get _workoutPayload => {
        "goal": _selectedGoals.isEmpty
            ? ["maintain_physique"]
            : _selectedGoals.map(_goalValue).toList(),
        "focusArea": _selectedAreas.isEmpty
            ? ["full_body"]
            : _selectedAreas.map(_focusValue).toList(),
        "workout_environment": _selectedLocations.isEmpty
            ? ["home"]
            : _selectedLocations.map(_locationValue).toList(),
        "equipment_availablity": _selectedEquipment.isEmpty
            ? ["no_equipment"]
            : _selectedEquipment.map(_slug).toList(),
        "workout_intensity": [_intensityValue(_intensity)],
        "duration": _duration.toInt(),
        "date": DateTime.now().toIso8601String().split('T').first,
        "workoutPreferences": {
          // The current questionnaire does not ask weekly availability.
          // The backend also accepts 2-6 from future clients.
          "daysPerWeek": 3,
        },
      };

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(
                step: _step,
                total: _totalSteps,
                onBack: _back,
                onSkip: _skip,
              ),
              Expanded(child: _buildStep()),
            ],
          ),
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
        return _SplitLoadingStep(
          payload: _workoutPayload,
          existingWorkoutId: _workoutId,
          onWorkoutCreated: (workoutId) => _workoutId = workoutId,
          onLoadingChanged: (loading) {
            if (!mounted || _step != 5 || _generationInFlight == loading) {
              return;
            }
            setState(() => _generationInFlight = loading);
          },
          onLoaded: (workoutId, options) {
            if (!mounted) return;
            setState(() {
              _workoutId = workoutId;
              _splitOptions = options;
              _selectedSplitId = null;
              _generationInFlight = false;
              _step = 6;
            });
          },
        );
      case 6:
        return _SplitSelectionStep(
          options: _splitOptions,
          selectedSplitId: _selectedSplitId,
          onSelected: (id) => setState(() => _selectedSplitId = id),
          onNext: () {
            if (_selectedSplitId == null) return;
            setState(() {
              _step = 7;
              _generationInFlight = true;
            });
          },
        );
      case 7:
        return _ProgramLoadingStep(
          workoutId: _workoutId!,
          selectedSplitId: _selectedSplitId!,
          onLoadingChanged: (loading) {
            if (!mounted || _step != 7 || _generationInFlight == loading) {
              return;
            }
            setState(() => _generationInFlight = loading);
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
          Semantics(
            button: true,
            label: 'Go back',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
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
          if (step < 5)
            Semantics(
              button: true,
              label: 'Skip this question',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onSkip,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            )
          else
            SizedBox(width: 30.w),
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
                  fontWeight: FontWeight.w700,
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
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
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
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: Colors.black87,
            ),
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
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Choose a realistic session length for a complete workout',
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
                ),
                SizedBox(height: 28.h),

                // Intensity label
                Text(
                  'Workout Intensity',
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
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
                                    fontWeight: FontWeight.w500,
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
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
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
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: ' min',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
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
                    min: 20,
                    max: 90,
                    divisions: 14,
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

// ─── Step 6: Generate split recommendations ──────────────────────────────────
class _SplitLoadingStep extends StatefulWidget {
  final Map<String, dynamic> payload;
  final String? existingWorkoutId;
  final ValueChanged<String> onWorkoutCreated;
  final ValueChanged<bool> onLoadingChanged;
  final void Function(String workoutId, List<Map<String, dynamic>> options)
      onLoaded;

  const _SplitLoadingStep({
    required this.payload,
    required this.existingWorkoutId,
    required this.onWorkoutCreated,
    required this.onLoadingChanged,
    required this.onLoaded,
  });

  @override
  State<_SplitLoadingStep> createState() => _SplitLoadingStepState();
}

class _SplitLoadingStepState extends State<_SplitLoadingStep> {
  bool _hasCompleted = false;
  bool _isLoading = true;
  bool _requestInFlight = false;
  String? _error;
  String? _workoutId;

  static const _phases = [
    'Analyzing your goals…',
    'Comparing weekly split strategies…',
    'Balancing training and recovery…',
    'Calibrating intensity & duration…',
    'Preparing three recommendations…',
    'Almost ready…',
  ];
  int _phaseIndex = 0;
  Timer? _phaseTimer;

  @override
  void initState() {
    super.initState();
    _phaseTimer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
      if (mounted && _phaseIndex < _phases.length - 1) {
        setState(() => _phaseIndex++);
      }
    });
    _workoutId = widget.existingWorkoutId;
    _generateSplits();
  }

  Future<void> _generateSplits() async {
    if (_requestInFlight || _hasCompleted) return;
    final traceId = _newWorkoutTraceId('splits');
    _requestInFlight = true;
    widget.onLoadingChanged(true);
    if (_isLoading == false) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      if (_workoutId == null) {
        _logWorkoutHandoff(traceId, 'request_sent', {
          'stage': 'create',
          'uri': ApiUrls.workoutCreate,
        });
        final createRes = await ApiClient.postData(
          ApiUrls.workoutCreate,
          widget.payload,
          traceId: traceId,
        );
        _logWorkoutHandoff(traceId, 'response_received', {
          'stage': 'create',
          'statusCode': createRes.statusCode,
          'bodyType': createRes.body.runtimeType.toString(),
        });
        if (createRes.statusCode == null ||
            createRes.statusCode! < 200 ||
            createRes.statusCode! >= 300) {
          throw _responseFailure(
            createRes,
            'create_request_failed',
            "We couldn't save your workout preferences. Please try again.",
          );
        }
        final createData = _asStringMap(_asStringMap(createRes.body)?['data']);
        final createdId = createData?['_id'] ?? createData?['id'];
        if (createdId == null || createdId.toString().trim().isEmpty) {
          throw const _WorkoutGenerationFailure(
            'create_response_missing_id',
            'The workout service returned an incomplete response. Please try again.',
          );
        }
        _workoutId = createdId.toString();
        widget.onWorkoutCreated(_workoutId!);
        _logWorkoutHandoff(traceId, 'state_set', {
          'stage': 'create',
          'workoutId': _workoutId,
        });
      }

      _logWorkoutHandoff(traceId, 'request_sent', {
        'stage': 'splits',
        'workoutId': _workoutId,
        'uri': ApiUrls.workoutSplits(_workoutId!),
      });
      final splitRes = await ApiClient.postData(
        ApiUrls.workoutSplits(_workoutId!),
        {},
        traceId: traceId,
      );
      _logWorkoutHandoff(traceId, 'response_received', {
        'stage': 'splits',
        'statusCode': splitRes.statusCode,
        'bodyType': splitRes.body.runtimeType.toString(),
      });
      if (splitRes.statusCode != 200) {
        throw _responseFailure(
          splitRes,
          'split_request_failed',
          "We couldn't generate workout splits. Please try again.",
        );
      }
      final splitData = _asStringMap(_asStringMap(splitRes.body)?['data']);
      final rawOptions = splitData?['splitOptions'];
      final options = rawOptions is List
          ? rawOptions.whereType<Map>().map((option) {
              final normalized = Map<String, dynamic>.from(option);
              final primaryId = normalized['id']?.toString().trim() ?? '';
              final fallbackId = normalized['_id']?.toString().trim() ?? '';
              final id = primaryId.isNotEmpty ? primaryId : fallbackId;
              if (id.isNotEmpty) normalized['id'] = id;
              return normalized;
            }).toList()
          : <Map<String, dynamic>>[];
      final optionsAreComplete = options.length == 3 &&
          options.every((option) {
            final id = option['id']?.toString().trim() ?? '';
            final schedule = option['weeklySchedule'];
            return id.isNotEmpty && schedule is List && schedule.isNotEmpty;
          });
      if (!optionsAreComplete) {
        throw const _WorkoutGenerationFailure(
          'split_response_incomplete',
          'The workout service returned incomplete split options. Please try again.',
        );
      }
      _logWorkoutHandoff(traceId, 'response_validated', {
        'stage': 'splits',
        'optionCount': options.length,
      });
      if (!mounted || _hasCompleted) return;
      widget.onLoadingChanged(false);
      _hasCompleted = true;
      widget.onLoaded(_workoutId!, options);
      _logWorkoutHandoff(traceId, 'state_set', {
        'stage': 'splits',
        'optionCount': options.length,
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _logWorkoutHandoff(traceId, 'render_completed', {
          'stage': 'split_selection',
          'optionCount': options.length,
        });
      });
    } catch (error) {
      _logWorkoutHandoff(traceId, 'failure', {
        'stage': 'splits',
        'reason': error.toString(),
      });
      if (!mounted) return;
      widget.onLoadingChanged(false);
      setState(() {
        _isLoading = false;
        _error = error is _WorkoutGenerationFailure
            ? error.userMessage
            : "We couldn't complete your workout yet.\nPlease try again.";
      });
    } finally {
      _requestInFlight = false;
    }
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoading && _error != null) {
      return _GenerationError(message: _error!, onRetry: _generateSplits);
    }
    final progress =
        (0.22 + (_phaseIndex * 0.14)).clamp(0.22, 0.94).toDouble();
    return _GenerationProgressView(
      headline: 'Building your recommended workout splits',
      currentPhase: _phases[_phaseIndex],
      progress: progress,
      steps: [
        _GenerationStepData(
          title: 'Reading your goals',
          detail: 'Focus, equipment, intensity, and time',
          complete: _phaseIndex >= 1,
          progress: _phaseIndex >= 1 ? 1 : progress,
        ),
        _GenerationStepData(
          title: 'Comparing split strategies',
          detail: 'Balancing training frequency and recovery',
          complete: _phaseIndex >= 3,
          progress: _phaseIndex >= 3 ? 1 : progress,
        ),
        _GenerationStepData(
          title: 'Building three recommendations',
          detail: 'Preparing distinct options for you to choose',
          complete: false,
          progress: progress,
        ),
      ],
      onHeroTap: () {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Your workout split is already being generated.'),
              duration: Duration(seconds: 2),
            ),
          );
      },
    );
  }
}

// ─── Step 7: Choose one of the generated splits ──────────────────────────────
class _SplitSelectionStep extends StatelessWidget {
  final List<Map<String, dynamic>> options;
  final String? selectedSplitId;
  final ValueChanged<String> onSelected;
  final VoidCallback onNext;

  const _SplitSelectionStep({
    required this.options,
    required this.selectedSplitId,
    required this.onSelected,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Your Workout Split',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Each option was built from your goals, equipment, intensity, and session length.',
                style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: options.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (_, index) {
              final option = options[index];
              final id = option['id'].toString();
              final selected = selectedSplitId == id;
              final schedule = option['weeklySchedule'] is List
                  ? (option['weeklySchedule'] as List)
                      .map((day) => day.toString())
                      .join(' • ')
                  : '';
              return Semantics(
                button: true,
                selected: selected,
                label:
                    '${(option['name'] ?? 'Workout Split')}. $schedule',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onSelected(id),
                  child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFFFF7A00)
                          : Colors.grey.shade200,
                      width: selected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              (option['name'] ?? 'Workout Split').toString(),
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Icon(
                            selected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: selected
                                ? const Color(0xFFFF7A00)
                                : Colors.grey.shade400,
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        schedule,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFFF57C1F),
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        (option['reason'] ?? '').toString(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 6.h,
                        children: [
                          _SplitChip(
                            '${option['estimatedSessionMinutes'] ?? 30} min',
                          ),
                          _SplitChip(
                            (option['difficulty'] ?? 'Beginner').toString(),
                          ),
                          _SplitChip(
                            '${option['daysPerWeek'] ?? schedule.split('•').length} days',
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        (option['recoveryRequirement'] ?? '').toString(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade500,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
          child: SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: selectedSplitId == null ? null : onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7A00),
                disabledBackgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: Text(
                'Build This Program',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SplitChip extends StatelessWidget {
  final String label;

  const _SplitChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFDEBD9),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: const Color(0xFFF57C1F),
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Step 8: Generate the selected complete program ──────────────────────────
class _ProgramLoadingStep extends StatefulWidget {
  final String workoutId;
  final String selectedSplitId;
  final ValueChanged<bool> onLoadingChanged;

  const _ProgramLoadingStep({
    required this.workoutId,
    required this.selectedSplitId,
    required this.onLoadingChanged,
  });

  @override
  State<_ProgramLoadingStep> createState() => _ProgramLoadingStepState();
}

class _ProgramLoadingStepState extends State<_ProgramLoadingStep> {
  Timer? _phaseTimer;
  int _phaseIndex = 0;
  bool _isLoading = true;
  bool _hasNavigated = false;
  bool _requestInFlight = false;
  String? _error;

  static const _phases = [
    'Programming each training day…',
    'Selecting approved exercises…',
    'Checking exercise order and volume…',
    'Balancing training and recovery…',
    'Validating your complete program…',
  ];

  @override
  void initState() {
    super.initState();
    _phaseTimer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
      if (mounted && _phaseIndex < _phases.length - 1) {
        setState(() => _phaseIndex++);
      }
    });
    _generateProgram();
  }

  Future<void> _generateProgram() async {
    if (_requestInFlight || _hasNavigated) return;
    final traceId = _newWorkoutTraceId('program');
    _requestInFlight = true;
    widget.onLoadingChanged(true);
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      _logWorkoutHandoff(traceId, 'request_sent', {
        'stage': 'program',
        'workoutId': widget.workoutId,
        'selectedSplitId': widget.selectedSplitId,
        'uri': ApiUrls.workoutProgram(widget.workoutId),
      });
      final response = await ApiClient.postData(
        ApiUrls.workoutProgram(widget.workoutId),
        {'selectedSplitId': widget.selectedSplitId},
        traceId: traceId,
      );
      _logWorkoutHandoff(traceId, 'response_received', {
        'stage': 'program',
        'statusCode': response.statusCode,
        'bodyType': response.body.runtimeType.toString(),
      });
      if (response.statusCode != 200) {
        throw _responseFailure(
          response,
          'program_request_failed',
          "We couldn't generate your workout program. Please try again.",
        );
      }
      final data = _asStringMap(_asStringMap(response.body)?['data']);
      final program = _asStringMap(data?['program']);
      final workouts = program?['workouts'];
      final hasCompleteWorkouts = workouts is List &&
          workouts.isNotEmpty &&
          workouts.whereType<Map>().length == workouts.length &&
          workouts.whereType<Map>().every((day) {
            final exercises = day['exercises'];
            return exercises is List && exercises.isNotEmpty;
          });
      if (data == null ||
          program == null ||
          data['aiPlan'] is! Map ||
          !hasCompleteWorkouts) {
        throw const _WorkoutGenerationFailure(
          'program_response_incomplete',
          'The workout service returned an empty or incomplete program. Please try again.',
        );
      }
      _logWorkoutHandoff(traceId, 'response_validated', {
        'stage': 'program',
        'workoutCount': workouts.length,
      });
      if (!mounted || _hasNavigated) return;
      widget.onLoadingChanged(false);
      _hasNavigated = true;
      final resultData = Map<String, dynamic>.from(data)
        ..['_workoutTraceId'] = traceId;
      _logWorkoutHandoff(traceId, 'state_set', {
        'stage': 'program',
        'workoutCount': workouts.length,
      });
      Get.offNamed(
        AppRoute.aiPlanResult,
        arguments: resultData,
      );
    } catch (error) {
      _logWorkoutHandoff(traceId, 'failure', {
        'stage': 'program',
        'reason': error.toString(),
      });
      if (!mounted) return;
      widget.onLoadingChanged(false);
      setState(() {
        _isLoading = false;
        _error = error is _WorkoutGenerationFailure
            ? error.userMessage
            : "We couldn't complete your workout yet.\nPlease try again.";
      });
    } finally {
      _requestInFlight = false;
    }
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoading && _error != null) {
      return _GenerationError(message: _error!, onRetry: _generateProgram);
    }
    final progress =
        (0.24 + (_phaseIndex * 0.17)).clamp(0.24, 0.94).toDouble();
    return _GenerationProgressView(
      headline: 'Building your personalized workout',
      currentPhase: _phases[_phaseIndex],
      progress: progress,
      steps: [
        _GenerationStepData(
          title: 'Reading your selected split',
          detail: 'Confirming schedule, duration, and intensity',
          complete: _phaseIndex >= 1,
          progress: _phaseIndex >= 1 ? 1 : progress,
        ),
        _GenerationStepData(
          title: 'Selecting approved exercises',
          detail: 'Matching movements to your goals and equipment',
          complete: _phaseIndex >= 3,
          progress: _phaseIndex >= 3 ? 1 : progress,
        ),
        _GenerationStepData(
          title: 'Validating your complete program',
          detail: 'Checking every training day before delivery',
          complete: false,
          progress: progress,
        ),
      ],
      onHeroTap: () {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Your personalized program is being built.'),
              duration: Duration(seconds: 2),
            ),
          );
      },
    );
  }
}

class _GenerationStepData {
  final String title;
  final String detail;
  final bool complete;
  final double progress;

  const _GenerationStepData({
    required this.title,
    required this.detail,
    required this.complete,
    required this.progress,
  });
}

class _GenerationProgressView extends StatelessWidget {
  static const _orange = Color(0xFFFF6B24);
  static const _green = Color(0xFF35B968);
  static const _teal = Color(0xFF21B7C5);

  final String headline;
  final String currentPhase;
  final double progress;
  final List<_GenerationStepData> steps;
  final VoidCallback onHeroTap;

  const _GenerationProgressView({
    required this.headline,
    required this.currentPhase,
    required this.progress,
    required this.steps,
    required this.onHeroTap,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).round();
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 28.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            button: true,
            label: 'Workout split generation is in progress',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onHeroTap,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22.r),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      AspectRatio(
                        aspectRatio: 1.9,
                        child: Image.asset(
                          'assets/images/generate_workout_split.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(14.w, 18.h, 14.w, 12.h),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.50),
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 16.w,
                              height: 16.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                headline,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 22.h),
          for (var index = 0; index < steps.length; index++) ...[
            _GenerationStatusCard(
              number: index + 1,
              data: steps[index],
              accent: index == steps.length - 1 ? _orange : _green,
            ),
            if (index < steps.length - 1) SizedBox(height: 12.h),
          ],
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    currentPhase,
                    key: ValueKey(currentPhase),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF6D6D6D),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  color: _orange,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6.h,
              backgroundColor: const Color(0xFFE4E4E4),
              valueColor: const AlwaysStoppedAnimation<Color>(_orange),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(Icons.auto_awesome, color: _teal, size: 14.sp),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  'Your preferences are saved and your program is being validated.',
                  style: TextStyle(
                    color: const Color(0xFF858585),
                    fontSize: 10.sp,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GenerationStatusCard extends StatelessWidget {
  final int number;
  final _GenerationStepData data;
  final Color accent;

  const _GenerationStatusCard({
    required this.number,
    required this.data,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor =
        data.complete ? const Color(0xFF28A95D) : const Color(0xFFFF6B24);
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: data.complete
              ? const Color(0xFFE7E7E7)
              : const Color(0xFFFFB48A),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.11),
              shape: BoxShape.circle,
            ),
            child: data.complete
                ? Icon(Icons.check_rounded, color: accent, size: 20.sp)
                : Text(
                    '$number',
                    style: TextStyle(
                      color: accent,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        data.title,
                        style: TextStyle(
                          color: const Color(0xFF202020),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      data.complete ? 'Complete' : 'In progress',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                Text(
                  data.detail,
                  style: TextStyle(
                    color: const Color(0xFF878787),
                    fontSize: 10.sp,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 10.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6.r),
                  child: LinearProgressIndicator(
                    value: data.progress.clamp(0, 1).toDouble(),
                    minHeight: 4.h,
                    backgroundColor: const Color(0xFFE6E6E6),
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
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

class _GenerationError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _GenerationError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh_rounded, size: 46.sp, color: const Color(0xFFFF7A00)),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.sp, color: Colors.black87, height: 1.45),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7A00),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  'Try Again',
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}