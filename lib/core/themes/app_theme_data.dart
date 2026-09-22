import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:pler_to_pler_app/core/themes/p2p_design_tokens.dart';
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
  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 38,
      height: 1.08,
      fontWeight: AppFontWeight.display,
      letterSpacing: -1.1,
      color: P2PColors.charcoal,
    ),
    displayMedium: TextStyle(
      fontSize: 32,
      height: 1.10,
      fontWeight: AppFontWeight.display,
      letterSpacing: -.8,
      color: P2PColors.charcoal,
    ),
    displaySmall: TextStyle(
      fontSize: 28,
      height: 1.12,
      fontWeight: AppFontWeight.title,
      letterSpacing: -.5,
      color: P2PColors.charcoal,
    ),
    headlineLarge: TextStyle(
      fontSize: 26,
      height: 1.15,
      fontWeight: AppFontWeight.title,
      letterSpacing: -.35,
      color: P2PColors.charcoal,
    ),
    headlineMedium: TextStyle(
      fontSize: 22,
      height: 1.18,
      fontWeight: AppFontWeight.title,
      letterSpacing: -.2,
      color: P2PColors.charcoal,
    ),
    headlineSmall: TextStyle(
      fontSize: 19,
      height: 1.2,
      fontWeight: AppFontWeight.section,
      color: P2PColors.charcoal,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      height: 1.22,
      fontWeight: AppFontWeight.title,
      color: P2PColors.charcoal,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      height: 1.25,
      fontWeight: AppFontWeight.section,
      color: P2PColors.charcoal,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      height: 1.25,
      fontWeight: AppFontWeight.label,
      color: P2PColors.charcoal,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      height: 1.42,
      fontWeight: AppFontWeight.body,
      color: P2PColors.charcoal,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      height: 1.4,
      fontWeight: AppFontWeight.body,
      color: P2PColors.charcoal,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      height: 1.35,
      fontWeight: AppFontWeight.body,
      color: P2PColors.secondaryText,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      height: 1.2,
      fontWeight: AppFontWeight.label,
      color: P2PColors.charcoal,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      height: 1.2,
      fontWeight: AppFontWeight.label,
      color: P2PColors.secondaryText,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      height: 1.2,
      fontWeight: AppFontWeight.body,
      color: P2PColors.secondaryText,
    ),
  );

  static ButtonStyle _primaryButtonStyle(Color primary, Color onPrimary) {
    return ElevatedButton.styleFrom(
      minimumSize: const Size(44, 48),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
      elevation: 0,
      backgroundColor: primary,
      foregroundColor: onPrimary,
      disabledBackgroundColor: primary.withValues(alpha: .35),
      disabledForegroundColor: onPrimary.withValues(alpha: .78),
      textStyle: _textTheme.labelLarge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(P2PRadius.control),
      ),
    );
  }

  static final ThemeData themeData = ThemeData(
    useMaterial3: true,
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
    scaffoldBackgroundColor: P2PColors.canvas,
    textTheme: _textTheme,
    dividerColor: P2PColors.divider,
    disabledColor: P2PColors.tertiaryText.withValues(alpha: .55),
    visualDensity: VisualDensity.standard,

    cardTheme: const CardThemeData(
      color: P2PColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: P2PColors.border),
        borderRadius: BorderRadius.all(Radius.circular(P2PRadius.card)),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: P2PColors.divider,
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: P2PColors.surface,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: _textTheme.bodyMedium?.copyWith(
        color: P2PColors.tertiaryText,
      ),
      labelStyle: _textTheme.bodyMedium?.copyWith(
        color: P2PColors.secondaryText,
      ),
      prefixIconColor: P2PColors.secondaryText,
      suffixIconColor: P2PColors.secondaryText,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(P2PRadius.control),
        borderSide: const BorderSide(color: P2PColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(P2PRadius.control),
        borderSide: const BorderSide(color: P2PColors.orange, width: 1.1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(P2PRadius.control),
        borderSide: const BorderSide(color: P2PColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(P2PRadius.control),
        borderSide: const BorderSide(color: P2PColors.error, width: 1.1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: _primaryButtonStyle(AppColors.primary, AppColors.textWhite),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: _primaryButtonStyle(AppColors.primary, AppColors.textWhite),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(44, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        foregroundColor: P2PColors.charcoal,
        side: const BorderSide(color: P2PColors.border),
        textStyle: _textTheme.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(P2PRadius.control),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(44, 44),
        foregroundColor: AppColors.primary,
        textStyle: _textTheme.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(P2PRadius.control),
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: P2PColors.surface,
      selectedColor: AppColors.primary.withValues(alpha: .12),
      disabledColor: P2PColors.softSurface,
      side: const BorderSide(color: P2PColors.border),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      labelStyle: _textTheme.labelMedium!,
      secondaryLabelStyle: _textTheme.labelMedium!.copyWith(
        color: AppColors.primary,
      ),
      showCheckmark: false,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: P2PColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(P2PRadius.sheet)),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: P2PColors.surface,
      modalBackgroundColor: P2PColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      modalElevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(P2PRadius.sheet),
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: P2PColors.charcoal,
      contentTextStyle: _textTheme.bodyMedium?.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(P2PRadius.control),
      ),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: P2PColors.canvas,
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
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
      },
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
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _primaryButtonStyle(primaryColor, onPrimary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: _primaryButtonStyle(primaryColor, onPrimary),
      ),
      textButtonTheme: TextButtonThemeData(
        style: themeData.textButtonTheme.style?.copyWith(
          foregroundColor: WidgetStatePropertyAll(primaryColor),
        ),
      ),
      inputDecorationTheme: themeData.inputDecorationTheme.copyWith(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(P2PRadius.control),
          borderSide: BorderSide(color: primaryColor, width: 1.1),
        ),
      ),
      chipTheme: themeData.chipTheme.copyWith(
        selectedColor: primaryColor.withValues(alpha: .12),
        secondaryLabelStyle: themeData.chipTheme.secondaryLabelStyle?.copyWith(
          color: primaryColor,
        ),
      ),
    );
  }
}
