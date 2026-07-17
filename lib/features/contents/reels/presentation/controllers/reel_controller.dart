import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/services/connectivity_service.dart';
import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';
import 'package:pler_to_pler_app/features/contents/reels/core/reel_player_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ReelController extends GetxController with WidgetsBindingObserver {
  ReelController({
    ReelPlayerManager? playerManager,
    ConnectivityService? connectivityService,
  })  : _player = playerManager ?? ReelPlayerManager(),
        _connectivity = connectivityService ?? ConnectivityService();

  final ReelPlayerManager _player;
  final ConnectivityService _connectivity;

  final RxInt currentIndex = 0.obs;
  final RxBool isPlaying = true.obs;
  final RxBool isUserPaused = false.obs;
  final RxInt slotVersion = 0.obs;

  bool _isClosed = false;
  bool _isActive = true;
  bool _wasPlayingBeforeBackground = false;
  int _syncGeneration = 0;

  int? _pendingIndex;
  List<ContentModel>? _pendingContents;
  bool _isProcessingPageChange = false;

  ReelPlayerManager get playerManager => _player;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _player.onUpdated = () => slotVersion.value++;
  }

  VideoPlayerController? videoControllerFor(int index) =>
      _player.controllerFor(index);

  bool isReady(int index) => _player.isReady(index);

  String errorFor(int index) => _player.errorFor(index);

  bool isActiveIndex(int index) => currentIndex.value == index;

  Future<void> activateAt({
    required int index,
    required List<ContentModel> contents,
    bool autoPlay = true,
  }) async {
    if (_isClosed || !_isActive) return;
    if (index < 0 || index >= contents.length) return;

    currentIndex.value = index;
    final generation = ++_syncGeneration;
    final shouldPlay = autoPlay && !isUserPaused.value;

    try {
      await _player.sync(
        index: index,
        contents: contents,
        playActive: shouldPlay,
        prioritizeNextPreload: _connectivity.shouldPrioritizeNextVideoPreload,
      );
      if (_isClosed || generation != _syncGeneration) return;

      if (!_player.isReady(index) && _player.errorFor(index).isEmpty) {
        await _player.sync(
          index: index,
          contents: contents,
          playActive: shouldPlay,
          prioritizeNextPreload: _connectivity.shouldPrioritizeNextVideoPreload,
        );
        if (_isClosed || generation != _syncGeneration) return;
      }

      isPlaying.value = _player.isReady(index) && shouldPlay;
    } catch (error) {
      if (kDebugMode) debugPrint('ReelController.activateAt: $error');
    }
  }

  Future<void> onPageChanged({
    required int index,
    required List<ContentModel> contents,
  }) async {
    if (_isClosed || index < 0 || index >= contents.length) return;

    if (index == currentIndex.value && isReady(index)) return;

    if (index != currentIndex.value) {
      isUserPaused.value = false;
    }

    _pendingIndex = index;
    _pendingContents = contents;
    await _processPendingPageChange();
  }

  Future<void> _processPendingPageChange() async {
    if (_isProcessingPageChange) return;

    _isProcessingPageChange = true;
    try {
      while (_pendingIndex != null && !_isClosed && _isActive) {
        final index = _pendingIndex!;
        final contents = _pendingContents!;
        _pendingIndex = null;
        _pendingContents = null;

        await activateAt(index: index, contents: contents);
      }
    } finally {
      _isProcessingPageChange = false;
      if (_pendingIndex != null && !_isClosed) {
        unawaited(_processPendingPageChange());
      }
    }
  }

  void onVisibilityChanged({
    required int index,
    required VisibilityInfo info,
    required List<ContentModel> contents,
  }) {
    if (_isClosed || !_isActive || index != currentIndex.value) return;

    if (info.visibleFraction >= 0.55 &&
        !isUserPaused.value &&
        !isPlaying.value &&
        _player.isReady(index)) {
      unawaited(_player.playActive().then((_) {
        if (!_isClosed) isPlaying.value = true;
      }));
      return;
    }

    if (info.visibleFraction <= 0.25 && isPlaying.value) {
      unawaited(_player.pauseActive().then((_) {
        if (!_isClosed) isPlaying.value = false;
      }));
    }
  }

  Future<void> togglePlayback() async {
    if (_isClosed) return;
    if (isPlaying.value) {
      isUserPaused.value = true;
      await _player.pauseActive();
      isPlaying.value = false;
    } else {
      isUserPaused.value = false;
      await _player.playActive();
      isPlaying.value = true;
    }
  }

  Future<void> pauseActive({bool userInitiated = false}) async {
    if (userInitiated) isUserPaused.value = true;
    await _player.pauseActive();
    isPlaying.value = false;
  }

  Future<void> retryAt(int index, List<ContentModel> contents) async {
    if (index < 0 || index >= contents.length) return;
    await _player.retryAt(index, contents[index]);
    if (index == currentIndex.value) {
      isPlaying.value = _player.isReady(index) && !isUserPaused.value;
    }
  }

  Future<void> suspend() async {
    _isActive = false;
    _wasPlayingBeforeBackground = isPlaying.value;
    await _player.pauseActive();
    isPlaying.value = false;
  }

  Future<void> resume({required List<ContentModel> contents}) async {
    _isActive = true;
    await activateAt(
      index: currentIndex.value,
      contents: contents,
      autoPlay: _wasPlayingBeforeBackground && !isUserPaused.value,
    );
  }

  Future<void> reset({int index = 0}) async {
    _syncGeneration++;
    _pendingIndex = null;
    _pendingContents = null;
    currentIndex.value = index;
    isUserPaused.value = false;
    isPlaying.value = true;
    await _player.reset();
    slotVersion.value++;
  }

  Future<void> disposePlayback() async {
    _pendingIndex = null;
    _pendingContents = null;
    await _player.releaseAll();
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
        unawaited(_player.pauseActive());
        isPlaying.value = false;
      case AppLifecycleState.resumed:
        if (_isActive && _wasPlayingBeforeBackground && !isUserPaused.value) {
          unawaited(_player.playActive());
          isPlaying.value = _player.isReady(currentIndex.value);
        }
    }
  }

  @override
  void onClose() {
    _isClosed = true;
    _pendingIndex = null;
    _pendingContents = null;
    _player.onUpdated = null;
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_player.releaseAll());
    super.onClose();
  }
}
