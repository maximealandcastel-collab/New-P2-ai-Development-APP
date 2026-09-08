import 'package:flutter/material.dart';
import '../../data/models/tenant_configuration.dart';

ThemeData enterpriseTheme(BuildContext context, TenantConfiguration t) {
  final dark =
      ThemeData.estimateBrightnessForColor(t.primary) == Brightness.dark;
  return ThemeData(
    brightness: dark ? Brightness.dark : Brightness.light,
    fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
    scaffoldBackgroundColor: t.primary,
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: t.accent,
          brightness: dark ? Brightness.dark : Brightness.light,
        ).copyWith(
          primary: t.accent,
          secondary: t.secondary,
          onPrimary:
              ThemeData.estimateBrightnessForColor(t.accent) == Brightness.dark
              ? Colors.white
              : Colors.black,
          onSecondary:
              ThemeData.estimateBrightnessForColor(t.secondary) ==
                  Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
  );
}
