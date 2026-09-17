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
  int _step = 0; // 0-based (0..6)
  final int _totalSteps = 7;

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
  final Set<String> _trainingStyles = {};

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

  void _skip() {
    if (_step == 0) _trainingStyles.clear();
    _next();
  }

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
        return _TrainingStylesStep(
          selectedStyles: _trainingStyles,
          onToggle: (value) => setState(() {
            _trainingStyles.contains(value)
                ? _trainingStyles.remove(value)
                : _trainingStyles.add(value);
          }),
          onNext: _next,
          onSkip: _skip,
        );
      case 1:
        return _SelectionStep(
          title: 'Choose Your Goals',
          subtitle: 'What you want to achieve from the workout',
          options: _goals,
          selected: _selectedGoals,
          onToggle: (v) => setState(() =>
          _selectedGoals.contains(v) ? _selectedGoals.remove(v) : _selectedGoals.add(v)),
          onNext: _next,
        );
      case 2:
        return _SelectionStep(
          title: 'Which areas do you want to focus on?',
          subtitle: 'Which area of your body you want to improve from the exercise.',
          options: _areas,
          selected: _selectedAreas,
          onToggle: (v) => setState(() =>
          _selectedAreas.contains(v) ? _selectedAreas.remove(v) : _selectedAreas.add(v)),
          onNext: _next,
        );
      case 3:
        return _SelectionStep(
          title: 'Where are you working out today?',
          subtitle: 'What you want to achieve from the workout',
          options: _locations,
          selected: _selectedLocations,
          onToggle: (v) => setState(() =>
          _selectedLocations.contains(v) ? _selectedLocations.remove(v) : _selectedLocations.add(v)),
          onNext: _next,
        );
      case 4:
        return _SelectionStep(
          title: 'What equipment do you have available?',
          subtitle: "What workout you can do with available equipment's",
          options: _equipment,
          selected: _selectedEquipment,
          onToggle: (v) => setState(() =>
          _selectedEquipment.contains(v) ? _selectedEquipment.remove(v) : _selectedEquipment.add(v)),
          onNext: _next,
        );
      case 5:
        return _IntensityDurationStep(
          intensity: _intensity,
          duration: _duration,
          onIntensityChanged: (v) => setState(() => _intensity = v),
          onDurationChanged: (v) => setState(() => _duration = v),
          onNext: _next,
        );
      case 6:
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
            "workoutPreferences": {
              "trainingStyles": _trainingStyles.toList(),
            },
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

// ─── Figma Step 1: Training-style filter ──────────────────────────────────────
class _TrainingStylesStep extends StatefulWidget {
  final Set<String> selectedStyles;
  final ValueChanged<String> onToggle;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _TrainingStylesStep({
    required this.selectedStyles,
    required this.onToggle,
    required this.onNext,
    required this.onSkip,
  });

  @override
  State<_TrainingStylesStep> createState() => _TrainingStylesStepState();
}

class _TrainingStylesStepState extends State<_TrainingStylesStep> {
  String _query = '';
  String _category = 'All';

  static const _categories = ['All', 'Combat', 'Strength', 'Cardio', 'Flexibility'];
  static const List<Map<String, dynamic>> _styles = [
    {'id':'boxing','title':'Boxing / Combat','subtitle':'Boxing, MMA, Kickboxing','icon':Icons.sports_mma,'category':'Combat'},
    {'id':'calisthenics','title':'Calisthenics','subtitle':'Bodyweight, Street Workout','icon':Icons.accessibility_new,'category':'Strength'},
    {'id':'weight_lifting','title':'Weight Lifting','subtitle':'Strength, Hypertrophy','icon':Icons.fitness_center,'category':'Strength'},
    {'id':'wrestling','title':'Wrestling','subtitle':'Technique, Conditioning','icon':Icons.sports_kabaddi,'category':'Combat'},
    {'id':'hiit','title':'HIIT','subtitle':'High Intensity Intervals','icon':Icons.flash_on,'category':'Cardio'},
    {'id':'yoga','title':'Yoga','subtitle':'Mind-Body, Recovery','icon':Icons.self_improvement,'category':'Flexibility'},
    {'id':'pilates','title':'Pilates','subtitle':'Core Strength, Stability','icon':Icons.sports_gymnastics,'category':'Flexibility'},
    {'id':'mobility','title':'Mobility','subtitle':'Movement, Flexibility','icon':Icons.accessibility,'category':'Flexibility'},
    {'id':'functional_training','title':'Functional Training','subtitle':'Real-World Movement','icon':Icons.widgets,'category':'Strength'},
    {'id':'cardio','title':'Cardio','subtitle':'Endurance, Conditioning','icon':Icons.monitor_heart,'category':'Cardio'},
    {'id':'sports_performance','title':'Sports Performance','subtitle':'Speed, Agility, Power','icon':Icons.emoji_events,'category':'Cardio'},
    {'id':'rehabilitation','title':'Rehabilitation','subtitle':'Pain Relief, Recovery','icon':Icons.medical_services,'category':'Flexibility'},
  ];

