import 'package:flutter/material.dart';

/// Presentation-only constants for the P2P visual system.
///
/// These tokens intentionally contain no navigation, state, data, or business
/// rules. Feature screens can adopt them incrementally without changing their
/// behavior.
class P2PColors {
  P2PColors._();

  static const orange = Color(0xFFFD7B00);
  static const orangeDeep = Color(0xFFFF5A12);
  static const charcoal = Color(0xFF171820);
  static const secondaryText = Color(0xFF727580);
  static const tertiaryText = Color(0xFF9A9CA5);
  static const canvas = Color(0xFFF7F7F8);
  static const warmCanvas = Color(0xFFFFFBF8);
  static const surface = Color(0xFFFFFFFF);
  static const softSurface = Color(0xFFFAFAFB);
  static const border = Color(0xFFE8E8EC);
  static const divider = Color(0xFFEDEDF0);
  static const success = Color(0xFF258A4B);
  static const warning = Color(0xFFBE6900);
  static const error = Color(0xFFD84747);
}

class P2PSpacing {
  P2PSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double screen = 20;
  static const double section = 24;
}

class P2PRadius {
  P2PRadius._();

  static const double control = 14;
  static const double card = 18;
  static const double sheet = 24;
  static const double pill = 999;
}

class P2PMotion {
  P2PMotion._();

  static const fast = Duration(milliseconds: 180);
  static const standard = Duration(milliseconds: 220);
  static const curve = Curves.easeOutCubic;
}

class P2PShadows {
  P2PShadows._();

  static const card = <BoxShadow>[
    BoxShadow(
      color: Color(0x0A11131A),
      blurRadius: 14,
      offset: Offset(0, 4),
    ),
  ];

  static const floating = <BoxShadow>[
    BoxShadow(
      color: Color(0x1011131A),
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
  ];
}

class P2PGradients {
  P2PGradients._();

  static const primary = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFFA13A), Color(0xFFFF711C), Color(0xFFFF4E16)],
  );
}
