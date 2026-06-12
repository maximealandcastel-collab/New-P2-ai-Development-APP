import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';

class CustomSearchTheme {

  CustomSearchTheme._();

  static CustomSearchTheme instance = CustomSearchTheme._();


  ThemeData get appBarTheme => _appBarTheme;




   final ThemeData _appBarTheme = ThemeData(
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 60,
      titleSpacing: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: const BorderSide(color: Color(0xFFE6E6E6)),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: InputBorder.none,
      hintStyle: TextStyle(
        fontSize: 16.sp,
        color: AppColors.textSecondary,
      ),
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      constraints: BoxConstraints(maxHeight: 44.h),
    ),

    textTheme: TextTheme(
      titleLarge: TextStyle(
        fontSize: 16.sp,
        color: AppColors.textSecondary,
      ),
    ),

    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.textSecondary,
    ),

    scaffoldBackgroundColor: AppColors.backgroundLight,
  );
}