import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('screen accents cannot bypass the active gym theme', () {
    // These are the former app-accent variants, including the profile's literal
    // orange. Semantic warning, rating, and medal palettes are not app accents.
    final fixedAccent = RegExp(
      r'Color\(0xFF(?:FD7B00|FF7A00|F57C1F|FF6B1A|FF7417|FF6B24|FF6B35|FF5B1A|EA580C|FF6B00|FF8C00)\)',
      caseSensitive: false,
    );
    final violations = <String>[];
    for (final file in Directory(
      'lib',
    ).listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart') || file.path.endsWith('.gen.dart'))
        continue;
      if (file.path.endsWith('/app_colors.dart') ||
          file.path.endsWith('/brand_color_mapper.dart') ||
          file.path.contains('/data/'))
        continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (fixedAccent.hasMatch(lines[i]) &&
            !lines[i].contains('fixed-color: provider logo')) {
          violations.add('${file.path}:${i + 1}');
        }
      }
    }
    expect(
      violations,
      isEmpty,
      reason: 'Use Theme.of(context) or BrandColors for app accents.',
    );
  });
}
