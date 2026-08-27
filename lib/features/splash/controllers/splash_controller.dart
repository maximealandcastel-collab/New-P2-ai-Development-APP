import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pler_to_pler_app/core/constants/app_constants.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';
import 'package:pler_to_pler_app/core/services/admin_mode_service.dart';
import 'package:pler_to_pler_app/features/profile/domain/services/profile_service.dart';

class SplashController extends GetxController with GetSingleTickerProviderStateMixin {

  static SplashController get to => Get.find();

  late AnimationController animationController;
  late Animation<double> scaleAnimation;
  late Animation<double> fadeAnimation;

  var currentImageIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();

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

  void _runSplashSequence() async {
    // ── Splash animation ──────────────────────────────────────────────────
    currentImageIndex.value = 0;
    await animationController.forward();
    await Future.delayed(const Duration(milliseconds: 200));

    await animationController.reverse();
    currentImageIndex.value = 1;
    await animationController.forward();
    await Future.delayed(const Duration(milliseconds: 200));

    await animationController.reverse();
    currentImageIndex.value = 2;
    await animationController.forward();
    await Future.delayed(const Duration(milliseconds: 500));

    // ── Auth routing ──────────────────────────────────────────────────────
    await _resolveRoute();
  }

  Future<void> _resolveRoute() async {
    // ── Privacy / Terms acceptance gate ─────────────────────────────────
    // Must be accepted before the user sees any other screen.
    // SharedPreferences key: 'privacyAccepted' (bool).
    final prefs = await SharedPreferences.getInstance();
    final privacyAccepted = prefs.getBool('privacyAccepted') ?? false;
    if (!privacyAccepted) {
      Get.offAllNamed(
        AppRoute.privacyPolicyScreen,
        arguments: {'title': 'Privacy Policy & Terms', 'key': 'privacy', 'consent': true},
      );
      return;
    }

    final isLoggedIn = LoginController.to.isLoggedIn();

    if (!isLoggedIn) {
      Get.offAllNamed(AppRoute.onboardingMainScreen);
      return;
    }

    // Check whether the user opted into "Save Login".
    // If they didn't, clear the session and send them to login.
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionPersisted = prefs.getBool('sessionPersisted') ?? false;
      if (!sessionPersisted) {
        // No saved-login consent — force fresh login.
        await LoginController.to.logout();
        return;
      }
    } catch (_) {
      // If prefs fail, fall through and allow the restored session.
    }

    // ── Restore admin mode for the owner account ─────────────────────────
    final cachedEmail = LoginController.to.getCachedEmail()?.toLowerCase() ?? '';
    if (AppConstants.ownerEmails.contains(cachedEmail)) {
      // permanent: true is required — under SmartManagement.full a non-permanent
      // instance is linked to the splash route and deleted by the offAllNamed
      // below, taking admin mode and the toggle pill with it.
      if (!Get.isRegistered<AdminModeService>()) {
        Get.put(AdminModeService(), permanent: true);
      }
      // activate() restores the admin's last saved dashboard mode (admin or user).
      await AdminModeService.to.activate();
    }

    final route = await Get.find<ProfileService>().resolveInitialRoute();
    Get.offAllNamed(route);
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}
