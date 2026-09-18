import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/themes/brand_colors.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  bool macroRemindersEnabled = true;

  @override
  Widget build(BuildContext context) {
    final orange = BrandColors.of(context).primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Meal Plan',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 28.h),
          children: [
            Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: const Color(0xFF101010),
                borderRadius: BorderRadius.circular(22.r),
                border: Border.all(color: orange.withOpacity(.55)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: BoxDecoration(
                          color: orange.withOpacity(.16),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Icon(
                          Icons.restaurant_menu_rounded,
                          color: orange,
                          size: 26.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'YOUR NUTRITION',
                              style: TextStyle(
                                color: orange,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: .8,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Stay on top of your macros',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Plan your meals, prep ahead, and keep your daily calories, protein, carbs, and fats visible in one place.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12.5.sp,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              'Today\'s macros',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              children: const [
                Expanded(child: _MacroCard(label: 'Calories', value: '0 / 2,000', icon: Icons.local_fire_department_rounded)),
                SizedBox(width: 8),
                Expanded(child: _MacroCard(label: 'Protein', value: '0 / 150g', icon: Icons.fitness_center_rounded)),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: const [
                Expanded(child: _MacroCard(label: 'Carbs', value: '0 / 220g', icon: Icons.grain_rounded)),
                SizedBox(width: 8),
                Expanded(child: _MacroCard(label: 'Fats', value: '0 / 70g', icon: Icons.water_drop_outlined)),
              ],
            ),
            SizedBox(height: 18.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: const Color(0xFFEAEAEA)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42.w,
                    height: 42.w,
                    decoration: BoxDecoration(
                      color: orange.withOpacity(.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.notifications_active_outlined, color: orange),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Macro reminders',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          'Get nudges to stay on track during the day.',
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: macroRemindersEnabled,
                    activeColor: orange,
                    onChanged: (value) =>
                        setState(() => macroRemindersEnabled = value),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              'Meal prep',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 10.h),
            _MealPrepTile(
              icon: Icons.free_breakfast_outlined,
              title: 'Breakfast',
              subtitle: 'Add your breakfast prep',
              color: orange,
            ),
            _MealPrepTile(
              icon: Icons.lunch_dining_outlined,
              title: 'Lunch',
              subtitle: 'Add your lunch prep',
              color: orange,
            ),
            _MealPrepTile(
              icon: Icons.dinner_dining_outlined,
              title: 'Dinner',
              subtitle: 'Add your dinner prep',
              color: orange,
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: 52.h,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                onPressed: () => Get.snackbar(
                  'Meal prep',
                  'Meal-plan creation is ready for the next backend wiring step.',
                  snackPosition: SnackPosition.BOTTOM,
                ),
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'Build My Meal Prep',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  const _MacroCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final orange = BrandColors.of(context).primary;
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: orange, size: 21.sp),
          SizedBox(height: 9.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MealPrepTile extends StatelessWidget {
  const _MealPrepTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: color.withOpacity(.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 21.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: Colors.black38),
        ],
      ),
    );
  }
}
