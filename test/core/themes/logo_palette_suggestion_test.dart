import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pler_to_pler_app/core/themes/logo_palette_suggestion.dart';

Future<Color?> suggestedColor(Color logoColor) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawColor(Colors.white, BlendMode.src);
  canvas.drawRect(const Rect.fromLTWH(20, 20, 60, 60), Paint()..color = logoColor);
  final picture = recorder.endRecording();
  final image = await picture.toImage(100, 100);
  try {
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return LogoPaletteSuggestion.fromBytes(data!.buffer.asUint8List());
  } finally {
    image.dispose();
    picture.dispose();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('suggests a logo hue without choosing its white background', () async {
    final result = await suggestedColor(const Color(0xFF19AD43));
    expect(result, isNotNull);
    expect(HSVColor.fromColor(result!).hue, inInclusiveRange(115, 155));
  });

  test('leaves a neutral logo for manual color selection', () async {
    expect(await suggestedColor(const Color(0xFF202020)), isNull);
  });
}
