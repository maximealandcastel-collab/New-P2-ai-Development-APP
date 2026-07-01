import 'package:media_kit/media_kit.dart';

class VideoMetadata {
  const VideoMetadata({
    required this.durationSeconds,
    required this.width,
    required this.height,
  });

  final int durationSeconds;
  final int width;
  final int height;
}

class VideoDurationHelper {
  VideoDurationHelper._();

  static Future<int?> fromFilePath(String path) async {
    final metadata = await metadataFromFilePath(path);
    return metadata?.durationSeconds;
  }

  static Future<VideoMetadata?> metadataFromFilePath(String path) async {
    final player = Player(
      configuration: const PlayerConfiguration(muted: true),
    );

    try {
      await player.open(Media('file://$path'), play: false);

      final results = await Future.wait([
        player.stream.duration
            .firstWhere((value) => value > Duration.zero)
            .timeout(const Duration(seconds: 15)),
        player.stream.width
            .firstWhere((value) => value != null && value > 0)
            .timeout(const Duration(seconds: 15)),
        player.stream.height
            .firstWhere((value) => value != null && value > 0)
            .timeout(const Duration(seconds: 15)),
      ]);

      final duration = results[0] as Duration;
      final width = results[1] as int?;
      final height = results[2] as int?;

      if (width == null || height == null) return null;

      return VideoMetadata(
        durationSeconds: duration.inSeconds,
        width: width,
        height: height,
      );
    } catch (_) {
      return null;
    } finally {
      await player.dispose();
    }
  }
}
