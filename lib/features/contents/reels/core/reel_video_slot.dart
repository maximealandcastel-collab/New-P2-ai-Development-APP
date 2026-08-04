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
  Future<void>? _activeLoad;
  bool _autoRetried = false;

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
    final cacheKey = content.id ?? url;

    if (url.isEmpty) {
      await cancel();
      index = targetIndex;
      error = 'No video available for this content.';
      _notifyState();
      return;
    }

    if (index == targetIndex &&
        sourceKey == cacheKey &&
        isReady &&
        error.isEmpty) {
      if (autoPlay) {
        await _controller?.play();
      } else {
        await _controller?.pause();
      }
      return;
    }

    if (_activeLoad != null &&
        index == targetIndex &&
        sourceKey == cacheKey &&
        !isReady &&
        error.isEmpty) {
      await _activeLoad;
      if (index == targetIndex &&
          sourceKey == cacheKey &&
          isReady &&
          error.isEmpty) {
        if (autoPlay) {
          await _controller?.play();
        } else {
          await _controller?.pause();
        }
        return;
      }
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
    _autoRetried = false;
    _notifyState();

    final loadFuture = _performLoad(
      targetIndex: targetIndex,
      url: url,
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
    required String url,
    required String cacheKey,
    required bool autoPlay,
    required int generation,
  }) async {
    await _dispose();
    if (generation != _generation) return;

    CachedVideoPlayerPlus? player;
    try {
      player = ContentMediaResolver.createPlayerForUrl(url, cacheKey: cacheKey);
      _player = player;
      await player.initialize();
      if (generation != _generation) {
        await player.dispose();
        return;
      }

      final videoController = player.controller;
      await videoController.setLooping(true);
      _controller = videoController;
      isReady = true;

      if (autoPlay) {
        await videoController.play();
      } else {
        // Do NOT seekTo(zero) on neighbors — that triggers an unnecessary
        // network read on the native layer. Just pause; position is already
        // at the start for a freshly initialized controller.
        await videoController.pause();
      }
    } catch (e) {
      if (generation != _generation) return;

      if (!_autoRetried) {
        _autoRetried = true;
        await _disposePlayer(player);
        player = null;
        _player = null;
        _controller = null;
        isReady = false;
        isLoading = true;
        _notifyState();

        try {
          player = ContentMediaResolver.createPlayerForUrl(
            url,
            cacheKey: cacheKey,
          );
          _player = player;
          await player.initialize();
          if (generation != _generation) {
            await player.dispose();
            return;
          }

          final videoController = player.controller;
          await videoController.setLooping(true);
          _controller = videoController;
          isReady = true;
          error = '';

          if (autoPlay) {
            await videoController.play();
          } else {
            await videoController.pause();
          }
        } catch (retryError) {
          if (generation != _generation) return;
          error = 'Unable to play this video.';
          isReady = false;
          _controller = null;
          await _disposePlayer(player);
          if (kDebugMode) debugPrint('ReelVideoSlot.load retry: $retryError');
        }
      } else {
        error = 'Unable to play this video.';
        isReady = false;
        _controller = null;
        await _disposePlayer(player);
        if (kDebugMode) debugPrint('ReelVideoSlot.load: $e');
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
    _controller = null;
    error = '';
    _activeLoad = null;
    _autoRetried = false;
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
    _autoRetried = false;
  }

  Future<void> release() async {
    await cancel();
    detach();
  }

  Future<void> _dispose() async {
    final player = _player;
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
