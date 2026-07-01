import 'package:media_kit/media_kit.dart';

class VideoDurationHelper {
  VideoDurationHelper._();

  static Future<int?> fromFilePath(String path) async {
    final player = Player(
      configuration: const PlayerConfiguration(muted: true),
    );

    try {
      await player.open(Media('file://$path'), play: false);
      final duration = await player.stream.duration
          .firstWhere((value) => value > Duration.zero)
          .timeout(const Duration(seconds: 15));
      return duration.inSeconds;
    } catch (_) {
      return null;
    } finally {
      await player.dispose();
    }
  }
}
