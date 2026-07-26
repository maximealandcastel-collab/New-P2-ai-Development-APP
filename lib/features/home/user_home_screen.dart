import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:pler_to_pler_app/routes/app_routes.dart';
import 'package:pler_to_pler_app/widgets/app_bar.dart';

// ─────────────────────────────────────────────────────────────────────────────
// User Home — matches the original app layout:
// greeting bar → Daily workout progress (week strip) → AI "Set your goal"
// banner → Gyms near you → Today's overview → Today's assigned workout
// ─────────────────────────────────────────────────────────────────────────────

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FeedAppBar(),
              _SectionTitle('Daily workout progress'),
              const _WeekStrip(),
              const _AiGoalBanner(),
              const _GymsCard(),
              SizedBox(height: 16.h),
              const _EmptyDataCard(title: "Today's overview"),
              SizedBox(height: 16.h),
              const _EmptyDataCard(title: "Today's assigned workout"),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Section title ────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );
  }
}

// ─── Week strip (Mon 20 … Sat 25) ────────────────────────────────────────────
class _WeekStrip extends StatelessWidget {
  const _WeekStrip();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return SizedBox(
      height: 82.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: labels.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (context, i) {
          final day = monday.add(Duration(days: i));
          final isToday = day.day == now.day && day.month == now.month;
          return Container(
            width: 62.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: isToday
                  ? Border.all(color: const Color(0xFFFF6B35), width: 1.4)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  '${day.day}',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── AI goal banner ──────────────────────────────────────────────────────────
class _AiGoalBanner extends StatelessWidget {
  const _AiGoalBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 148.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B7A99), Color(0xFF9AA5B8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -6.w,
            bottom: 0,
            top: 0,
            child: Icon(Icons.fitness_center,
                size: 110.sp, color: Colors.white.withOpacity(0.15)),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Leverage power of ai to find\nworkout that fits your needs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 14.h),
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoute.workoutFinderFlow),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 26.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Text(
                      'Set your goal',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

// ─── Gyms near you ───────────────────────────────────────────────────────────
class _GymsCard extends StatelessWidget {
  const _GymsCard();

  static const _gyms = [
    ('StrongFit Downtown', '0.8 km away'),
    ('Iron Pulse Gym', '1.2 km away'),
    ('Core Strength Hub', '2.0 km away'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Gyms',
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black)),
              Text('Near Gym',
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFF6B35))),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 150.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _gyms.length,
              separatorBuilder: (_, __) => SizedBox(width: 12.w),
              itemBuilder: (context, i) {
                final (name, distance) = _gyms[i];
                return SizedBox(
                  width: 140.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          height: 70.h,
                          width: double.infinity,
                          color: const Color(0xFF2B2B2B),
                          child: Icon(Icons.fitness_center,
                              color: Colors.white38, size: 30.sp),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black)),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 13.sp, color: Colors.black54),
                          SizedBox(width: 2.w),
                          Text(distance,
                              style: TextStyle(
                                  fontSize: 12.sp, color: Colors.black54)),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9E9E9E),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text('Disable',
                            style: TextStyle(
                                fontSize: 11.sp, color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty-state data card (Today's overview / assigned workout) ─────────────
class _EmptyDataCard extends StatelessWidget {
  final String title;
  const _EmptyDataCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black)),
          SizedBox(height: 20.h),
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 32.r,
                  backgroundColor: const Color(0xFFEDEDED),
                  child: Icon(Icons.assignment_outlined,
                      size: 28.sp, color: Colors.black45),
                ),
                SizedBox(height: 14.h),
                Text('Not enough data to view',
                    style:
                        TextStyle(fontSize: 14.sp, color: Colors.black54)),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoute.workoutFinderFlow),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 14.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                    color: const Color(0xFFDDDDDD),
                    style: BorderStyle.solid),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recommendation',
                      style: TextStyle(
                          fontSize: 12.sp, color: Colors.black45)),
                  SizedBox(height: 2.h),
                  Text('Set your workout goal to get data',
                      style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
