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
import 'package:pler_to_pler_app/routes/app_routes.dart';
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
  String _viewMode = 'admin';

  bool get _isAdmin => _role.toLowerCase() == 'admin';
  bool get _isTrainer => _role.toLowerCase() == 'trainer';
  bool get _isAdminView => _isAdmin && _viewMode == 'admin';

  List<Widget> get _screens => _isAdminView || _isTrainer
      ? [
          const HomeScreen(),
          const ClientsScreen(),
          const ContentsScreen(),
          const ScheduleScreen(),
        ]
      : [
          const UserHomeScreen(),
          const WorkoutPlansScreen(),
          const FeedScreen(),
          const ExerciseSummaryScreen(),
        ];

  List<Map<String, dynamic>> get _navItems => [
    {"icon": Assets.icons.home.path, "label": "Home"},
    {
      "icon": _isAdminView || _isTrainer
          ? Assets.icons.clients.path
          : Assets.icons.schedules.path,
      "label": _isAdminView || _isTrainer ? "Clients" : "Plans",
    },
    {"icon": Assets.icons.contents.path, "label": "Contents"},
    {
      "icon": _isAdminView || _isTrainer
          ? Assets.icons.schedules.path
          : Assets.icons.progress.path,
      "label": _isAdminView || _isTrainer ? "Schedules" : "Progress",
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await PrefsHelper.getString('role');
    final savedViewMode = await PrefsHelper.getString('p2p_view_mode');
    if (!mounted) return;
    setState(() {
      _role = role;
      _viewMode = role.toLowerCase() == 'admin' &&
              (savedViewMode == 'user' || savedViewMode == 'admin')
          ? savedViewMode
          : role.toLowerCase() == 'admin'
              ? 'admin'
              : role;
    });
    _navBarController.onChange(0);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final screens = _screens;
      final safeIndex = _navBarController.selectedIndex.value
          .clamp(0, screens.length - 1);
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,

        // ✅ Use extendBody so body renders behind the nav bar.
        //    The blur/transparent nav bar will show body content through it.
        extendBody: true,

        // ✅ Body is just the IndexedStack — no Column wrapping needed.
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: _isAdmin ? 76.h : 0),
              child: IndexedStack(
                index: safeIndex,
                children: screens,
              ),
            ),
            if (_isAdmin)
              Positioned(
                top: 10.h,
                left: 24.w,
                right: 24.w,
                child: _buildViewToggle(),
              ),
          ],
        ),

        // ✅ Nav bar goes in bottomNavigationBar, NOT inside body.
        bottomNavigationBar: _buildNavBar(context),
      );
    });
  }

  Widget _buildViewToggle() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 44.h,
          padding: EdgeInsets.all(4.r),
          decoration: BoxDecoration(
            color: const Color(0xFF171717),
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildViewToggleOption(
                label: 'Admin',
                value: 'admin',
                icon: Icons.dashboard_customize_outlined,
              ),
              _buildViewToggleOption(
                label: 'User',
                value: 'user',
                icon: Icons.person_outline_rounded,
              ),
            ],
          ),
        ),
        SizedBox(height: 5.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.62),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Text(
            'Viewing as ${_viewMode == 'admin' ? 'Admin' : 'User'}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildViewToggleOption({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final selected = _viewMode == value;
    return Expanded(
      child: GestureDetector(
        onTap: selected
            ? null
            : () async {
                setState(() {
                  _viewMode = value;
                  _navBarController.onChange(0);
                });
                await PrefsHelper.setString('p2p_view_mode', value);
              },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: double.infinity,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16.sp,
                color: selected ? Colors.white : Colors.white70,
              ),
              SizedBox(width: 5.w),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white70,
                  fontSize: 13.sp,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
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
                        onAddSchedule: () {
                          if (_isAdminView || _isTrainer) {
                            _navBarController.onChange(3);
                          } else {
                            Get.to(() => const FindTrainerScreen());
                          }
                        },
                        onAddExercise: () {
                          if (_isAdminView || _isTrainer) {
                            Get.to(() => const CreateExercisePlanScreen());
                          } else {
                            Get.toNamed(AppRoute.workoutFinderFlow);
                          }
                        },
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
            SizedBox(height: 4.h),
            CustomText(
              text: _navItems[index]["label"],
              fontSize: 10.5.sp,
              fontWeight:
              isSelected ? FontWeight.w500 : FontWeight.w400,
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