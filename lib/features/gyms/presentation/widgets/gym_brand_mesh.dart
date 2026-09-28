import 'package:flutter/material.dart';

/// The P2P charcoal-to-warm-color treatment, tinted with each gym's palette.
/// Keep logos and brand tokens intact; only presentation surfaces use this mesh.
class GymBrandMesh {
  static const charcoal = Color(0xFF191A20);

  static Color _legible(Color color) {
    var end = color;
    // Partner palettes may include pale blue, yellow or white. Keep white CTA
    // labels readable without changing the facility's saved brand colors.
    while (end.computeLuminance() > .179) {
      end = Color.lerp(end, charcoal, .12)!;
    }
    return end;
  }

  static LinearGradient forColors(Color primary, Color accent) => LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      charcoal,
      _legible(Color.lerp(const Color(0xFF292327), primary, .38)!),
      _legible(Color.lerp(const Color(0xFF382B28), accent, .68)!),
    ],
    stops: const [0, .54, 1],
  );

  static BoxShadow shadow(Color accent) => BoxShadow(
    color: accent.withValues(alpha: .14),
    blurRadius: 10,
    offset: const Offset(0, 3),
  );
}
