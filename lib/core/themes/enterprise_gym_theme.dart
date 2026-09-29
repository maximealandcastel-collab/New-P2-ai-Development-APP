import 'package:flutter/material.dart';

/// Presentation tokens for one licensed gym. Logo sources are deliberately
/// outside this class: theme colors must never be applied to an image.
@immutable
class EnterpriseGymTheme extends ThemeExtension<EnterpriseGymTheme> {
  static const signatureBlack = Color(0xFF171820);
  static const neutralGraphite = Color(0xFF565B63);

  const EnterpriseGymTheme({
    required this.primaryBrandColor,
    required this.secondaryBrandColor,
    required this.meshStart,
    required this.meshMid,
    required this.meshEnd,
    required this.selectedState,
    required this.iconAccent,
    required this.surfaceTint,
    required this.borderTint,
    required this.textOnGradient,
    required this.subtleHighlight,
  });

  final Color primaryBrandColor;
  final Color secondaryBrandColor;
  final Color meshStart;
  final Color meshMid;
  final Color meshEnd;
  final Color selectedState;
  final Color iconAccent;
  final Color surfaceTint;
  final Color borderTint;
  final Color textOnGradient;
  final Color subtleHighlight;

  static bool _chromatic(Color color) {
    final hsv = HSVColor.fromColor(color);
    return hsv.saturation > .20 && hsv.value > .17;
  }

  static Color _restrained(Color color) {
    final hsv = HSVColor.fromColor(color);
    // Preserve hue. Only very bright colors are moderated on UI surfaces.
    return hsv.withValue(hsv.value.clamp(.20, .82).toDouble())
        .withSaturation(hsv.saturation.clamp(0.0, .88).toDouble()).toColor();
  }

  factory EnterpriseGymTheme.fromColors({
    required Color? primary,
    Color? secondary,
    Color? accent,
  }) {
    final raw = primary == null || primary.computeLuminance() > .97
        ? null
        : primary;
    // A black parent palette with a real colored accent (such as KMF) uses
    // the colored accent as the recognizable gym hue.
    final source = raw != null && _chromatic(raw)
        ? raw
        : accent != null && _chromatic(accent)
            ? accent
            : secondary != null && _chromatic(secondary)
                ? secondary
                : raw ?? neutralGraphite;
    final brand = _restrained(source);
    var readable = brand;
    while (readable.computeLuminance() > .18) {
      readable = Color.lerp(readable, signatureBlack, .10)!;
    }
    final start = Color.lerp(signatureBlack, brand, .09)!;
    return EnterpriseGymTheme(
      primaryBrandColor: brand,
      secondaryBrandColor: secondary ?? brand,
      meshStart: start,
      meshMid: Color.lerp(start, readable, .56)!,
      meshEnd: readable,
      selectedState: readable,
      iconAccent: readable,
      surfaceTint: Color.lerp(Colors.white, brand, .045)!,
      borderTint: Color.lerp(Colors.white, brand, .16)!,
      textOnGradient: Colors.white,
      subtleHighlight: Color.lerp(Colors.white, brand, .075)!,
    );
  }

  static EnterpriseGymTheme of(BuildContext context) =>
      Theme.of(context).extension<EnterpriseGymTheme>() ??
      EnterpriseGymTheme.fromColors(
        primary: Theme.of(context).colorScheme.primary,
      );

  LinearGradient get ctaGradient => LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [meshStart, meshMid, meshEnd],
    stops: const [0, .44, 1],
  );
  LinearGradient get activeNavGradient => ctaGradient;
  LinearGradient get activePillGradient => ctaGradient;

  @override
  EnterpriseGymTheme copyWith({
    Color? primaryBrandColor, Color? secondaryBrandColor,
    Color? meshStart, Color? meshMid, Color? meshEnd,
    Color? selectedState, Color? iconAccent, Color? surfaceTint,
    Color? borderTint, Color? textOnGradient, Color? subtleHighlight,
  }) => EnterpriseGymTheme(
    primaryBrandColor: primaryBrandColor ?? this.primaryBrandColor,
    secondaryBrandColor: secondaryBrandColor ?? this.secondaryBrandColor,
    meshStart: meshStart ?? this.meshStart,
    meshMid: meshMid ?? this.meshMid,
    meshEnd: meshEnd ?? this.meshEnd,
    selectedState: selectedState ?? this.selectedState,
    iconAccent: iconAccent ?? this.iconAccent,
    surfaceTint: surfaceTint ?? this.surfaceTint,
    borderTint: borderTint ?? this.borderTint,
    textOnGradient: textOnGradient ?? this.textOnGradient,
    subtleHighlight: subtleHighlight ?? this.subtleHighlight,
  );

  @override
  EnterpriseGymTheme lerp(ThemeExtension<EnterpriseGymTheme>? other, double t) {
    if (other is! EnterpriseGymTheme) return this;
    Color blend(Color a, Color b) => Color.lerp(a, b, t)!;
    return EnterpriseGymTheme(
      primaryBrandColor: blend(primaryBrandColor, other.primaryBrandColor),
      secondaryBrandColor: blend(secondaryBrandColor, other.secondaryBrandColor),
      meshStart: blend(meshStart, other.meshStart),
      meshMid: blend(meshMid, other.meshMid),
      meshEnd: blend(meshEnd, other.meshEnd),
      selectedState: blend(selectedState, other.selectedState),
      iconAccent: blend(iconAccent, other.iconAccent),
      surfaceTint: blend(surfaceTint, other.surfaceTint),
      borderTint: blend(borderTint, other.borderTint),
      textOnGradient: blend(textOnGradient, other.textOnGradient),
      subtleHighlight: blend(subtleHighlight, other.subtleHighlight),
    );
  }
}