  @override
  Widget build(BuildContext context) {
    final visible = _styles.where((style) {
      final text = '${style['title']} ${style['subtitle']}'.toLowerCase();
      return text.contains(_query.toLowerCase()) &&
          (_category == 'All' || style['category'] == _category);
    }).toList();

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            children: [
              SizedBox(height: 8.h),
              Text(
                'What type of training\ndo you want to do?',
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: AppFontWeight.section,
                  height: 1.12,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Choose one or more styles. We’ll customize your workouts, trainers, and content.',
                style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600, height: 1.4),
              ),
              SizedBox(height: 18.h),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44.h,
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22.r),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, size: 18.sp, color: Colors.black38),
                          SizedBox(width: 7.w),
                          Expanded(
                            child: TextField(
                              onChanged: (value) => setState(() => _query = value),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Search training styles...',
                                hintStyle: TextStyle(fontSize: 12.sp, color: Colors.black38),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    height: 44.h,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22.r),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _category,
                        style: TextStyle(fontSize: 12.sp, color: Colors.black87),
                        items: _categories.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => _category = value);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: visible.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10.h,
                  crossAxisSpacing: 10.w,
                  childAspectRatio: .76,
                ),
                itemBuilder: (_, index) {
                  final style = visible[index];
                  final id = style['id'] as String;
                  return _TrainingStyleCard(
                    title: style['title'] as String,
                    subtitle: style['subtitle'] as String,
                    icon: style['icon'] as IconData,
                    imagePath: 'assets/images/training_styles/$id.png',
                    selected: widget.selectedStyles.contains(id),
                    onTap: () => widget.onToggle(id),
                  );
                },
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 14.h),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: widget.onNext,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFFFF6B2C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13.r)),
                  ),
                  child: Text('Next', style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: AppFontWeight.label)),
                ),
              ),
              TextButton(
                onPressed: widget.onSkip,
                child: const Text('Skip for now', style: TextStyle(color: Color(0xFFFF6B2C))),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TrainingStyleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String imagePath;
  final bool selected;
  final VoidCallback onTap;

  const _TrainingStyleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.imagePath,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: title,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13.r),
            border: Border.all(color: selected ? const Color(0xFFFF6B2C) : Colors.transparent, width: 2),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black.withOpacity(.52), BlendMode.darken),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 7.w,
                top: 7.h,
                child: Container(
                  width: 19.w,
                  height: 19.w,
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFFFF6B2C) : Colors.black26,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.3),
                  ),
                  child: selected ? Icon(Icons.check, color: Colors.white, size: 12.sp) : null,
                ),
              ),
              Positioned(
                left: 7.w,
                right: 7.w,
                bottom: 7.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 17.sp),
                    SizedBox(height: 3.h),
                    Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 10.5.sp, height: 1.05, fontWeight: AppFontWeight.label)),
                    SizedBox(height: 2.h),
                    Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white70, fontSize: 7.5.sp, height: 1.05)),
                  ],
                ),
              ),
            ],
          ),
        ),
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

  // ── Phase messages cycle while AI works ──────────────────────────────────
  static const _phases = [
    'Analyzing your goals…',
    'Building your workout split…',
    'Selecting the right exercises…',
    'Calibrating intensity & duration…',
    'Optimizing for your body…',
    'Almost ready…',
  ];
  int _phaseIndex = 0;
  Timer? _phaseTimer;

  // Minimum time (ms) before navigating — makes it feel like real AI work.
  static const _minDisplayMs = 5000;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _rotation = Tween<double>(begin: 0, end: 1).animate(_ctrl);

    // Advance phase label every 1.4 s
    _phaseTimer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
      if (mounted) setState(() => _phaseIndex = (_phaseIndex + 1) % _phases.length);
    });

    _generatePlan();
  }

  Future<void> _generatePlan() async {
    final sw = Stopwatch()..start();
    Map<String, dynamic>? plan;
    try {
      final createRes =
          await ApiClient.postData(ApiUrls.workoutCreate, widget.payload);
      final workoutId = createRes.body is Map
          ? (createRes.body['data']?['_id'] ?? createRes.body['data']?['id'])
          : null;
      if (workoutId != null) {
        final genRes = await ApiClient.postData(
            ApiUrls.workoutGenerate(workoutId.toString()), {});
        if (genRes.statusCode == 200 && genRes.body is Map) {
          final data = genRes.body['data'];
          if (data is Map<String, dynamic>) {
            plan = (data['aiPlan'] ?? data['plan'] ?? data)
                as Map<String, dynamic>?;
          }
        }
      }
    } catch (_) {
      // Backend unreachable — fall through to error handling below.
    }

    // ── Enforce minimum display time so it never feels instant / fake ──────
    final remaining = _minDisplayMs - sw.elapsedMilliseconds;
    if (remaining > 0) await Future.delayed(Duration(milliseconds: remaining));

    if (!mounted || _hasNavigated) return;
    if (plan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not generate your plan. Please check your connection and try again.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      setState(() {});
      return;
    }
    _hasNavigated = true;
    Get.offNamed(AppRoute.aiPlanResult, arguments: plan);
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Finding your perfect\nworkout plan',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: AppFontWeight.section,
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
            'AI is crafting your personalized plan',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400),
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