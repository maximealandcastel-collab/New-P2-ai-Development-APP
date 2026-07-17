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

  int? index;
  String? sourceKey;
  bool isReady = false;
  bool isLoading = false;
  String error = '';

  VideoPlayerController? get controller => isReady ? _controller : null;

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

    if (isLoading) return;

    final generation = ++_generation;
    index = targetIndex;
    sourceKey = cacheKey;
    isReady = false;
    isLoading = true;
    error = '';

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
        await videoController.seekTo(Duration.zero);
        await videoController.pause();
      }
    } catch (e) {
      if (generation != _generation) return;
      error = 'Unable to play this video.';
      isReady = false;
      _controller = null;
      await _disposePlayer(player);
      if (kDebugMode) debugPrint('ReelVideoSlot.load: $e');
    } finally {
      if (generation == _generation) isLoading = false;
    }
  }

  Future<void> cancel() async {
    _generation++;
    isLoading = false;
    isReady = false;
    _controller = null;
    error = '';
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
