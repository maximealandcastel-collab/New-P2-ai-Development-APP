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
          factor: 0.094,
          minimum: 34,
          maximum: 40,
        ),
        fontWeight: FontWeight.w500,
        color: const Color(0xFF111111),
        height: 1.08,
        letterSpacing: -0.4,
      );

  static TextStyle description(BuildContext context) => TextStyle(
        fontSize: _responsiveSize(
          context,
          factor: 0.045,
          minimum: 17,
          maximum: 19,
        ),
        fontWeight: FontWeight.w400,
        color: const Color(0xFF6B6B70),
        height: 1.42,
        letterSpacing: -0.1,
      );

  static TextStyle action(BuildContext context) => TextStyle(
        fontSize: _responsiveSize(
          context,
          factor: 0.041,
          minimum: 15,
          maximum: 17,
        ),
        fontWeight: FontWeight.w400,
        height: 1.15,
      );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: Colors.black,
    height: 1.2,
  );

  static const TextStyle cardDescription = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Color(0xFF5F5F63),
    height: 1.35,
  );
}