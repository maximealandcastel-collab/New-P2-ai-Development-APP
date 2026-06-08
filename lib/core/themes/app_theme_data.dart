import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';

class AppThemeData {

  static final ThemeData themeData = ThemeData(
    scaffoldBackgroundColor: AppColors.backgroundLight,

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundLight,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 20.sp,
        fontFamily: 'Montserrat',
      ),
      scrolledUnderElevation: 0,
      foregroundColor: Colors.white,
      elevation: 0,

      // Status Bar Color
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: AppColors.backgroundLight,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),

    fontFamily: 'Montserrat',
  );
}
