import 'package:flutter/material.dart';
import '../../data/models/tenant_configuration.dart';
import 'package:pler_to_pler_app/core/themes/enterprise_gym_theme.dart';

/// Keep flagship layout, typography, surfaces and security UI unchanged.
/// Tenant configuration supplies validated color tokens, never arbitrary styles.
ThemeData enterpriseTheme(BuildContext context, TenantConfiguration tenant) {
  final tokens = EnterpriseGymTheme.fromColors(
    primary: tenant.primary, secondary: tenant.secondary,
    accent: tenant.accent,
  );
  final base = Theme.of(context);
  final scheme = base.colorScheme.copyWith(
    primary: tokens.primaryBrandColor,
    onPrimary: tokens.textOnGradient,
    secondary: tokens.surfaceTint,
    onSecondary: EnterpriseGymTheme.signatureBlack,
    surface: Colors.white,
    onSurface: EnterpriseGymTheme.signatureBlack,
  );
  return base.copyWith(
    colorScheme: scheme,
    extensions: [tokens],
    scaffoldBackgroundColor: const Color(0xFFFAFAFB),
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: Colors.white,
      foregroundColor: EnterpriseGymTheme.signatureBlack,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: tokens.iconAccent),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: tokens.selectedState,
        foregroundColor: tokens.textOnGradient,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: tokens.selectedState,
        foregroundColor: tokens.textOnGradient,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: tokens.selectedState,
      foregroundColor: tokens.textOnGradient,
    ),
    chipTheme: base.chipTheme.copyWith(
      selectedColor: tokens.subtleHighlight,
      secondaryLabelStyle: base.chipTheme.secondaryLabelStyle?.copyWith(
        color: tokens.iconAccent),
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: tokens.iconAccent),
      ),
    ),
  );
}
