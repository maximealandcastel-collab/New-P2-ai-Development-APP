import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/splash/controllers/splash_controller.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  final controller = SplashController.to;

  // List the splash images in order
  final List<String> splashImages = [
    Assets.images.appIcon.path,
    Assets.images.appIcon.path,
    Assets.images.appIcon.path,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Ensure background matches your theme
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
              width: 200.r,
              height: 200.r,
              fit: BoxFit.contain, // Changed to contain to avoid cropping icons
            ),
          );
        }),
      ),
    );
  }
}