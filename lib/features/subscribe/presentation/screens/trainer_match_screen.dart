import 'dart:math';

import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/find_trainer_model.dart';

const _kOrange = Color(0xFFFF6B1A);

/// Shows an unbiased trainer suggestion with options to retry or browse all.
/// Plays a 3-step matching animation while fetching a real trainer from the
/// API, then reveals the matched trainer and lets the user tap into their
/// profile.
class TrainerMatchScreen extends StatefulWidget {
  const TrainerMatchScreen({super.key});

  @override
  State<TrainerMatchScreen> createState() => _TrainerMatchScreenState();
}

class _TrainerMatchScreenState extends State<TrainerMatchScreen>
    with TickerProviderStateMixin {
  int _step = 0; // 0=start  1=analyzing  2=searching  3=matched
  FindTrainerModel? _matched;
  final Random _random = Random();

  late final AnimationController _pulseCtrl;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _pulse;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _pulse = Tween<double>(begin: 0.93, end: 1.07).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _runFlow();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _runFlow() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (mounted) setState(() => _step = 1);

    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _step = 2);

    final trainer = await _fetchTrainer();

    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      setState(() {
        _step = 3;
        _matched = trainer;
      });
      _fadeCtrl.forward();
    }
  }

  Future<FindTrainerModel?> _fetchTrainer() async {
    try {
      final connect = GetConnect();
      final randomPage = _random.nextInt(21) + 1;
      final resp = await connect.get(
        'https://fit-tech-ai.replit.app/api/v1/trainer'
        '?page=$randomPage&limit=50&skipPinned=true',
      );
      if (resp.isOk && resp.body != null) {
        final raw = resp.body['data'];
        if (raw is List) {
          final candidates = raw
              .whereType<Map>()
              .map((e) => FindTrainerModel.fromJson(Map<String, dynamic>.from(e)))
              .where((trainer) {
                final name = (trainer.name ?? trainer.userId?.fullName ?? '')
                    .trim()
                    .toLowerCase();
                return name != 'coach max';
              })
              .toList()
            ..shuffle(_random);
          if (candidates.isNotEmpty) return candidates.first;
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('TrainerMatchScreen fetch error: $e');
    }
    return null;
  }

  void _tryAnotherMatch() {
    if (!mounted) return;
    _fadeCtrl.reset();
    setState(() {
      _step = 0;
      _matched = null;
    });
    _runFlow();
  }

  void _goToTrainer() {
    final id = _matched?.sId;
    if (id != null && id.isNotEmpty) {
      Get.offNamed(AppRoute.trainerProfileScreen, arguments: id);
    } else {
      Get.offAllNamed(AppRoute.bottonNavBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final matched = _step >= 3;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w),
          child: Column(
            children: [
              SizedBox(height: 64.h),

              // ── Animated icon ───────────────────────────────────────
              ScaleTransition(
                scale: matched
                    ? const AlwaysStoppedAnimation(1.0)
                    : _pulse,
                child: Container(
                  width: 96.w,
                  height: 96.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      _kOrange.withOpacity(0.75),
                      _kOrange.withOpacity(0.18),
                    ]),
                    boxShadow: [
                      BoxShadow(
                        color: _kOrange.withOpacity(0.38),
                        blurRadius: 32,
                        spreadRadius: 4,
                      )
                    ],
                  ),
                  child: Icon(
                    matched
                        ? Icons.favorite_rounded
                        : Icons.manage_search_rounded,
                    color: Colors.white,
                    size: 44.sp,
                  ),
                ),
              ),

              SizedBox(height: 30.h),

              // ── Headline ────────────────────────────────────────────
              Text(
                matched ? 'Match Found! 🎉' : 'Finding Your\nPerfect Trainer',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 27.sp,
                  fontWeight: AppFontWeight.display,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                matched
                    ? 'We found someone who fits your goals'
                    : 'Scanning 1,000+ trainers in our network…',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.sp, color: Colors.white54),
              ),

              SizedBox(height: 44.h),

              // ── Step rows ───────────────────────────────────────────
              _StepRow(
                done: _step >= 1,
                active: _step == 0,
                label: 'Analyzing your fitness profile',
              ),
              SizedBox(height: 18.h),
              _StepRow(
                done: _step >= 2,
                active: _step == 1,
                label: 'Searching our trainer network',
              ),
              SizedBox(height: 18.h),
              _StepRow(
                done: _step >= 3,
                active: _step == 2,
                label: 'Locking in your perfect match',
              ),

              const Spacer(),

              // ── Matched trainer reveal ──────────────────────────────
              if (matched)
                FadeTransition(
                  opacity: _fade,
                  child: Column(
                    children: [
                      _matched != null
                          ? _TrainerCard(trainer: _matched!)
                          : _FallbackCard(),
                      SizedBox(height: 20.h),
                      GestureDetector(
                        onTap: _goToTrainer,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 17.h),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B1A), Color(0xFFFF9D5C)],
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: _kOrange.withOpacity(0.42),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Text(
                            'Meet Your Trainer  →',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: AppFontWeight.stat,
                              color: Colors.white,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton.icon(
                            onPressed: _tryAnotherMatch,
                            icon: const Icon(Icons.shuffle_rounded),
                            label: const Text('Try another'),
                            style: TextButton.styleFrom(foregroundColor: Colors.white70),
                          ),
                          SizedBox(width: 8.w),
                          TextButton.icon(
                            onPressed: () => Get.offNamed(AppRoute.findTrainerScreen),
                            icon: const Icon(Icons.grid_view_rounded),
                            label: const Text('Browse all'),
                            style: TextButton.styleFrom(foregroundColor: _kOrange),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 44.h),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Step indicator ────────────────────────────────────────────────────────
class _StepRow extends StatelessWidget {
  final bool done;
  final bool active;
  final String label;
  const _StepRow(
      {required this.done, required this.active, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          width: 30.w,
          height: 30.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? _kOrange : Colors.white10,
            border: Border.all(
              color: done
                  ? _kOrange
                  : active
                      ? Colors.white38
                      : Colors.white12,
              width: 1.5,
            ),
          ),
          child: done
              ? Icon(Icons.check_rounded, color: Colors.white, size: 16.sp)
              : active
                  ? Padding(
                      padding: EdgeInsets.all(7.r),
                      child: CircularProgressIndicator(
                        strokeWidth: 1.8,
                        color: Colors.white70,
                      ),
                    )
                  : null,
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: done
                  ? Colors.white
                  : active
                      ? Colors.white70
                      : Colors.white30,
              fontWeight: done ? AppFontWeight.label : AppFontWeight.body,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Trainer card revealed after match ─────────────────────────────────────
class _TrainerCard extends StatelessWidget {
  final FindTrainerModel trainer;
  const _TrainerCard({required this.trainer});

  @override
  Widget build(BuildContext context) {
    final name =
        trainer.name ?? trainer.userId?.fullName ?? 'Your Trainer';
    final photo = trainer.profileImage?.isNotEmpty == true
        ? trainer.profileImage
        : trainer.userId?.profilePicture;
    final spec = trainer.specialty;

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
            color: _kOrange.withOpacity(0.45), width: 1.5),
      ),
      child: Row(
        children: [
          // Photo
          Container(
            width: 68.w,
            height: 68.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _kOrange, width: 2),
            ),
            child: ClipOval(
              child: photo != null
                  ? Image.network(photo,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _avatar())
                  : _avatar(),
            ),
          ),
          SizedBox(width: 16.w),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: AppFontWeight.title,
                        color: Colors.white)),
                if (spec != null && spec.isNotEmpty) ...[
                  SizedBox(height: 5.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: _kOrange.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      spec
                          .replaceAll('_', ' ')
                          .toUpperCase(),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: AppFontWeight.label,
                        color: _kOrange,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 6.h),
                Text('Matched to your goals ✓',
                    style: TextStyle(
                        fontSize: 11.sp, color: Colors.white38)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar() => Container(
        color: _kOrange.withOpacity(0.25),
        child: Icon(Icons.person_rounded,
            color: Colors.white54, size: 34.sp),
      );
}

class _FallbackCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(22.r),
        border:
            Border.all(color: _kOrange.withOpacity(0.45), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 68.w,
            height: 68.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _kOrange.withOpacity(0.25),
              border: Border.all(color: _kOrange, width: 2),
            ),
            child: Icon(Icons.fitness_center_rounded,
                color: Colors.white70, size: 30.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              'Your trainer is ready to\nstart your journey!',
              style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: AppFontWeight.label,
                  color: Colors.white,
                  height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
