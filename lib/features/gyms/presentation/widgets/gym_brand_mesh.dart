import 'package:flutter/material.dart';

/// A slight tonal shift on top of each gym's actual brand color.
/// This affects actions only; logos, photos and page backgrounds stay native.
class GymBrandMesh {
  static const charcoal = Color(0xFF191A20);

  static LinearGradient forColors(Color primary, Color accent) => LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color.lerp(primary, charcoal, .10)!,
      primary,
      Color.lerp(primary, accent, .14)!,
    ],
    stops: const [0, .62, 1],
  );

  /// A small, high-contrast accent on the gym detail entry action.
  static LinearGradient detailAction(Color brand) {
    var end = brand;
    while (end.computeLuminance() > .179) {
      end = Color.lerp(end, charcoal, .12)!;
    }
    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [charcoal, Color.lerp(charcoal, end, .45)!, end],
    );
  }

  /// Keep white CTA labels readable even on a franchise's bright color.
  static Color darkBrand(Color brand) {
    var color = brand;
    while (color.computeLuminance() > .179) {
      color = Color.lerp(color, charcoal, .12)!;
    }
    return color;
  }

  /// KMF's logo-first detail page uses a small sunny edge, with its green
  /// still dominant and a charcoal finish. Other gyms use detailAction.
  static LinearGradient sunnyAction(Color brand) => LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color.lerp(darkBrand(brand), brand, .18)!,
      darkBrand(brand),
      Color.lerp(darkBrand(brand), charcoal, .78)!,
    ],
    stops: const [0, .4, 1],
  );

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
}
