import 'dart:async';
import 'dart:math';
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
  int _step = 0; // 0-based (0..7)
  final int _totalSteps = 8;
  String? _workoutId;
  List<Map<String, dynamic>> _splitOptions = [];
  String? _selectedSplitId;

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
    if (_step < _totalSteps - 1) setState(() => _step++);
  }

  void _back() {
    if (_step == 7) {
      setState(() => _step = 6);
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
    if (_step > 0) setState(() => _step--);
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
        return _SplitLoadingStep(
          payload: _workoutPayload,
          existingWorkoutId: _workoutId,
          onWorkoutCreated: (workoutId) => _workoutId = workoutId,
          onLoaded: (workoutId, options) {
            if (!mounted) return;
            setState(() {
              _workoutId = workoutId;
              _splitOptions = options;
              _selectedSplitId = null;
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
            setState(() => _step = 7);
          },
        );
      case 7:
        return _ProgramLoadingStep(
          workoutId: _workoutId!,
          selectedSplitId: _selectedSplitId!,
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
                fontWeight: FontWeight.w500,
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
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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
  final void Function(String workoutId, List<Map<String, dynamic>> options)
      onLoaded;

  const _SplitLoadingStep({
    required this.payload,
    required this.existingWorkoutId,
    required this.onWorkoutCreated,
    required this.onLoaded,
  });

  @override
  State<_SplitLoadingStep> createState() => _SplitLoadingStepState();
}

class _SplitLoadingStepState extends State<_SplitLoadingStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _rotation;
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
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _rotation = Tween<double>(begin: 0, end: 1).animate(_ctrl);

    _phaseTimer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
      if (mounted) setState(() => _phaseIndex = (_phaseIndex + 1) % _phases.length);
    });
    _workoutId = widget.existingWorkoutId;
    _generateSplits();
  }

  Future<void> _generateSplits() async {
    if (_requestInFlight || _hasCompleted) return;
    _requestInFlight = true;
    if (_isLoading == false) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      if (_workoutId == null) {
        final createRes =
            await ApiClient.postData(ApiUrls.workoutCreate, widget.payload);
        final createdId = createRes.body is Map
            ? (createRes.body['data']?['_id'] ?? createRes.body['data']?['id'])
            : null;
        if (createdId == null) throw Exception('Workout could not be created');
        _workoutId = createdId.toString();
        widget.onWorkoutCreated(_workoutId!);
      }

      final splitRes = await ApiClient.postData(
        ApiUrls.workoutSplits(_workoutId!),
        {},
      );
      if (splitRes.statusCode == 200 && splitRes.body is Map) {
        final data = splitRes.body['data'];
        final rawOptions = data is Map ? data['splitOptions'] : null;
        if (rawOptions is List) {
          final options = rawOptions
              .whereType<Map>()
              .map((option) => Map<String, dynamic>.from(option))
              .toList();
          if (options.length == 3) {
            if (!mounted || _hasCompleted) return;
            _hasCompleted = true;
            widget.onLoaded(_workoutId!, options);
            return;
          }
        }
      }
      throw Exception('Split recommendations were incomplete');
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = "We couldn't complete your workout yet.\nPlease try again.";
      });
    } finally {
      _requestInFlight = false;
    }
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoading && _error != null) {
      return _GenerationError(message: _error!, onRetry: _generateSplits);
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Building your recommended\nworkout splits',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              height: 1.35,
            ),
          ),
          SizedBox(height: 10.h),

          // ── Cycling status message — fades between phases ───────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: Text(
              _phases[_phaseIndex],
              key: ValueKey(_phaseIndex),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
            ),
          ),

          SizedBox(height: 48.h),

          // ── Arc spinner ─────────────────────────────────────────────────
          AnimatedBuilder(
            animation: _rotation,
            builder: (_, __) => CustomPaint(
              size: Size(120.w, 120.w),
              painter: _ArcLoaderPainter(progress: _rotation.value),
            ),
          ),

          SizedBox(height: 28.h),
          Text(
            'AI is comparing the best programming strategies',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400),
          ),
        ],
      ),
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
              final id = (option['id'] ?? 'split_${index + 1}').toString();
              final selected = selectedSplitId == id;
              final schedule = option['weeklySchedule'] is List
                  ? (option['weeklySchedule'] as List)
                      .map((day) => day.toString())
                      .join(' • ')
                  : '';
              return GestureDetector(
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

  const _ProgramLoadingStep({
    required this.workoutId,
    required this.selectedSplitId,
  });

  @override
  State<_ProgramLoadingStep> createState() => _ProgramLoadingStepState();
}

class _ProgramLoadingStepState extends State<_ProgramLoadingStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _rotation;
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
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _rotation = Tween<double>(begin: 0, end: 1).animate(_ctrl);
    _phaseTimer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
      if (mounted) setState(() => _phaseIndex = (_phaseIndex + 1) % _phases.length);
    });
    _generateProgram();
  }

  Future<void> _generateProgram() async {
    if (_requestInFlight || _hasNavigated) return;
    _requestInFlight = true;
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final response = await ApiClient.postData(
        ApiUrls.workoutProgram(widget.workoutId),
        {'selectedSplitId': widget.selectedSplitId},
      );
      if (response.statusCode == 200 && response.body is Map) {
        final data = response.body['data'];
        if (data is Map && data['program'] is Map) {
          if (!mounted || _hasNavigated) return;
          _hasNavigated = true;
          Get.offNamed(
            AppRoute.aiPlanResult,
            arguments: Map<String, dynamic>.from(data),
          );
          return;
        }
      }
      throw Exception('Program response was incomplete');
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = "We couldn't complete your workout yet.\nPlease try again.";
      });
    } finally {
      _requestInFlight = false;
    }
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoading && _error != null) {
      return _GenerationError(message: _error!, onRetry: _generateProgram);
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Building your\npersonalized workout',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              height: 1.35,
            ),
          ),
          SizedBox(height: 10.h),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: Text(
              _phases[_phaseIndex],
              key: ValueKey(_phaseIndex),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
            ),
          ),
          SizedBox(height: 48.h),
          AnimatedBuilder(
            animation: _rotation,
            builder: (_, __) => CustomPaint(
              size: Size(120.w, 120.w),
              painter: _ArcLoaderPainter(progress: _rotation.value),
            ),
          ),
          SizedBox(height: 28.h),
          Text(
            'Your selected split is being programmed and validated',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400),
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
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}