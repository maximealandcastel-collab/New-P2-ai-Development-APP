import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:pler_to_pler_app/features/contents/core/content_media_resolver.dart';
import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';
import 'package:video_player/video_player.dart';

/// One cached video player for a reel index.
class ReelVideoSlot {
  CachedVideoPlayerPlus? _player;
  VideoPlayerController? _controller;
  int _generation = 0;
  VoidCallback? _videoListener;
  Future<void>? _activeLoad;

  VoidCallback? onUpdated;

  int? index;
  String? sourceKey;
  bool isReady = false;
  bool isLoading = false;
  String error = '';

  VideoPlayerController? get controller => isReady ? _controller : null;

  void _notifyState() => onUpdated?.call();

  Future<void> load(
    int targetIndex,
    ContentModel content, {
    required bool autoPlay,
  }) async {
    final url = ContentMediaResolver.resolveVideoUrl(content);
    final cacheKey = ContentMediaResolver.sourceKey(content);

    if (url.isEmpty) {
      await cancel();
      index = targetIndex;
      error = 'No video available for this content.';
      _notifyState();
      return;
    }

    if (index == targetIndex && sourceKey == cacheKey && isReady && error.isEmpty) return;
    if (_activeLoad != null && index == targetIndex && sourceKey == cacheKey && error.isEmpty) {
      await _activeLoad;
      return;
    }

    if (isLoading) {
      _generation++;
      isLoading = false;
      _activeLoad = null;
      _notifyState();
    }

    final generation = ++_generation;
    index = targetIndex;
    sourceKey = cacheKey;
    isReady = false;
    isLoading = true;
    error = '';
    _notifyState();

    final loadFuture = _performLoad(
      targetIndex: targetIndex,
      urls: ContentMediaResolver.videoCandidates(content),
      cacheKey: cacheKey,
      autoPlay: autoPlay,
      generation: generation,
    );
    _activeLoad = loadFuture;

    try {
      await loadFuture;
    } finally {
      if (_activeLoad == loadFuture) {
        _activeLoad = null;
      }
    }
  }

  Future<void> _performLoad({
    required int targetIndex,
    required List<String> urls,
    required String cacheKey,
    required bool autoPlay,
    required int generation,
  }) async {
    await _dispose();
    if (generation != _generation) return;
    try {
      for (final url in urls) {
        final player = ContentMediaResolver.createPlayerForUrl(url, cacheKey: cacheKey);
        try {
          await ContentMediaResolver.initializePlayer(player);
          if (generation != _generation) {
            await _disposePlayer(player);
            return;
          }
          final controller = player.controller;
          await controller.setLooping(true);
          await controller.setVolume(0);
          await controller.pause();
          if (generation != _generation) {
            await _disposePlayer(player);
            return;
          }
          _player = player;
          _controller = controller;
          isReady = true;
          error = '';
          _videoListener = () {
            if (generation != _generation || !controller.value.hasError) return;
            isReady = false;
            error = 'Playback stopped. Please retry this video.';
            _notifyState();
          };
          controller.addListener(_videoListener!);
          return; // Only the manager may play after checking current visibility.
        } catch (failure) {
          await _disposePlayer(player);
          if (generation != _generation) return;
          if (kDebugMode) debugPrint('Reel initialization failed: ${failure.runtimeType}');
        }
      }
      error = 'Unable to load this video. Check your connection and retry.';
      isReady = false;
    } catch (_) {
      if (generation == _generation) {
        error = 'Unable to load this video. Please retry.';
        isReady = false;
      }
    } finally {
      if (generation == _generation) {
        isLoading = false;
        _notifyState();
      }
    }
  }

  Future<void> cancel() async {
    _generation++;
    isLoading = false;
    isReady = false;
    error = '';
    _activeLoad = null;
    await _dispose();
  }

  Future<void> play() async {
    if (!isReady) return;
    try {
      await _controller?.play();
    } catch (_) {}
  }

  Future<void> pause() async {
    try {
      await _controller?.pause();
    } catch (_) {}
  }

  Future<void> setVolume(double volume) async {
    try {
      await _controller?.setVolume(volume);
    } catch (_) {}
  }

  Future<void> stop() async {
    await pause();
    try {
      await _controller?.seekTo(Duration.zero);
    } catch (_) {}
  }

  void detach() {
    index = null;
    sourceKey = null;
    isReady = false;
    isLoading = false;
    error = '';
    _controller = null;
    _activeLoad = null;
  }

  Future<void> release() async {
    await cancel();
    detach();
  }

  Future<void> _dispose() async {
    final player = _player;
    if (_videoListener != null) _controller?.removeListener(_videoListener!);
    _videoListener = null;
    _player = null;
    _controller = null;
    await _disposePlayer(player);
  }

  Future<void> _disposePlayer(CachedVideoPlayerPlus? player) async {
    if (player == null) return;
    try {
      await player.dispose();
    } catch (_) {}
  }
}
