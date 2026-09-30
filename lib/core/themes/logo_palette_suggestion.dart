import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Suggests a brand accent from an uploaded logo without modifying its pixels.
/// The owner can always replace the suggestion before submitting a claim.
class LogoPaletteSuggestion {
  const LogoPaletteSuggestion._();

  static Future<Color?> fromBytes(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(
      bytes, targetWidth: 96, targetHeight: 96,
    );
    try {
      final frame = await codec.getNextFrame();
      final image = frame.image;
      try {
        final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        if (data == null) return null;
        final pixels = data.buffer.asUint8List();
        final counts = <int, int>{};
        final red = <int, int>{}, green = <int, int>{}, blue = <int, int>{};
        for (var i = 0; i + 3 < pixels.length; i += 4) {
          if (pixels[i + 3] < 180) continue;
          final color = Color.fromARGB(255, pixels[i], pixels[i + 1], pixels[i + 2]);
          final hsv = HSVColor.fromColor(color);
          // White backgrounds, black text and gray outlines aren't brand hues.
          if (hsv.saturation < .28 || hsv.value < .20 || hsv.value > .98) continue;
          final bucket = (hsv.hue / 15).floor();
          counts[bucket] = (counts[bucket] ?? 0) + 1;
          red[bucket] = (red[bucket] ?? 0) + pixels[i];
          green[bucket] = (green[bucket] ?? 0) + pixels[i + 1];
          blue[bucket] = (blue[bucket] ?? 0) + pixels[i + 2];
        }
        if (counts.isEmpty) return null;
        final dominant = counts.keys.reduce(
          (a, b) => counts[a]! >= counts[b]! ? a : b,
        );
        final n = counts[dominant]!;
        return Color.fromARGB(255, red[dominant]! ~/ n,
            green[dominant]! ~/ n, blue[dominant]! ~/ n);
      } finally {
        image.dispose();
      }
    } finally {
      codec.dispose();
    }
  }
}
