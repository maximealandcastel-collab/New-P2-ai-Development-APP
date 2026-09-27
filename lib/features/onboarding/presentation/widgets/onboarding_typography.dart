import 'package:flutter/material.dart';

class OnboardingTypography {
  OnboardingTypography._();

  static double _responsiveSize(
    BuildContext context, {
    required double factor,
    required double minimum,
    required double maximum,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    return (width * factor).clamp(minimum, maximum).toDouble();
  }

  static TextStyle headline(BuildContext context) => TextStyle(
        fontSize: _responsiveSize(
          context,
          factor: 0.081,
          minimum: 29,
          maximum: 34,
        ),
        fontWeight: FontWeight.w500,
        color: const Color(0xFF111111),
        height: 1.12,
        letterSpacing: -0.5,
      );

  static TextStyle description(BuildContext context) => TextStyle(
        fontSize: _responsiveSize(
          context,
          factor: 0.039,
          minimum: 14,
          maximum: 16,
        ),
        fontWeight: FontWeight.w400,
        color: const Color(0xFF6B6B70),
        height: 1.4,
        letterSpacing: -0.1,
      );

  static TextStyle action(BuildContext context) => TextStyle(
        fontSize: _responsiveSize(
          context,
          factor: 0.039,
          minimum: 14,
          maximum: 16,
        ),
        fontWeight: FontWeight.w400,
        height: 1.15,
      );

  static TextStyle cardTitle(BuildContext context) => TextStyle(
        fontSize: _responsiveSize(
          context,
          factor: 0.038,
          minimum: 13,
          maximum: 15,
        ),
        fontWeight: FontWeight.w500,
        color: const Color(0xFF171820),
        height: 1.2,
      );

  static TextStyle cardDescription(BuildContext context) => TextStyle(
        fontSize: _responsiveSize(
          context,
          factor: 0.032,
          minimum: 11,
          maximum: 13,
        ),
        fontWeight: FontWeight.w400,
        color: const Color(0xFF5F5F63),
        height: 1.35,
      );
}
