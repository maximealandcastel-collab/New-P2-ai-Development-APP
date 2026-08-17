import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/splash/controllers/splash_controller.dart';

// Injected at build time via --dart-define=BUILD_NUMBER=$BUILD_NUMBER
const _kBuild = String.fromEnvironment('BUILD_NUMBER', defaultValue: 'dev');

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  final controller = SplashController.to;
  final List<String> splashImages = [
    Assets.images.logo.path,
    Assets.images.logo.path,
    Assets.images.logo.path,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Center(
        child: Obx(() {
          return AnimatedBuilder(
            animation: controller.animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: controller.fadeAnimation,
                child: ScaleTransition(
                  scale: controller.scaleAnimation,
                  child: child,
                ),
              );
            },
            child: Image.asset(
              splashImages[controller.currentImageIndex.value],
              width: 150.r,
              height: 150.r,
              fit: BoxFit.contain,
            ),
          );
        }),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 28.h),
        child: Center(
          child: Text(
            'P2P FIT TECH · v2.9.0 · #$_kBuild',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 11.sp,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
