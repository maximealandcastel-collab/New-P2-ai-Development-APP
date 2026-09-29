import 'package:flutter/material.dart';
import 'package:pler_to_pler_app/core/themes/enterprise_gym_theme.dart';

/// A slight tonal shift on top of each gym's actual brand color.
/// This affects actions only; logos, photos and page backgrounds stay native.
class GymBrandMesh {
  static const charcoal = EnterpriseGymTheme.signatureBlack;

  static LinearGradient forColors(Color primary, Color accent) =>
      EnterpriseGymTheme.fromColors(
        primary: primary, secondary: accent, accent: accent,
      ).ctaGradient;

  /// A small, high-contrast accent on the gym detail entry action.
  static LinearGradient detailAction(Color brand) =>
      EnterpriseGymTheme.fromColors(primary: brand).ctaGradient;

  /// Keep white CTA labels readable even on a franchise's bright color.
  static Color darkBrand(Color brand) =>
      EnterpriseGymTheme.fromColors(primary: brand).iconAccent;

  /// KMF's logo-first detail page uses a small sunny edge, with its green
  /// still dominant and a charcoal finish. Other gyms use detailAction.
  static LinearGradient sunnyAction(Color brand) => detailAction(brand);

  static BoxShadow sunnyShadow(Color brand) => BoxShadow(
    color: brand.withValues(alpha: .11),
    blurRadius: 13,
    offset: const Offset(0, 3),
  );

  /// Barely visible surface shade: the gym's existing background remains
  /// the source color, with no replacement of its logo or brand palette.
  static LinearGradient surface(Color background, Color accent) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.lerp(background, charcoal, .035)!,
      background,
      Color.lerp(background, accent, .025)!,
    ],
    stops: const [0, .56, 1],
  );

  static BoxShadow shadow(Color accent) => BoxShadow(
    color: accent.withValues(alpha: .08),
    blurRadius: 7,
    offset: const Offset(0, 2),
  );

  /// Dark franchise colors can use their own secondary color for the faint
  /// edge light. White accents fall back to the primary brand color.
  static BoxShadow franchiseShadow(Color primary, Color accent) => shadow(
    primary.computeLuminance() < .08 && accent.computeLuminance() < .85
        ? accent : primary,
  );
}
