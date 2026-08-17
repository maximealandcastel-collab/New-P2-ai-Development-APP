import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/controllers/workout_controller.dart';
import 'package:pler_to_pler_app/widgets/gradient_ring_loader.dart';

const _kDark   = Color(0xFF0D0D0D);
const _kOrange = Color(0xFFFF6B1A);

/// Shown while the AI builds the user's workout plan.
/// 3-step animated simulation — same UX pattern as TrainerMatchScreen.
class WorkoutGeneratingScreen extends StatefulWidget {
  const WorkoutGeneratingScreen({super.key});

  @override
  State<WorkoutGeneratingScreen> createState() =>
      _WorkoutGeneratingScreenState();
}

class _WorkoutGeneratingScreenState extends State<WorkoutGeneratingScreen>
    with TickerProviderStateMixin {
  // ── Animation controllers ───────────────────────────────────────────────
  late final AnimationController _pulseCtrl;
  late final AnimationController _fadeCtrl;
  late final Animation<double>   _pulse;
  late final Animation<double>   _fade;

  // ── Simulation state ────────────────────────────────────────────────────
  /// 0 = idle  1 = analyzing  2 = building  3 = personalizing  4 = revealed
  int  _step       = 0;
  bool _simDone    = false;
  bool _readyShown = false;

  // ── Step metadata ───────────────────────────────────────────────────────
  static const _stepMeta = [
    (icon: Icons.search_rounded,       label: 'Analyzing your fitness goals…'),
    (icon: Icons.layers_rounded, label: 'Building your workout structure…'),
    (icon: Icons.tune_rounded,         label: 'Personalizing your exercises…'),
  ];

  // ── Timing (step 3 holds until API responds) ────────────────────────────
  static const _d1 = Duration(milliseconds: 1400);
  static const _d2 = Duration(milliseconds: 2200);

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 950))
      ..repeat(reverse: true);
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _pulse = Tween<double>(begin: 0.92, end: 1.08).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    // Kick off the API call and the simulation in parallel.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WorkoutController.to.generateWorkout();
      _runSimulation();
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── Simulation flow ─────────────────────────────────────────────────────
  Future<void> _runSimulation() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _step = 1);

    await Future<void>.delayed(_d1);
    if (!mounted) return;
    setState(() => _step = 2);

    await Future<void>.delayed(_d2);
    if (!mounted) return;
    setState(() => _step = 3);

    // Step 3 holds until the API finishes — then _tryReveal() is called by Obx.
    _simDone = true;
    _tryReveal();
  }

  void _tryReveal() {
    if (!_simDone || _readyShown || !mounted) return;
    final state = WorkoutController.to.generateLoadingState;
    if (state == LoadingState.loaded || state == LoadingState.error) {
      setState(() => _readyShown = true);
      _pulseCtrl.stop();
      _fadeCtrl.forward();
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kDark,
      body: SafeArea(
        child: Obx(() {
          final state = WorkoutController.to.generateLoadingState;

          // Hard error before sim completes — show retry immediately.
          if (state == LoadingState.error && !_readyShown) {
            return _buildError();
          }

          // API finished — trigger reveal once sim is also done.
          if ((state == LoadingState.loaded || state == LoadingState.error) &&
              _simDone && !_readyShown) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _tryReveal());
          }

          if (_readyShown) {
            return state == LoadingState.error
                ? _buildError()
                : _buildReady();
          }

          return _buildSimulation();
        }),
      ),
    );
  }

  // ── Simulation screen ───────────────────────────────────────────────────
  Widget _buildSimulation() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Column(
        children: [
          SizedBox(height: 60.h),

          // Pulsing ring + dumbbell icon
          ScaleTransition(
            scale: _pulse,
            child: SizedBox(
              width: 148.w,
              height: 148.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GradientRingLoader(size: 148.r, strokeWidth: 6),
                  Container(
                    width: 82.w,
                    height: 82.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _kOrange.withOpacity(0.12),
                      border: Border.all(
                          color: _kOrange.withOpacity(0.4), width: 1.5),
                    ),
                    child: Icon(
                      Icons.fitness_center_rounded,
                      color: _kOrange,
                      size: 36.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 44.h),

          Text(
            'Building your\nworkout plan',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              height: 1.28,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Personalized to your goals and fitness level',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 15.sp),
          ),

          SizedBox(height: 48.h),

          // Animated step cards
          ..._buildStepCards(),

          const Spacer(),

          Text(
            'This usually takes 30 – 90 seconds',
            style: TextStyle(color: Colors.white30, fontSize: 12.sp),
          ),
          SizedBox(height: 28.h),
        ],
      ),
    );
  }

  List<Widget> _buildStepCards() {
    return List.generate(_stepMeta.length, (i) {
      final stepNum = i + 1;
      final active  = _step >= stepNum;
      final done    = _step > stepNum;

      return Padding(
        padding: EdgeInsets.only(bottom: 14.h),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: active
                ? _kOrange.withOpacity(done ? 0.16 : 0.09)
                : Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: active
                  ? _kOrange.withOpacity(done ? 0.65 : 0.30)
                  : Colors.white.withOpacity(0.07),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 320),
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active
                      ? (done ? _kOrange : _kOrange.withOpacity(0.22))
                      : Colors.white.withOpacity(0.07),
                ),
                child: Icon(
                  done ? Icons.check_rounded : _stepMeta[i].icon,
                  color: active ? Colors.white : Colors.white24,
                  size: 19.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  _stepMeta[i].label,
                  style: TextStyle(
                    color: active ? Colors.white : Colors.white38,
                    fontSize: 14.sp,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (active && !done)
                SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: const AlwaysStoppedAnimation(_kOrange),
                  ),
                ),
              if (done)
                Icon(Icons.check_circle_rounded, color: _kOrange, size: 18.sp),
            ],
          ),
        ),
      );
    });
  }

  // ── Ready reveal ────────────────────────────────────────────────────────
  Widget _buildReady() {
    return FadeTransition(
      opacity: _fade,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 108.w,
                height: 108.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    _kOrange.withOpacity(0.85),
                    _kOrange.withOpacity(0.35),
                  ]),
                  boxShadow: [
                    BoxShadow(
                      color: _kOrange.withOpacity(0.45),
                      blurRadius: 36,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(Icons.check_rounded, color: Colors.white, size: 46.sp),
              ),
              SizedBox(height: 36.h),
              Text(
                'Your workout\nis ready! 💪',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34.sp,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                'Built specifically for your goals',
                style: TextStyle(color: Colors.white54, fontSize: 15.sp),
              ),
              SizedBox(height: 56.h),
              GestureDetector(
                onTap: Get.back,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 44.w, vertical: 18.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B1A), Color(0xFFFF8C42)],
                    ),
                    borderRadius: BorderRadius.circular(50.r),
                    boxShadow: [
                      BoxShadow(
                        color: _kOrange.withOpacity(0.42),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Text(
                    'View My Workout',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Error state ─────────────────────────────────────────────────────────
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.white30, size: 64.sp),
            SizedBox(height: 20.h),
            Text(
              'Could not generate your\nworkout plan',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8.h),
            Text('Please try again',
                style: TextStyle(color: Colors.white54, fontSize: 15.sp)),
            SizedBox(height: 36.h),
            GestureDetector(
              onTap: () {
                setState(() {
                  _step       = 0;
                  _simDone    = false;
                  _readyShown = false;
                });
                _fadeCtrl.reset();
                _pulseCtrl.repeat(reverse: true);
                _runSimulation();
                WorkoutController.to.generateWorkout();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 36.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: _kOrange,
                  borderRadius: BorderRadius.circular(50.r),
                ),
                child: Text('Try Again',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
