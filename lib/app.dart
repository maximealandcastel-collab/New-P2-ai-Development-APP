import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/theme/theme.dart';
import 'package:pler_to_pler_app/routes/app_routes.dart';
import 'core/bindings/controller_binder.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          theme: AppTheme.instance.lightTheme,
          themeMode: ThemeMode.light,
          debugShowCheckedModeBanner: false,
          defaultTransition: Transition.cupertino,
          transitionDuration: const Duration(milliseconds: 260),
          initialRoute: AppRoute.init,
          getPages: AppRoute.routes,
          initialBinding: ControllerBinder(),

        );
      },
    );
  }

}
