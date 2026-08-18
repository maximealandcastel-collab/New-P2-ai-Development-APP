import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ─── Model ────────────────────────────────────────────────────────────────────
class ExerciseBlock {
  final String title;
  final int steps;
  final int reps;
  final int minutes;
  final String imageUrl;

  const ExerciseBlock({
    required this.title,
    required this.steps,
    required this.reps,
    required this.minutes,
    required this.imageUrl,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class CreateExercisePlanScreen2 extends StatelessWidget {
  const CreateExercisePlanScreen2({super.key});

  static const _blocks = [
    ExerciseBlock(
      title: 'The Warm-Up',
      steps: 5, reps: 1, minutes: 3,
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=200',
    ),
    ExerciseBlock(
      title: 'Push-Ups',
      steps: 3, reps: 4, minutes: 5,
      imageUrl: 'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=200',
    ),
    ExerciseBlock(
      title: 'Bent-Over Dumbbell Rows',
      steps: 4, reps: 4, minutes: 2,
      imageUrl: 'https://images.unsplash.com/photo-1581009137042-c552e485697a?w=200',
    ),
    ExerciseBlock(
      title: 'Overhead Shoulder Press',
      steps: 4, reps: 4, minutes: 3,
      imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=200',
    ),
    ExerciseBlock(
      title: 'Bicep Curls (Arms)',
      steps: 3, reps: 4, minutes: 2,
      imageUrl: 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=200',
    ),
    ExerciseBlock(
      title: 'Tricep Dips (Arms)',
      steps: 3, reps: 4, minutes: 2,
      imageUrl: 'https://images.unsplash.com/photo-1530822847156-5df684ec5933?w=200',
    ),
    ExerciseBlock(
      title: 'Cool Down',
      steps: 3, reps: 4, minutes: 1,
      imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=200',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            _AppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    _HeroBanner(),
                    SizedBox(height: 24.h),
                    _ExerciseBlocksSection(blocks: _blocks),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            ),
            _BottomActions(),
          ],
        ),
      ),
    );
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────
class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          _CircleIconButton(
            icon: Icons.chevron_left,
            onTap: () => Navigator.maybePop(context),
          ),
          Expanded(
            child: Text(
              'Create exercise plan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(width: 34.w),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34.w,
        height: 34.h,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Icon(icon, size: 20.sp, color: Colors.black87),
      ),
    );
  }
}

// ─── Hero Banner ──────────────────────────────────────────────────────────────
class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: const LinearGradient(
          colors: [Color(0xFFCFEAD8), Color(0xFFAAD6BC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Found best workout we have to offer for you',
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFF2E7D52),
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '20 min upper body exercise',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.55),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                'Customized and ready for you needs in mind',
                style: TextStyle(fontSize: 13.sp, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Exercise Blocks Section ──────────────────────────────────────────────────
class _ExerciseBlocksSection extends StatelessWidget {
  final List<ExerciseBlock> blocks;

  const _ExerciseBlocksSection({required this.blocks});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Exercise  blocks',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          ...blocks.map(
                (b) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _ExerciseCard(block: b),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Exercise Card ────────────────────────────────────────────────────────────
class _ExerciseCard extends StatelessWidget {
  final ExerciseBlock block;

  const _ExerciseCard({required this.block});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Image.network(
              block.imageUrl,
              width: 54.w,
              height: 54.h,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 54.w,
                height: 54.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.fitness_center, color: Colors.grey.shade400, size: 22.sp),
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  block.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 5.h),
                Row(
                  children: [
                    _Meta('${block.steps} steps'),
                    _Dot(),
                    _Meta('${block.reps} rep'),
                    _Dot(),
                    _Meta('${block.minutes} ${block.minutes == 1 ? "Minute" : "Minutes"}'),
                  ],
                ),
              ],
            ),
          ),

          // More
          Icon(Icons.more_vert, size: 20.sp, color: Colors.black38),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final String text;
  const _Meta(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
  );
}

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 5.w),
    child: Container(
      width: 3.w,
      height: 3.w,
      decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
    ),
  );
}

// ─── Bottom Actions ───────────────────────────────────────────────────────────
class _BottomActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
      color: const Color(0xFFF2F2F2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Start button
          GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              height: 52.h,
              decoration: BoxDecoration(
                color: const Color(0xFFFF7A00),
                borderRadius: BorderRadius.circular(14.r),
              ),
              alignment: Alignment.center,
              child: Text(
                'Start exercise plan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),

          // Add to plan button
          GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              height: 50.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.black12),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 18.sp, color: Colors.black87),
                  SizedBox(width: 8.w),
                  Text(
                    'Add to workout plan',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
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