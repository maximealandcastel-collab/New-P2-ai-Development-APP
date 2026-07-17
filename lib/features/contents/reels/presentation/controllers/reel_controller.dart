import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';
import 'package:pler_to_pler_app/features/contents/reels/core/reel_player_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Manages reel video lifecycle: preload, autoplay, pause, and app lifecycle.
///
/// Ensures only one [VideoPlayerController] plays at a time.
class ReelController extends GetxController with WidgetsBindingObserver {
  ReelController({ReelPlayerManager? playerManager})
      : _playerManager = playerManager ?? ReelPlayerManager();

  final ReelPlayerManager _playerManager;

  final RxInt currentIndex = 0.obs;
  final RxBool isPlaying = true.obs;
  final RxBool isUserPaused = false.obs;

  /// Play when mostly visible; pause only when mostly off-screen.
  static const double _playVisibilityThreshold = 0.55;
  static const double _pauseVisibilityThreshold = 0.25;

  bool _isClosed = false;
  bool _isActive = true;
  bool _wasPlayingBeforeBackground = false;
  int _syncGeneration = 0;

  ReelPlayerManager get playerManager => _playerManager;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  VideoPlayerController? videoControllerFor(int index) =>
      _playerManager.controllerFor(index);

  bool isReady(int index) => _playerManager.isReady(index);

  String errorFor(int index) => _playerManager.errorFor(index);

  bool isActiveIndex(int index) => currentIndex.value == index;

  /// Activates playback for the feed at [index].
  Future<void> activateAt({
    required int index,
    required List<ContentModel> contents,
    bool autoPlay = true,
  }) async {
    if (_isClosed || !_isActive) return;
    if (index < 0 || index >= contents.length) return;

    currentIndex.value = index;
    final generation = ++_syncGeneration;

    try {
      await _playerManager.sync(
        index: index,
        contents: contents,
        playActive: autoPlay && !isUserPaused.value,
      );
      if (_isClosed || generation != _syncGeneration) return;

      isPlaying.value =
          _playerManager.isReady(index) && autoPlay && !isUserPaused.value;
    } catch (error) {
      if (kDebugMode) debugPrint('ReelController.activateAt error: $error');
    }
  }

  Future<void> onPageChanged({
    required int index,
    required List<ContentModel> contents,
  }) async {
    if (index == currentIndex.value) return;

    isUserPaused.value = false;
    await activateAt(index: index, contents: contents);
  }

  /// Visibility-based autoplay keeps playback during small scroll movements.
  void onVisibilityChanged({
    required int index,
    required VisibilityInfo info,
    required List<ContentModel> contents,
  }) {
    if (_isClosed || !_isActive) return;
    if (index != currentIndex.value) return;

    final fraction = info.visibleFraction;

    if (fraction >= _playVisibilityThreshold) {
      if (!isUserPaused.value &&
          !isPlaying.value &&
          _playerManager.isReady(index)) {
        unawaited(_resumePlayback(index));
      }
      return;
    }

    if (fraction <= _pauseVisibilityThreshold && isPlaying.value) {
      unawaited(_pausePlayback(index, userInitiated: false));
    }
  }

  Future<void> togglePlayback() async {
    if (_isClosed) return;

    if (isPlaying.value) {
      isUserPaused.value = true;
      await _pausePlayback(currentIndex.value, userInitiated: true);
    } else {
      isUserPaused.value = false;
      await _resumePlayback(currentIndex.value);
    }
  }

  Future<void> pauseActive({bool userInitiated = false}) async {
    if (userInitiated) isUserPaused.value = true;
    await _pausePlayback(currentIndex.value, userInitiated: userInitiated);
  }

  Future<void> playActive() async {
    isUserPaused.value = false;
    await _resumePlayback(currentIndex.value);
  }

  Future<void> retryAt(int index, List<ContentModel> contents) async {
    if (index < 0 || index >= contents.length) return;

    await _playerManager.retryAt(index, contents[index]);
    if (index == currentIndex.value) {
      isPlaying.value = _playerManager.isReady(index) && !isUserPaused.value;
    }
  }

  Future<void> suspend() async {
    _isActive = false;
    _wasPlayingBeforeBackground = isPlaying.value;
    await _playerManager.pauseActive();
    isPlaying.value = false;
  }

  Future<void> resume({
    required List<ContentModel> contents,
  }) async {
    _isActive = true;
    await activateAt(
      index: currentIndex.value,
      contents: contents,
      autoPlay: _wasPlayingBeforeBackground && !isUserPaused.value,
    );
  }

  Future<void> reset() async {
    currentIndex.value = 0;
    isUserPaused.value = false;
    isPlaying.value = true;
    await _playerManager.reset();
  }

  Future<void> disposePlayback() async {
    await _playerManager.releaseAll();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isClosed) return;

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _wasPlayingBeforeBackground = isPlaying.value;
        unawaited(_playerManager.pauseActive());
        isPlaying.value = false;
        break;
      case AppLifecycleState.resumed:
        if (_isActive &&
            _wasPlayingBeforeBackground &&
            !isUserPaused.value) {
          unawaited(_playerManager.playActive());
          isPlaying.value = _playerManager.isReady(currentIndex.value);
        }
        break;
    }
  }

  Future<void> _pausePlayback(int index, {required bool userInitiated}) async {
    if (!_playerManager.isActive(index)) return;
    await _playerManager.pauseActive();
    if (!_isClosed) isPlaying.value = false;
  }

  Future<void> _resumePlayback(int index) async {
    if (!_playerManager.isActive(index) || !_playerManager.isReady(index)) {
      return;
    }
    await _playerManager.playActive();
    if (!_isClosed) isPlaying.value = true;
  }

  @override
  void onClose() {
    _isClosed = true;
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_playerManager.releaseAll());
    _playerManager.dispose();
    super.onClose();
  }
}
