import 'dart:io';

import 'package:video_player/video_player.dart';

class VideoDurationHelper {
  VideoDurationHelper._();

  static Future<int?> fromFilePath(String path) async {
    final controller = VideoPlayerController.file(File(path));

    try {
      await controller.initialize().timeout(const Duration(seconds: 15));
      final seconds = controller.value.duration.inSeconds;
      return seconds > 0 ? seconds : null;
    } catch (_) {
      return null;
    } finally {
      await controller.dispose();
    }
  }
}
