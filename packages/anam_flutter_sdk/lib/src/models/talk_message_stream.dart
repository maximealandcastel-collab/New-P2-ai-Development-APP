import 'package:uuid/uuid.dart';

import '../streaming/signaling_client.dart';
import '../utils/client_error.dart';

enum TalkMessageStreamState { unstarted, streaming, interrupted, ended }

/// Streams assistant text to the avatar via signaling (custom LLM pattern).
class TalkMessageStream {
  TalkMessageStream({
    required SignalingClient signalingClient,
    required String sessionId,
    String? correlationId,
  })  : _signalingClient = signalingClient,
        _sessionId = sessionId,
        correlationId = correlationId ?? const Uuid().v4();

  final SignalingClient _signalingClient;
  final String _sessionId;
  final String correlationId;

  TalkMessageStreamState _state = TalkMessageStreamState.unstarted;

  bool get isActive =>
      _state == TalkMessageStreamState.unstarted ||
      _state == TalkMessageStreamState.streaming;

  TalkMessageStreamState get state => _state;

  Future<void> streamMessageChunk(String partialMessage, bool endOfSpeech) async {
    if (!isActive) {
      throw ClientError(
        message: 'Talk stream is not in an active state: $_state',
      );
    }

    await _signalingClient.sendTalkMessage(
      sessionId: _sessionId,
      payload: {
        'content': partialMessage,
        'startOfSpeech': _state == TalkMessageStreamState.unstarted,
        'endOfSpeech': endOfSpeech,
        'correlationId': correlationId,
      },
    );

    _state = endOfSpeech
        ? TalkMessageStreamState.ended
        : TalkMessageStreamState.streaming;
  }

  Future<void> endMessage() async {
    if (_state == TalkMessageStreamState.ended) return;
    if (_state != TalkMessageStreamState.streaming) return;

    await _signalingClient.sendTalkMessage(
      sessionId: _sessionId,
      payload: {
        'content': '',
        'startOfSpeech': false,
        'endOfSpeech': true,
        'correlationId': correlationId,
      },
    );
    _state = TalkMessageStreamState.ended;
  }
}
