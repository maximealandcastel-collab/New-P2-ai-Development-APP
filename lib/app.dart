import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/themes/app_theme_data.dart';
import 'package:pler_to_pler_app/core/observers/reel_route_observer.dart';
import 'package:pler_to_pler_app/widgets/keyboard_dismiss_on_tap.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (context, child) => GetMaterialApp(
        theme: AppThemeData.themeData,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoute.init,
        getPages: AppRoute.routes,
        unknownRoute: AppRoute.unknown,
        defaultTransition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 200),
        navigatorObservers: [ReelRouteObserver()],
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          final userTextScale = mediaQuery.textScaler.scale(1);

          return MediaQuery(
            data: mediaQuery.copyWith(
              // Apply the same subtle size reduction to every route, including
              // screens that still provide an explicit TextStyle font size.
              textScaler: TextScaler.linear(userTextScale * 0.95),
            ),
            child: KeyboardDismissOnTap(
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }

}
