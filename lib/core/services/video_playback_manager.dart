import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Central controller that guarantees video/audio cannot bleed
/// outside of the video module.
class VideoPlaybackManager extends ChangeNotifier
    with WidgetsBindingObserver {
  VideoPlayerController? _activeController;
  bool _videoModuleActive = false;

  VideoPlaybackManager() {
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> registerPlayer(VideoPlayerController controller) async {
    // Kill previous playback before another video becomes active.
    if (_activeController != null && _activeController != controller) {
      await _hardStop(_activeController!);
    }

    _activeController = controller;

    // Never allow playback unless video module is actually active.
    if (!_videoModuleActive) {
      await _hardStop(controller);
    }
  }

  Future<void> enterVideoModule() async {
    _videoModuleActive = true;
  }

  Future<void> exitVideoModule() async {
    _videoModuleActive = false;

    if (_activeController != null) {
      await _hardStop(_activeController!);
    }

    notifyListeners();
  }

  Future<void> play(VideoPlayerController controller) async {
    if (!_videoModuleActive) return;

    await registerPlayer(controller);

    // Explicit volume prevents old controller state from leaking.
    await controller.setVolume(1.0);

    if (!controller.value.isPlaying) {
      await controller.play();
    }
  }

  Future<void> pause(VideoPlayerController controller) async {
    await controller.pause();
  }

  Future<void> _hardStop(VideoPlayerController controller) async {
    try {
      // Volume first = immediate audio cutoff.
      await controller.setVolume(0.0);

      if (controller.value.isPlaying) {
        await controller.pause();
      }
    } catch (e) {
      debugPrint('Video hard-stop error: $e');
    }
  }

  /// Stops audio when app backgrounds, becomes inactive,
  /// notification center opens, user switches apps, etc.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      if (_activeController != null) {
        _hardStop(_activeController!);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    if (_activeController != null) {
      _hardStop(_activeController!);
    }

    super.dispose();
  }
}
