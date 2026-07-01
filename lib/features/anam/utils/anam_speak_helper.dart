import 'package:anam_flutter_sdk/anam_flutter_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// Speaks assistant replies via Anam TTS (not `sendUserMessage`).
class AnamSpeakHelper {
  AnamSpeakHelper._();

  static Future<void> speak({
    required AnamClient client,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    try {
      await client.speakAssistantText(trimmed);
    } catch (e) {
      if (kDebugMode) debugPrint('Anam speak failed: $e');
    }
  }

  static void attachRemoteStream(AnamClient client, RTCVideoRenderer renderer) {
    client.streamToVideoElement(renderer);
  }
}
