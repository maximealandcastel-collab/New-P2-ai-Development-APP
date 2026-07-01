import 'package:anam_flutter_sdk/anam_flutter_sdk.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:uuid/uuid.dart';

/// Sends assistant text to the avatar using Anam's talk-stream signaling format.
class AnamSpeakHelper {
  AnamSpeakHelper._();

  static const _uuid = Uuid();
  static final Dio _dio = Dio();

  static Future<void> speak(AnamClient client, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final dynamic c = client;
    final signaling = c._signalingClient;
    final sessionId = c._currentSessionId as String?;
    if (signaling == null || sessionId == null) return;

    signaling.sendMessage({
      'actionType': 'talkstream',
      'sessionId': sessionId,
      'payload': {
        'content': trimmed,
        'startOfSpeech': true,
        'endOfSpeech': true,
        'correlationId': _uuid.v4(),
      },
    });

    await _sendTalkRestFallback(c, sessionId, trimmed);
  }

  static Future<void> _sendTalkRestFallback(
    dynamic client,
    String sessionId,
    String content,
  ) async {
    try {
      final signaling = client._signalingClient;
      final engineHost = signaling?.engineHost as String?;
      final engineProtocol = signaling?.engineProtocol as String? ?? 'https';
      if (engineHost == null || engineHost.isEmpty) return;

      final url =
          '$engineProtocol://$engineHost/talk?session_id=$sessionId';

      await _dio.post(
        url,
        data: {'content': content},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Anam talk REST fallback failed: $e');
    }
  }

  static void attachRemoteStream(AnamClient client, RTCVideoRenderer renderer) {
    client.streamToVideoElement(renderer);

    final dynamic c = client;
    final stream = c._streamingClient?.remoteStream;
    if (stream != null) {
      renderer.srcObject = stream;
    }
  }
}
