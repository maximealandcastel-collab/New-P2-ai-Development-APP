import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/content_controller.dart';

/// Suspends the content-feed reel whenever any route is pushed on top of the
/// bottom nav bar (e.g. content details, trainer profile, workout screens)
/// while the content tab is active, and resumes when the user pops back.
///
/// Register once in GetMaterialApp(navigatorObservers: [ReelRouteObserver()]).
class ReelRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // A new screen slid on top of the bottom nav bar → suspend the reel.
    if (previousRoute?.settings.name == AppRoute.bottonNavBar) {
      _suspend();
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // Popped back to the bottom nav bar → resume if content tab is active.
    if (previousRoute?.settings.name == AppRoute.bottonNavBar) {
      _resumeIfContentTab();
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute?.settings.name == AppRoute.bottonNavBar) {
      _resumeIfContentTab();
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute?.settings.name == AppRoute.bottonNavBar &&
        newRoute?.settings.name != AppRoute.bottonNavBar) {
      _suspend();
    }
  }

  // ── helpers ─────────────────────────────────────────────────────────────

  void _suspend() {
    try {
      if (!Get.isRegistered<ContentController>()) return;
      if (!Get.isRegistered<BottomNavBarController>()) return;
      if (BottomNavBarController.to.selectedIndex !=
          BottomNavBarController.to.contentsTabIndex) return;
      unawaited(ContentController.to.reel.suspend());
    } catch (_) {}
  }

  void _resumeIfContentTab() {
    try {
      if (!Get.isRegistered<ContentController>()) return;
      if (!Get.isRegistered<BottomNavBarController>()) return;
      if (BottomNavBarController.to.selectedIndex !=
          BottomNavBarController.to.contentsTabIndex) return;
      final cc = ContentController.to;
      unawaited(cc.reel.resume(contents: cc.contents));
    } catch (_) {}
  }
}
