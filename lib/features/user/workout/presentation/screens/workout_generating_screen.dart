import 'package:flutter/material.dart';
    import 'package:flutter_screenutil/flutter_screenutil.dart';
    import 'package:get/get.dart';
    import 'package:pler_to_pler_app/core/enums/loading_state.dart';
    import 'package:pler_to_pler_app/core/utils/app_colors.dart';
    import 'package:pler_to_pler_app/features/user/workout/presentation/controllers/workout_controller.dart';
    import 'package:pler_to_pler_app/widgets/gradient_ring_loader.dart';

    const _kDark   = Color(0xFF0A0A0A);
    const _kOrange = Color(0xFFFF6B1A);

    /// Shown while the AI builds the user's workout plan.
    /// Hero image banner + 3-step animated simulation.
    class WorkoutGeneratingScreen extends StatefulWidget {
    const WorkoutGeneratingScreen({super.key});

    @override
    State<WorkoutGeneratingScreen> createState() =>
        _WorkoutGeneratingScreenState();
    }

    class _WorkoutGeneratingScreenState extends State<WorkoutGeneratingScreen>
      with TickerProviderStateMixin {
    late final AnimationController _pulseCtrl;
    late final AnimationController _fadeCtrl;
    late final AnimationController _shimmerCtrl;
    late final Animation<double>   _pulse;
    late final Animation<double>   _fade;
    late final Animation<double>   _shimmer;

    int  _step       = 0;
    bool _simDone    = false;
    bool _readyShown = false;

    static const _stepMeta = [
      (icon: Icons.search_rounded,        label: 'Analyzing your fitness goals…'),
      (icon: Icons.layers_rounded,        label: 'Building your workout structure…'),
      (icon: Icons.tune_rounded,          label: 'Personalizing your exercises…'),
    ];

    // Longer durations for a more premium feel
    static const _d1 = Duration(milliseconds: 2600);
    static const _d2 = Duration(milliseconds: 3400);

    @override
    void initState() {
      super.initState();

      _pulseCtrl = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 1100))
        ..repeat(reverse: true);
      _fadeCtrl = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 700));
      _shimmerCtrl = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 1800))
        ..repeat();

      _pulse = Tween<double>(begin: 0.94, end: 1.06).animate(
          CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
      _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
      _shimmer = Tween<double>(begin: -1.5, end: 1.5).animate(
          CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut));

      WidgetsBinding.instance.addPostFrameCallback((_) {
        WorkoutController.to.generateWorkout();
        _runSimulation();
      });
    }

    @override
    void dispose() {
      _pulseCtrl.dispose();
      _fadeCtrl.dispose();
      _shimmerCtrl.dispose();
      super.dispose();
    }

    Future<void> _runSimulation() async {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() => _step = 1);
      await Future<void>.delayed(_d1);
      if (!mounted) return;
      setState(() => _step = 2);
      await Future<void>.delayed(_d2);
      if (!mounted) return;
      setState(() => _step = 3);
      _simDone = true;
      _tryReveal();
    }

    void _tryReveal() {
      if (!_simDone || _readyShown || !mounted) return;
      final state = WorkoutController.to.generateLoadingState;
      if (state == LoadingState.loaded || state == LoadingState.error) {
        setState(() => _readyShown = true);
        _pulseCtrl.stop();
        _shimmerCtrl.stop();
        _fadeCtrl.forward();
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: _kDark,
        body: Obx(() {
          final state = WorkoutController.to.generateLoadingState;

          if (state == LoadingState.error && !_readyShown) {
            return _buildError();
          }
          if ((state == LoadingState.loaded || state == LoadingState.error) &&
              _simDone && !_readyShown) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _tryReveal());
          }
          if (_readyShown) {
            return state == LoadingState.error ? _buildError() : _buildReady();
          }
          return _buildSimulation();
        }),
      );
    }

    // ── Simulation screen ──────────────────────────────────────────────────
    Widget _buildSimulation() {
      return Column(
        children: [
          // Hero image banner
          _buildHeroBanner(),

          // Step progress
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Generating your plan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Personalized to your goals and fitness level',
                    style: TextStyle(color: Colors.white54, fontSize: 13.sp),
                  ),
                  SizedBox(height: 28.h),
                  ..._buildStepCards(),
                  SizedBox(height: 24.h),
                  _buildProgressBar(),
                  SizedBox(height: 20.h),
                  Center(
                    child: Text(
                      'This usually takes 30 – 90 seconds',
                      style: TextStyle(color: Colors.white24, fontSize: 12.sp),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    Widget _buildHeroBanner() {
      return SizedBox(
        height: 220.h,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Banner image
            Image.asset(
              'assets/images/workout_generating_banner.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: _kOrange.withOpacity(0.15)),
            ),
            // Gradient overlay — dark at top for status bar, heavy at bottom for blend
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _kDark.withOpacity(0.55),
                    _kDark.withOpacity(0.1),
                    _kDark.withOpacity(0.7),
                    _kDark,
                  ],
                  stops: const [0.0, 0.3, 0.75, 1.0],
                ),
              ),
            ),
            // Pulsing loader centered in banner
            Center(
              child: ScaleTransition(
                scale: _pulse,
                child: SizedBox(
                  width: 88.w,
                  height: 88.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      GradientRingLoader(size: 88.r, strokeWidth: 5),
                      Container(
                        width: 52.w,
                        height: 52.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _kDark.withOpacity(0.7),
                          border: Border.all(
                              color: _kOrange.withOpacity(0.5), width: 1.5),
                        ),
                        child: Icon(
                          Icons.fitness_center_rounded,
                          color: _kOrange,
                          size: 24.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Safe area top padding
            Positioned(
              top: MediaQuery.of(context).padding.top + 12.h,
              left: 20.w,
              child: Row(
                children: [
                  Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _kOrange,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'P2P FIT TECH AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                    ),
                  ),
                ],
              ),
            ),
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
          padding: EdgeInsets.only(bottom: 12.h),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: active
                  ? _kOrange.withOpacity(done ? 0.14 : 0.08)
                  : Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: active
                    ? _kOrange.withOpacity(done ? 0.5 : 0.35)
                    : Colors.white.withOpacity(0.07),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done
                        ? _kOrange
                        : active
                            ? _kOrange.withOpacity(0.18)
                            : Colors.white.withOpacity(0.06),
                  ),
                  child: Icon(
                    done
                        ? Icons.check_rounded
                        : _stepMeta[i].icon,
                    color: done
                        ? Colors.white
                        : active
                            ? _kOrange
                            : Colors.white30,
                    size: 18.sp,
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
                      valueColor: AlwaysStoppedAnimation(_kOrange),
                    ),
                  ),
              ],
            ),
          ),
        );
      });
    }

    Widget _buildProgressBar() {
      final progress = _step / _stepMeta.length;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress',
                  style: TextStyle(color: Colors.white38, fontSize: 11.sp)),
              Text('${(_step * 33).clamp(0, 99)}%',
                  style: TextStyle(
                      color: _kOrange,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              height: 4.h,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withOpacity(0.08),
                valueColor: AlwaysStoppedAnimation(_kOrange),
              ),
            ),
          ),
        ],
      );
    }

    // ── Ready screen ───────────────────────────────────────────────────────
    Widget _buildReady() {
      return FadeTransition(
        opacity: _fade,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kOrange.withOpacity(0.15),
                  border: Border.all(color: _kOrange, width: 2),
                ),
                child: Icon(Icons.check_rounded, color: _kOrange, size: 36.sp),
              ),
              SizedBox(height: 28.h),
              Text(
                'Your workout plan
is ready!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Personalized just for you',
                style: TextStyle(color: Colors.white54, fontSize: 15.sp),
              ),
            ],
          ),
        ),
      );
    }

    // ── Error screen ───────────────────────────────────────────────────────
    Widget _buildError() {
      return Padding(
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
                _shimmerCtrl.repeat();
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
      );
    }
    }
    