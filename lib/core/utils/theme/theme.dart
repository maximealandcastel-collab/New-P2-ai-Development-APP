import 'package:flutter/material.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';

class AppTheme {

  AppTheme._();

  static AppTheme instance = AppTheme._();

  final lightTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.backgroundLight,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.textPrimary, // RefreshIndicator color
    ),
    appBarTheme: const AppBarTheme(
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.backgroundLight,
    ),
  );
}