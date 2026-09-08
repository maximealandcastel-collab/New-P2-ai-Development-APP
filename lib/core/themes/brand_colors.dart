import 'package:flutter/material.dart';

/// Derived accent colors for custom controls, illustrations, and gradients.
/// Read during build so changing the session theme rebuilds these surfaces too.
class BrandColors {
  const BrandColors._(this.primary, this.onPrimary);

  factory BrandColors.of(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return BrandColors._(scheme.primary, scheme.onPrimary);
  }

  final Color primary;
  final Color onPrimary;
  Color get soft => primary.withValues(alpha: 0.10);
  Color get border => primary.withValues(alpha: 0.25);
  Color get light => Color.lerp(primary, Colors.white, 0.35)!;
  Color get dark => Color.lerp(primary, Colors.black, 0.25)!;
  Color get headerStart => Color.lerp(primary, Colors.black, 0.65)!;
  Color get headerEnd => Color.lerp(primary, Colors.black, 0.35)!;
}
