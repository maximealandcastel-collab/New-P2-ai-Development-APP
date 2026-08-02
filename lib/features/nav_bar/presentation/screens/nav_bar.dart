import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/helpers/prefs_helper.dart';
import 'package:pler_to_pler_app/custom_assets/assets.gen.dart';
import 'package:pler_to_pler_app/features/home/home_screen.dart';
import 'package:pler_to_pler_app/features/home/user_home_screen.dart';
import 'package:pler_to_pler_app/features/nav_bar/controllers/nav_bar_controller.dart';
import 'package:pler_to_pler_app/features/nav_bar/presentation/screens/widgets/nav_fab_widget.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/presentation/screens/trainer_home_schedule_screen.dart';
import 'package:pler_to_pler_app/features/user/contents/presentations/feed_screen.dart';
import 'package:pler_to_pler_app/features/user/find_trainer/presentation/find_trainer_screen.dart';
import 'package:pler_to_pler_app/features/user/progress/presentation/exercise_summary_screen.dart';
import 'package:pler_to_pler_app/features/user/workout_pan/presentation/workout_plan_screen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';
import '../../../trainer/assignedPlan/presentation/screen/assigned_plan_screen.dart';
import '../../../trainer/clients/presentation/screens/clients_screen.dart';
import '../../../trainer/contentPost/presentation/screens/content_post_screen.dart';
import '../../../trainer/contents/presentation/screens/contents_screen.dart';
import '../../../trainer/createExercisePlan/presentation/screen/create_exercise_plan_screen.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  final NavBarController _navBarController = Get.find<NavBarController>();
  String _role = '';

  List<Widget> get _screens => [
    _role == 'Trainer' ? const HomeScreen() : const UserHomeScreen(),
    _role == 'Trainer' ? const ClientsScreen() : const WorkoutPlansScreen(),
    _role == 'Trainer' ? const ContentsScreen() : const FeedScreen(),
    _role == 'Trainer' ? const ScheduleScreen() : const ExerciseSummaryScreen(),
  ];

  List<Map<String, dynamic>> get _navItems => [
    {"icon": Assets.icons.home.path, "label": "Home"},
    {"icon": _role == 'Trainer' ? Assets.icons.clients.path : Assets.icons.schedules.path,
      "label": _role == 'Trainer' ? "Clients" : "Plans"},
    {"icon": Assets.icons.contents.path, "label": "Contents"},
    {"icon": _role == 'Trainer' ? Assets.icons.schedules.path : Assets.icons.progress.path,
      "label": _role == 'Trainer' ? "Schedules" : "Progress"
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await PrefsHelper.getString('role');
    setState(() => _role = role ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Scaffold(
        backgroundColor: AppColors.backgroundLight,

        // ✅ Use extendBody so body renders behind the nav bar.
        //    The blur/transparent nav bar will show body content through it.
        extendBody: true,

        // ✅ Body is just the IndexedStack — no Column wrapping needed.
        body: IndexedStack(
          index: _navBarController.selectedIndex.value,
          children: _screens,
        ),

        // ✅ Nav bar goes in bottomNavigationBar, NOT inside body.
        bottomNavigationBar: _buildNavBar(context),
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 8.h),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: BackdropFilter(
            // ✅  Blur sigma 10–16 — NOT 320 (that caused the grey wash)
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                // Slight white tint so icons are readable
                color: Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    offset: const Offset(0, 4),
                    blurRadius: 6,
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(
                vertical: 12.h,
                horizontal: 12.w,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0),
                  _buildNavItem(1),

                  // Centre FAB button
                  GestureDetector(
                    onTap: () {
                      NavFabWidget.instance.show(
                        context,
                        onPostContent: () =>
                            Get.to(() => const ContentPostScreen()),
                        onAddSchedule: () =>
                            Get.to(() => const FindTrainerScreen()),
                        onAddExercise: () =>
                            Get.to(() => const CreateExercisePlanScreen()),
                      );
                    },
                    child: Assets.icons.addButton.svg(
                      height: 48.h,
                      width: 48.w,
                    ),
                  ),

                  _buildNavItem(2),
                  _buildNavItem(3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final bool isSelected =
        _navBarController.selectedIndex.value == index;

    return GestureDetector(
      onTap: () => _navBarController.onChange(index),
      behavior: HitTestBehavior.opaque, // ✅ larger tap area
      child: SizedBox(
        width: 56.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              _navItems[index]["icon"],
              width: 24.w,
              height: 24.h,
              colorFilter: ColorFilter.mode(
                isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(height: 3.h),
            CustomText(
              text: _navItems[index]["label"],
              fontSize: 11.sp,
              fontWeight:
              isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}