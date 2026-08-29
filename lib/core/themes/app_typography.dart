import 'package:flutter/material.dart';

/// The single source of truth for type weight in this app.
///
/// WHY THIS EXISTS
/// The client's brief is that a newer build "lost the premium feel" through
/// heavier typography. Counting every FontWeight literal in lib/ showed the
/// problem precisely:
///
///     w600  329      w700  205      bold   73
///     w800   54      w900   17      w400/normal  40
///
/// Forty regular-weight declarations against 776 at medium or heavier. Body
/// copy is almost never set at regular weight — the client's own
/// "Smarter care. effortless workflow" screenshot shows the headline *and* the
/// paragraph beneath it both rendered heavy. The reference dashboard shows the
/// intended relationship instead: a ~w700 section title over regular-weight
/// grey body text. Restoring that contrast is the whole job.
///
/// WHY A CONSTANT CLASS AND NOT ThemeData.textTheme
/// Wiring `AppTextTheme` into `ThemeData` looks like the obvious fix, but it is
/// very nearly a no-op here: essentially all text in this app renders through
/// `CustomText` or a literal `TextStyle(...)`, and both build an explicit style
/// that overrides the ambient theme. A theme-level text scale would only ever
/// reach bare `Text()` widgets and Material's own components. The weights are
/// passed at call sites, so the scale has to be usable at call sites.
///
/// WHY NO fontFamily
/// Nothing is bundled in `pubspec.yaml`, so type resolves to the platform
/// default — SF Pro on iOS, Roboto on Android. The client's reference
/// screenshots are TestFlight builds, so *they are SF Pro*: introducing a
/// bundled family would move iOS away from the look being restored, not toward
/// it. Deliberate decision, 2026-08-28. Do not add a fontFamily here.
class AppFontWeight {
  AppFontWeight._();

  /// Screen-dominating display text. Was w800/w900.
  static const FontWeight display = FontWeight.w700;

  /// Screen titles and card titles. Was w700/w800.
  static const FontWeight title = FontWeight.w600;

  /// Section headers within a screen. Was w700/w800.
  static const FontWeight section = FontWeight.w600;

  /// Large emphasised numerals — KPI values, stat counters. Was w800.
  static const FontWeight stat = FontWeight.w700;

  /// Button and tab labels. Was w700.
  static const FontWeight label = FontWeight.w600;

  /// Emphasis *inside* running text. Use sparingly; this is the heaviest
  /// weight that should ever appear next to body copy.
  static const FontWeight emphasis = FontWeight.w500;

  /// Body copy, descriptions, captions, helper text.
  ///
  /// This is the single highest-impact value in the file. Most of the
  /// "heaviness" the client is describing is body text sitting at w600.
  static const FontWeight body = FontWeight.w400;
}
