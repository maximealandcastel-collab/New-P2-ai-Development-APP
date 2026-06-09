import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/themes/app_theme_data.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder:
          (context, child) => GetMaterialApp(
        theme: AppThemeData.themeData,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoute.init,
        getPages: AppRoute.routes,
        defaultTransition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

}
