import 'package:flutter/material.dart';
import '../../data/models/tenant_configuration.dart';

/// Keep flagship layout, typography, surfaces and security UI unchanged.
/// Tenant configuration supplies validated color tokens, never arbitrary styles.
ThemeData enterpriseTheme(BuildContext context, TenantConfiguration tenant) {
  Color foreground(Color color) => color.computeLuminance() > 0.179
      ? Colors.black
      : Colors.white;
  final base = Theme.of(context);
  final scheme = base.colorScheme.copyWith(
    primary: tenant.primary,
    onPrimary: foreground(tenant.primary),
    secondary: tenant.accent,
    onSecondary: foreground(tenant.accent),
  );
  return base.copyWith(
    colorScheme: scheme,
    progressIndicatorTheme: ProgressIndicatorThemeData(color: tenant.primary),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: tenant.primary,
        foregroundColor: scheme.onPrimary,
      ),
    ),
  );
}
