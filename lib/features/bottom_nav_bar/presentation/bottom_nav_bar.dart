import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/widgets/bottom_nav_bar.dart';

class BottomNavBarMain extends StatelessWidget {
  const BottomNavBarMain({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = BottomNavBarController.to;
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.backgroundLight,
      body: Obx(
        () => IndexedStack(
          index: controller.selectedIndex,
          children: controller.navItems.map((e) => e.screen).toList(),
        ),
      ),
      bottomNavigationBar: BottomNavBar(navItems: controller.navItems),
    );
  }
}
