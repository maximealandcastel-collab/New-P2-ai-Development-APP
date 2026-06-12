import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/data/models/nav_item_model.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/widgets/nav_fab_widget.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/widgets/nav_item_widget.dart';
import 'package:pler_to_pler_app/features/trainer/contentPost/presentation/screens/content_post_screen.dart';
import 'package:pler_to_pler_app/features/trainer/createExercisePlan/presentation/screen/create_exercise_plan_screen.dart';
import 'package:pler_to_pler_app/features/user/find_trainer/presentation/find_trainer_screen.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';

class BottomNavBar extends StatelessWidget {
  final List<NavItemModel> navItems;

  const BottomNavBar({super.key, required this.navItems});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 8.h),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
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
                  BottomNavItem(index: 0, navItem: navItems[0]),
                  BottomNavItem(index: 1, navItem: navItems[1]),

                  // Centre FAB
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

                  BottomNavItem(index: 2, navItem: navItems[2]),
                  BottomNavItem(index: 3, navItem: navItems[3]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}