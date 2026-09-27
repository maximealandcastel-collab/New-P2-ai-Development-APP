import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pler_to_pler_app/core/themes/app_theme_data.dart';
import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:pler_to_pler_app/core/themes/p2p_design_tokens.dart';

void main() {
  test('phone text scale stays compact without shrinking small screens further', () {
    expect(P2PResponsive.textScale(0.85), 0.85);
    expect(P2PResponsive.textScale(1), 1);
    expect(P2PResponsive.textScale(1.15), 1.05);
    expect(P2PResponsive.maxContentWidth, 440);
  });

  test('global theme uses the restrained P2P presentation tokens', () {
    final theme = AppThemeData.themeData;

    expect(theme.scaffoldBackgroundColor, P2PColors.canvas);
    expect(theme.textTheme.bodyMedium?.fontWeight, AppFontWeight.body);
    expect(theme.textTheme.titleLarge?.fontWeight, AppFontWeight.title);
    expect(theme.cardTheme.elevation, 0);
    expect(theme.cardTheme.surfaceTintColor, Colors.transparent);
    expect(theme.inputDecorationTheme.fillColor, P2PColors.surface);
    expect(theme.chipTheme.showCheckmark, isFalse);
    expect(theme.bottomSheetTheme.surfaceTintColor, Colors.transparent);
  });

  test('tenant theme changes brand accents without changing the system', () {
    const tenantColor = Color(0xFF145CA8);
    const tenantCanvas = Color(0xFFF5F8FC);
    final theme = AppThemeData.forBrand(
      primaryColor: tenantColor,
      scaffoldBackground: tenantCanvas,
    );

    expect(theme.colorScheme.primary, tenantColor);
    expect(theme.scaffoldBackgroundColor, tenantCanvas);
    expect(theme.textTheme.bodyMedium, AppThemeData.themeData.textTheme.bodyMedium);
    expect(theme.cardTheme, AppThemeData.themeData.cardTheme);
    final focusedBorder = theme.inputDecorationTheme.focusedBorder;
    expect(focusedBorder, isA<OutlineInputBorder>());
    expect(
      (focusedBorder as OutlineInputBorder).borderSide.color,
      tenantColor,
    );
  });
}
