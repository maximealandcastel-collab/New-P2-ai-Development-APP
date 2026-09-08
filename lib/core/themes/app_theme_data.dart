import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';

class AppThemeData {
  // NO fontFamily HERE — deliberate.
  //
  // This used to declare fontFamily: 'Montserrat' both on the AppBar title and
  // app-wide. Nothing was ever bundled: pubspec.yaml has no `fonts:` section at
  // all, so 'Montserrat' resolved to nothing and silently fell back. Type has
  // therefore always rendered as the platform default — SF Pro on iOS, Roboto
  // on Android (see the note in widgets/custom_text.dart).
  //
  // That matters because the client's UX reference screenshots are TestFlight
  // builds, so the look being restored *is* SF Pro. Bundling a family now would
  // move iOS away from the reference rather than toward it. Leaving the dead
  // declaration in place was worse than useless: it made every reader assume
  // the app had a configured typeface. Weight, not family, is the actual
  // problem — see core/themes/app_typography.dart.
  static final ThemeData themeData = ThemeData(
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: AppColors.textWhite,
          secondary: AppColors.primary,
          surface: AppColors.primaryBackground,
          onSurface: AppColors.textPrimary,
        ),
    scaffoldBackgroundColor: AppColors.backgroundLight,

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundLight,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontWeight: AppFontWeight.title,
        fontSize: 18.sp,
        color: AppColors.textPrimary,
      ),
      scrolledUnderElevation: 0,
      // Was Colors.white — white icons and white back arrows on a #F0F0F0
      // background. This is what tints AppBar icons, so they were invisible on
      // every screen that did not override them.
      foregroundColor: AppColors.textPrimary,
      elevation: 0,

      // Both brightness values were inverted for a light status bar.
      // Android reads statusBarIconBrightness as the ICON colour: dark icons
      // belong on a light bar. iOS reads statusBarBrightness as the BACKGROUND
      // brightness, and picks contrasting icons itself — so light background.
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: AppColors.backgroundLight,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),
  );

  /// Runtime theme for a backend-issued licensed-gym tenant.
  ///
  /// P2P remains the default theme; tenant sessions replace only presentation
  /// tokens and never infer identity from email, role, or route.
  static ThemeData forBrand({
    required Color primaryColor,
    required Color scaffoldBackground,
  }) {
    final onPrimary =
        ThemeData.estimateBrightnessForColor(primaryColor) == Brightness.dark
        ? Colors.white
        : Colors.black;
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ).copyWith(
          primary: primaryColor,
          onPrimary: onPrimary,
          secondary: primaryColor,
          surface: AppColors.primaryBackground,
          onSurface: AppColors.textPrimary,
        );

    return themeData.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      appBarTheme: themeData.appBarTheme.copyWith(
        backgroundColor: scaffoldBackground,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: scaffoldBackground,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primaryColor),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: onPrimary,
      ),
    );
  }
}
