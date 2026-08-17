import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';

/// Manages the iOS AVAudioSession and Android AudioFocus for the video reel.
///
/// [configure] once at app startup. Then [activate] before starting playback
/// and [deactivate] whenever the feed suspends (tab change, route push, app
/// background). Subscribe to [interruptionStream] to react to phone calls etc.
class AudioFocusService {
  AudioFocusService._();
  static final instance = AudioFocusService._();

  AudioSession? _session;
  StreamSubscription<AudioInterruptionEvent>? _interruptionSub;

  final _interruptionController =
      StreamController<AudioInterruptionEvent>.broadcast();

  /// System interruption events (phone calls, Siri, alarms, etc.).
  Stream<AudioInterruptionEvent> get interruptionStream =>
      _interruptionController.stream;

  bool _sessionActive = false;

  /// Configure AVAudioSession / AudioFocus. Call once at app startup in main().
  Future<void> configure() async {
    try {
      _session = await AudioSession.instance;
      await _session!.configure(const AudioSessionConfiguration(
        // iOS — Playback category; not ambient, not mixed. Audio stops other
        // apps while feed is playing, and is silenced when feed suspends.
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.defaultToSpeaker,
        avAudioSessionMode: AVAudioSessionMode.moviePlayback,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        // Android — gain full focus; pause on interruption (duck disabled)
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.movie,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ));

      _interruptionSub = _session!.interruptionEventStream.listen(
        (event) {
          debugPrint(
            '[AUDIO_SESSION] interruption: begin=${event.begin} type=${event.type}',
          );
          _interruptionController.add(event);
        },
        onError: (_) {},
      );

      debugPrint('[AUDIO_SESSION] configured: category=playback mode=moviePlayback');
    } catch (e) {
      debugPrint('[AUDIO_SESSION] configure error: $e');
    }
  }

  /// Claim audio focus. Call immediately before starting playback.
  Future<void> activate() async {
    if (_sessionActive) return;
    try {
      final session = _session ?? await AudioSession.instance;
      final granted = await session.setActive(true);
      _sessionActive = granted;
      debugPrint('[AUDIO_SESSION] activate — focus granted=$granted');
    } catch (e) {
      debugPrint('[AUDIO_SESSION] activate error: $e');
    }
  }

  /// Release audio focus. Call whenever the feed suspends — tab change, route
  /// push on top, app background, or the user navigating away.
  Future<void> deactivate() async {
    if (!_sessionActive) return;
    try {
      final session = _session ?? await AudioSession.instance;
      await session.setActive(false);
      _sessionActive = false;
      debugPrint('[AUDIO_SESSION] deactivated — audio focus released');
    } catch (e) {
      debugPrint('[AUDIO_SESSION] deactivate error: $e');
    }
  }

  void dispose() {
    _interruptionSub?.cancel();
    _interruptionController.close();
  }
}
