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
    return Obx(() {
      final items = controller.navItems;
      return Scaffold(
        extendBody: true,
        backgroundColor: AppColors.backgroundLight,
        body: IndexedStack(
          index: controller.selectedIndex,
          children: items.map((e) => e.screen).toList(),
        ),
        bottomNavigationBar: BottomNavBar(navItems: items),
      );
    });
  }
}
