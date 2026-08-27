import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Central owner of raw [VideoPlayerController] playback.
///
/// Guarantees two things the feed screens cannot guarantee for themselves:
///   • Only one player is ever audible — registering a new one hard-stops the
///     rest, so a PageView that builds its neighbours cannot stack audio.
///   • Playback is impossible while the video module is inactive, which is how
///     leaving the Contents tab silences everything.
///
/// This matters because tab screens live inside an IndexedStack: their State is
/// never disposed on a tab change, so `dispose()` is not a usable teardown hook
/// and every player needs an explicit external stop path.
class VideoPlaybackManager extends ChangeNotifier with WidgetsBindingObserver {
  /// Every player that is currently alive, active or not. Tracking the whole
  /// set (rather than a single pointer) is what makes [stopAll] reliable when
  /// several pages initialised at once and only the last one was registered.
  final Set<VideoPlayerController> _players = <VideoPlayerController>{};

  VideoPlayerController? _activeController;
  bool _videoModuleActive = false;

  VideoPlaybackManager() {
    WidgetsBinding.instance.addObserver(this);
  }

  bool get videoModuleActive => _videoModuleActive;

  Future<void> registerPlayer(VideoPlayerController controller) async {
    _players.add(controller);

    for (final other in _players) {
      if (!identical(other, controller)) {
        await _hardStop(other);
      }
    }

    _activeController = controller;

    if (!_videoModuleActive) {
      await _hardStop(controller);
    }
  }

  /// Drops a player from tracking. Call from the owning widget's dispose so the
  /// manager never touches a controller that has already been released.
  void unregisterPlayer(VideoPlayerController controller) {
    _players.remove(controller);
    if (identical(_activeController, controller)) _activeController = null;
  }

  Future<void> enterVideoModule() async {
    _videoModuleActive = true;
  }

  Future<void> exitVideoModule() async {
    _videoModuleActive = false;
    await stopAll();
    notifyListeners();
  }

  /// Silences every tracked player. This is the hook the bottom nav calls when
  /// the user leaves the Contents tab.
  Future<void> stopAll() async {
    for (final controller in _players) {
      await _hardStop(controller);
    }
    _activeController = null;
  }

  Future<void> play(VideoPlayerController controller) async {
    if (!_videoModuleActive) return;

    await registerPlayer(controller);
    // Explicit volume prevents a previous hard-stop's mute from leaking in.
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
      if (!controller.value.isInitialized) return;
      // Volume first = immediate audio cutoff, before the async pause lands.
      await controller.setVolume(0.0);
      if (controller.value.isPlaying) {
        await controller.pause();
      }
      // Rewind so a later resume starts clean rather than mid-clip.
      await controller.seekTo(Duration.zero);
    } catch (e) {
      debugPrint('Video hard-stop error: $e');
    }
  }

  /// Stops audio when the app backgrounds, goes inactive, the notification
  /// shade opens, or the user switches apps.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      stopAll();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    stopAll();
    _players.clear();
    super.dispose();
  }
}
