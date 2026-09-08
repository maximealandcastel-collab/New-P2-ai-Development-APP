import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Recolors brand accents in bundled SVGs without tinting their neutral detail.
class BrandColorMapper extends ColorMapper {
  const BrandColorMapper(this.primary);

  final Color primary;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    return switch (color.toARGB32()) {
      0xFFFD7B00 => primary,
      0xFFFEC28A => Color.lerp(primary, Colors.white, 0.55)!,
      0xFFE86100 => Color.lerp(primary, Colors.black, 0.15)!,
      _ => color,
    };
  }

  @override
  bool operator ==(Object other) =>
      other is BrandColorMapper && other.primary == primary;

  @override
  int get hashCode => primary.hashCode;
}
