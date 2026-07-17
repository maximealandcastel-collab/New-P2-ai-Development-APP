import 'dart:async';

import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:pler_to_pler_app/features/contents/core/content_media_resolver.dart';
import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';
import 'package:video_player/video_player.dart';

/// Wraps a single [CachedVideoPlayerPlus] instance for one reel index.
///
/// Slots are reused by [ReelPlayerManager] to keep memory bounded while
/// supporting preload of adjacent videos.
class ReelVideoSlot extends ChangeNotifier {
  CachedVideoPlayerPlus? _cachedPlayer;

  int? index;
  String? sourceKey;
  bool isInitialized = false;
  bool isInitializing = false;
  String error = '';

  VideoPlayerController? get controller => _cachedPlayer?.controller;

  bool get hasPlayer => _cachedPlayer != null;

  /// Loads [content] at [targetIndex]. Reuses the player when the source is unchanged.
  Future<void> loadAt(
    int targetIndex,
    ContentModel content, {
    required bool autoPlay,
  }) async {
    final url = ContentMediaResolver.resolveVideoUrl(content);
    final cacheKey = content.id ?? url;

    if (url.isEmpty) {
      await _releasePlayer();
      index = targetIndex;
      sourceKey = null;
      isInitialized = false;
      error = 'No video available for this content.';
      _notify();
      return;
    }

    if (index == targetIndex &&
        sourceKey == cacheKey &&
        isInitialized &&
        error.isEmpty &&
        _cachedPlayer != null) {
      if (autoPlay) {
        await controller?.play();
      } else {
        await controller?.pause();
      }
      _notify();
      return;
    }

    if (isInitializing && index == targetIndex) {
      return;
    }

    index = targetIndex;
    sourceKey = cacheKey;
    isInitialized = false;
    error = '';
    isInitializing = true;
    _notify();

    await _releasePlayer();

    try {
      _cachedPlayer = ContentMediaResolver.createPlayerForUrl(
        url,
        cacheKey: cacheKey,
      );

      await _cachedPlayer!.initialize();
      await controller!.setLooping(true);
      isInitialized = true;

      if (autoPlay) {
        await controller!.play();
      } else {
        await controller!.seekTo(Duration.zero);
        await controller!.pause();
      }
    } catch (loadError) {
      error = 'Unable to play this video.';
      isInitialized = false;
      if (kDebugMode) {
        debugPrint('ReelVideoSlot load error: $loadError');
      }
    } finally {
      isInitializing = false;
      _notify();
    }
  }

  Future<void> play() async {
    if (!isInitialized || controller == null) return;
    try {
      await controller!.play();
    } catch (_) {}
  }

  Future<void> pause() async {
    if (controller == null) return;
    try {
      await controller!.pause();
    } catch (_) {}
  }

  Future<void> seekToStart() async {
    if (!isInitialized || controller == null) return;
    try {
      await controller!.seekTo(Duration.zero);
      await controller!.play();
    } catch (_) {}
  }

  Future<void> stop() async {
    await pause();
    try {
      await controller?.seekTo(Duration.zero);
    } catch (_) {}
  }

  void detach() {
    index = null;
    sourceKey = null;
    isInitialized = false;
    isInitializing = false;
    error = '';
    _notify();
  }

  Future<void> release() async {
    await _releasePlayer();
    detach();
  }

  Future<void> _releasePlayer() async {
    try {
      await _cachedPlayer?.dispose();
    } catch (_) {}
    _cachedPlayer = null;
  }

  void _notify() {
    if (hasListeners) notifyListeners();
  }
}
