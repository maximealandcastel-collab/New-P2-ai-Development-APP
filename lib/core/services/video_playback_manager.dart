import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Central owner of raw [VideoPlayerController] playback.
///
/// Every asynchronous operation carries a generation. A newer visibility or
/// playback request invalidates older work so a late stop cannot pause a video
/// that the user has already returned to.
class VideoPlaybackManager extends ChangeNotifier with WidgetsBindingObserver {
  final Set<VideoPlayerController> _players = <VideoPlayerController>{};

  VideoPlayerController? _activeController;
  bool _videoModuleActive = false;
  int _operationId = 0;

  VideoPlaybackManager() {
    WidgetsBinding.instance.addObserver(this);
  }

  bool get videoModuleActive => _videoModuleActive;

  void unregisterPlayer(VideoPlayerController controller) {
    _players.remove(controller);
    if (identical(_activeController, controller)) _activeController = null;
  }

  Future<void> enterVideoModule() async {
    _operationId++;
    _videoModuleActive = true;
  }

  Future<void> exitVideoModule() async {
    _videoModuleActive = false;
    final operationId = ++_operationId;
    await _stopAll(operationId);
    if (operationId == _operationId) notifyListeners();
  }

  Future<void> stopAll() async {
    final operationId = ++_operationId;
    await _stopAll(operationId);
  }

  Future<void> _stopAll(int operationId) async {
    for (final controller in List<VideoPlayerController>.of(_players)) {
      if (operationId != _operationId) return;
      await _hardStop(controller, operationId);
    }
    if (operationId == _operationId) _activeController = null;
  }

  Future<void> play(VideoPlayerController controller) async {
    final operationId = ++_operationId;
    _players.add(controller);

    // Fail closed: a hidden/prebuilt page may still finish initializing after
    // Home becomes active. Mute and stop that controller instead of merely
    // ignoring its play request.
    if (!_videoModuleActive) {
      await _hardStop(controller, operationId);
      return;
    }

    for (final other in List<VideoPlayerController>.of(_players)) {
      if (operationId != _operationId || !_videoModuleActive) return;
      if (!identical(other, controller)) {
        await _hardStop(other, operationId);
      }
    }

    if (operationId != _operationId || !_videoModuleActive) return;
    _activeController = controller;
    try {
      await controller.setVolume(1.0);
      if (operationId != _operationId || !_videoModuleActive) return;
      if (!controller.value.isPlaying) await controller.play();
    } catch (error) {
      debugPrint('Video play error: $error');
    }
  }

  Future<void> pause(VideoPlayerController controller) async {
    ++_operationId;
    try {
      await controller.pause();
    } catch (error) {
      debugPrint('Video pause error: $error');
    }
  }

  Future<void> _hardStop(
    VideoPlayerController controller,
    int operationId,
  ) async {
    try {
      if (!controller.value.isInitialized) return;
      await controller.setVolume(0.0);
      if (operationId != _operationId) return;
      if (controller.value.isPlaying) await controller.pause();
      if (operationId != _operationId) return;
      await controller.seekTo(Duration.zero);
    } catch (error) {
      debugPrint('Video hard-stop error: $error');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      unawaited(stopAll());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _operationId++;
    _videoModuleActive = false;
    for (final controller in List<VideoPlayerController>.of(_players)) {
      unawaited(_hardStop(controller, _operationId));
    }
    _players.clear();
    _activeController = null;
    super.dispose();
  }
}
