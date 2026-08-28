import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
    import 'package:flutter_screenutil/flutter_screenutil.dart';
    import 'package:get/get.dart';
    import 'package:pler_to_pler_app/core/enums/loading_state.dart';
    import 'package:pler_to_pler_app/core/utils/app_colors.dart';
    import 'package:pler_to_pler_app/features/user/workout/presentation/controllers/workout_controller.dart';
    import 'package:pler_to_pler_app/widgets/gradient_ring_loader.dart';

    const _kOrange = Color(0xFFFF6B1A);
    const _kDark   = Color(0xFF1A1A1A);
    const _kAqua1  = Color(0xFF00BFA5);
    const _kAqua2  = Color(0xFF26C6DA);

    /// Shown while the AI builds the user's workout plan.
    /// Matches the Generate Workout Split card design — white layout,
    /// athletes hero image, aqua CTA, 3-step simulation unchanged.
    class WorkoutGeneratingScreen extends StatefulWidget {
    const WorkoutGeneratingScreen({super.key});

    @override
    State<WorkoutGeneratingScreen> createState() =>
        _WorkoutGeneratingScreenState();
    }

    class _WorkoutGeneratingScreenState extends State<WorkoutGeneratingScreen>
      with TickerProviderStateMixin {
    // ── Animation controllers ─────────────────────────────────────────────
    late final AnimationController _pulseCtrl;
    late final AnimationController _fadeCtrl;
    late final Animation<double>   _pulse;
    late final Animation<double>   _fade;

    // ── Simulation state ──────────────────────────────────────────────────
    int  _step       = 0;
    bool _simDone    = false;
    bool _readyShown = false;

    static const _stepMeta = [
      (icon: Icons.search_rounded,        label: 'Analyzing your fitness goals…'),
      (icon: Icons.layers_rounded,        label: 'Building your workout structure…'),
      (icon: Icons.tune_rounded,          label: 'Personalizing your exercises…'),
    ];

    // Slightly longer for a premium feel
    static const _d1 = Duration(milliseconds: 3000);
    static const _d2 = Duration(milliseconds: 4200);

    @override
    void initState() {
      super.initState();
      _pulseCtrl = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 1100))
        ..repeat(reverse: true);
      _fadeCtrl = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 700));
      _pulse = Tween<double>(begin: 0.94, end: 1.06).animate(
          CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
      _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

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

    // ── Simulation flow (unchanged) ────────────────────────────────────────
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
        _fadeCtrl.forward();
      }
    }

    // ── Build ─────────────────────────────────────────────────────────────
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Obx(() {
          final state = WorkoutController.to.generateLoadingState;
          if (state == LoadingState.error && !_readyShown) return _buildError();
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

    // ── Simulation screen ─────────────────────────────────────────────────
    Widget _buildSimulation() {
      return Column(
        children: [
          _buildHeroBanner(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(22.w, 18.h, 22.w, 28.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // "GENERATE" label
                  Text(
                    'GENERATE',
                    style: TextStyle(
                      color: _kOrange,
                      fontSize: 12.sp,
                      fontWeight: AppFontWeight.display,
                      letterSpacing: 2.8,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // "WORKOUT SPLIT" title
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'WORKOUT\n',
                          style: TextStyle(
                            color: _kDark,
                            fontSize: 30.sp,
                            fontWeight: AppFontWeight.display,
                            height: 1.1,
                          ),
                        ),
                        TextSpan(
                          text: 'SPLIT',
                          style: TextStyle(
                            color: _kOrange,
                            fontSize: 30.sp,
                            fontWeight: AppFontWeight.display,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // Divider accent
                  Container(
                    width: 40.w,
                    height: 2.5.h,
                    decoration: BoxDecoration(
                      color: _kOrange,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'Get a custom workout plan tailored to your goals.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13.sp,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  // Aqua CTA button — loading state
                  _buildAquaButton(),
                  SizedBox(height: 24.h),
                  // Step simulation cards (unchanged logic)
                  ..._buildStepCards(),
                  SizedBox(height: 12.h),
                  _buildProgressBar(),
                ],
              ),
            ),
          ),
        ],
      );
    }

    Widget _buildHeroBanner() {
      final topPad = MediaQuery.of(context).padding.top;
      return SizedBox(
        height: 195.h,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/workout_generating_banner.png',
              fit: BoxFit.cover,
              alignment: const Alignment(0.4, 0.0),
              errorBuilder: (_, __, ___) => Container(
                color: _kOrange.withOpacity(0.12),
                child: Icon(Icons.fitness_center_rounded,
                    color: _kOrange, size: 48.sp),
              ),
            ),
            // Gradient blending into white at bottom
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.15),
                      Colors.white,
                    ],
                    stops: const [0.55, 0.80, 1.0],
                  ),
                ),
              ),
            ),
            // Top safe-area back button
            Positioned(
              top: topPad + 10.h,
              left: 16.w,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.35),
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 16.sp),
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildAquaButton() {
      final stepLabel = _step == 0
          ? 'Generate Workout Split'
          : _step == 1
              ? 'Analyzing goals…'
              : _step == 2
                  ? 'Building structure…'
                  : 'Personalizing plan…';

      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 15.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_kAqua1, _kAqua2],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(50.r),
          boxShadow: [
            BoxShadow(
              color: _kAqua1.withOpacity(0.4),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
              ),
              child: _step > 0
                  ? Padding(
                      padding: EdgeInsets.all(8.r),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(Icons.fitness_center_rounded,
                      color: Colors.white, size: 17.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                stepLabel,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: AppFontWeight.section,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18.sp),
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
          padding: EdgeInsets.only(bottom: 10.h),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: active
                  ? _kOrange.withOpacity(done ? 0.08 : 0.05)
                  : Colors.grey.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: active
                    ? _kOrange.withOpacity(done ? 0.45 : 0.25)
                    : Colors.grey.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done
                        ? _kOrange
                        : active
                            ? _kOrange.withOpacity(0.15)
                            : Colors.grey.withOpacity(0.1),
                  ),
                  child: Icon(
                    done ? Icons.check_rounded : _stepMeta[i].icon,
                    color: done
                        ? Colors.white
                        : active
                            ? _kOrange
                            : Colors.grey.shade400,
                    size: 16.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    _stepMeta[i].label,
                    style: TextStyle(
                      color: active ? _kDark : Colors.grey.shade400,
                      fontSize: 13.sp,
                      fontWeight:
                          active ? AppFontWeight.label : AppFontWeight.body,
                    ),
                  ),
                ),
                if (active && !done)
                  SizedBox(
                    width: 14.w,
                    height: 14.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.8,
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
      final pct = (_step * 33).clamp(0, 99);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11.sp)),
              Text('$pct%',
                  style: TextStyle(
                      color: _kOrange,
                      fontSize: 11.sp,
                      fontWeight: AppFontWeight.section)),
            ],
          ),
          SizedBox(height: 6.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              height: 4.h,
              child: LinearProgressIndicator(
                value: _step / _stepMeta.length,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(_kOrange),
              ),
            ),
          ),
        ],
      );
    }

    // ── Ready screen ──────────────────────────────────────────────────────
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
                  color: _kOrange.withOpacity(0.12),
                  border: Border.all(color: _kOrange, width: 2),
                ),
                child: Icon(Icons.check_rounded, color: _kOrange, size: 36.sp),
              ),
              SizedBox(height: 28.h),
              Text(
                'Your workout plan\nis ready!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _kDark,
                  fontSize: 28.sp,
                  fontWeight: AppFontWeight.display,
                  height: 1.25,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Personalized just for you',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 15.sp),
              ),
            ],
          ),
        ),
      );
    }

    // ── Error screen ──────────────────────────────────────────────────────
    Widget _buildError() {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                color: Colors.grey.shade300, size: 64.sp),
            SizedBox(height: 20.h),
            Text(
              'Could not generate your\nworkout plan',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _kDark,
                  fontSize: 22.sp,
                  fontWeight: AppFontWeight.section),
            ),
            SizedBox(height: 8.h),
            Text('Please try again',
                style:
                    TextStyle(color: Colors.grey.shade500, fontSize: 15.sp)),
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
                padding:
                    EdgeInsets.symmetric(horizontal: 36.w, vertical: 16.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [_kAqua1, _kAqua2]),
                  borderRadius: BorderRadius.circular(50.r),
                ),
                child: Text('Try Again',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: AppFontWeight.label)),
              ),
            ),
          ],
        ),
      );
    }
    }
    