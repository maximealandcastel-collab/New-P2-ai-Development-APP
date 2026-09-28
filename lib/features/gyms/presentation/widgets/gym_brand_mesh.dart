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

  static BoxShadow shadow(Color accent) => BoxShadow(
    color: accent.withValues(alpha: .08),
    blurRadius: 7,
    offset: const Offset(0, 2),
  );
}
