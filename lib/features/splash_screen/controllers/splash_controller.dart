import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:pler_to_pler_app/features/nav_bar/presentation/screens/nav_bar.dart';
import 'package:pler_to_pler_app/features/onboarding/presentation/screens/onboarding_main_screen.dart';

class SplashController extends GetxController with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> scaleAnimation;
  late Animation<double> fadeAnimation;

  // Observable index to switch between splash1, splash2, splash3
  var currentImageIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();

    // Duration is now for EACH image (e.g., 1 second each)
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOutBack),
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeIn),
    );

    _runSplashSequence();
  }

  /// Sequential animation for 3 images
  void _runSplashSequence() async {
    // 1. First Image
    currentImageIndex.value = 0;
    await animationController.forward();
    await Future.delayed(const Duration(milliseconds: 500));

    // 2. Second Image
    await animationController.reverse(); // Smooth transition out
    currentImageIndex.value = 1;
    await animationController.forward(); // Smooth transition in
    await Future.delayed(const Duration(milliseconds: 500));

    // 3. Third Image
    await animationController.reverse();
    currentImageIndex.value = 2;
    await animationController.forward();
    await Future.delayed(const Duration(milliseconds: 1000));

    // Final Navigation
    Get.offAll(() =>  OnboardingMainScreen());
    // Get.offAll(() =>  NavBar());
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}