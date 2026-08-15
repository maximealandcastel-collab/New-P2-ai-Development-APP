import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';
import 'package:pler_to_pler_app/core/services/admin_mode_service.dart';
import 'package:pler_to_pler_app/features/profile/domain/services/profile_service.dart';

class SplashController extends GetxController with GetSingleTickerProviderStateMixin {

  static SplashController get to => Get.find();

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
    await Future.delayed(const Duration(milliseconds: 200));

    // 2. Second Image
    await animationController.reverse(); // Smooth transition out
    currentImageIndex.value = 1;
    await animationController.forward(); // Smooth transition in
    await Future.delayed(const Duration(milliseconds: 200));

    // 3. Third Image
    await animationController.reverse();
    currentImageIndex.value = 2;
    await animationController.forward();
    await Future.delayed(const Duration(milliseconds: 500));

    if (LoginController.to.isLoggedIn()) {
      // Re-activate admin mode for the owner account on every app restart.
      // This ensures trainer+admin nav is always shown after a cold launch.
      const _ownerEmails = {'pmoney78q@gmail.com'};
      final _cachedEmail = LoginController.to.getCachedEmail()?.toLowerCase() ?? '';
      if (_ownerEmails.contains(_cachedEmail)) {
        if (!Get.isRegistered<AdminModeService>()) {
          Get.put(AdminModeService());
        }
        AdminModeService.to.activate();
      }
      final route = await Get.find<ProfileService>().resolveInitialRoute();
      Get.offAllNamed(route);
    } else {
      Get.offAllNamed(AppRoute.onboardingMainScreen);
    }
    //Get.offAllNamed(AppRoute.subscribeSelectScreen);
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}