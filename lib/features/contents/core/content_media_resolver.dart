import 'dart:async';
import 'dart:io';

import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';

class ContentMediaResolver {
  ContentMediaResolver._();

  static void _log(String message) {
    if (kDebugMode) debugPrint(message);
  }

  static String resolveUrl(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) {
      _log('ContentMediaResolver.resolveUrl: raw url is empty');
      return '';
    }

    if (value.startsWith('asset://') || value.startsWith('file://')) {
      return value;
    }

    if (value.startsWith('http://') || value.startsWith('https://')) {
      final resolved = Uri.parse(value).toString();
      _log('ContentMediaResolver.resolveUrl: absolute → $resolved');
      return resolved;
    }

    final base = Uri.parse(ApiConstants.mediaBaseUrl);
    final path = value.startsWith('/') ? value.substring(1) : value;
    final segments = path.split('/').where((segment) => segment.isNotEmpty);
    final resolved = base.replace(
      pathSegments: [
        ...base.pathSegments.where((segment) => segment.isNotEmpty),
        ...segments,
      ],
    );

    _log('ContentMediaResolver.resolveUrl: resolved → ${resolved.toString()}');
    return resolved.toString();
  }

  static const initializationTimeout = Duration(seconds: 12);

  static String sourceKey(ContentModel content) =>
      '${content.id ?? ""}|${content.updatedAt ?? ""}|${resolveVideoUrl(content)}';

  static List<String> videoCandidates(ContentModel content) {
    final preferred = resolveVideoUrl(content);
    final legacy = resolveUrl(content.videoUrl);
    return {if (preferred.isNotEmpty) preferred, if (legacy.isNotEmpty) legacy}.toList();
  }

  /// Future.timeout doesn't cancel native initialization. Dispose late success
  /// as well, so leaving a loading screen cannot leak a native video player.
  static Future<void> initializePlayer(CachedVideoPlayerPlus player) async {
    final initialization = player.initialize();
    try {
      await initialization.timeout(initializationTimeout);
    } on TimeoutException {
      unawaited(initialization.then((_) => player.dispose()).catchError((Object _) {}));
      rethrow;
    }
  }

  /// Playback source preference:
  ///   1. Mux HLS  (https://stream.mux.com/{playbackId}.m3u8) — adaptive CDN stream
  ///   2. Legacy videoUrl — GCS MP4 stream with Range support
  ///   3. Empty string — slot shows error state
  static String resolveVideoUrl(ContentModel content) {
    if (content.hasMuxHls) {
      final muxUrl = 'https://stream.mux.com/${content.muxPlaybackId}.m3u8';
      _log('ContentMediaResolver.resolveVideoUrl: Mux HLS → $muxUrl');
      return muxUrl;
    }
    final legacy = resolveUrl(content.videoUrl);
    _log('ContentMediaResolver.resolveVideoUrl: legacy → $legacy');
    return legacy;
  }

  /// Returns a thumbnail URL.
  /// Prefers Mux auto-generated poster (sharp first frame, served from CDN)
  /// over the stored thumbnailUrl, which may be missing for legacy content.
  static String resolveThumbnailUrl(ContentModel content) {
    // Mux poster: free, generated automatically, served from image.mux.com CDN
    if (content.hasMuxHls) {
      final muxThumb =
          'https://image.mux.com/${content.muxPlaybackId}/thumbnail.jpg'
          '?time=0&width=480&fit_mode=smartcrop';
      _log('ContentMediaResolver.resolveThumbnailUrl: Mux → $muxThumb');
      return muxThumb;
    }
    return resolveUrl(content.thumbnailUrl);
  }

  /// Builds a cached player for any supported video source string.
  static CachedVideoPlayerPlus createPlayerForUrl(
    String url, {
    String? cacheKey,
  }) {
    if (url.startsWith('file://')) {
      final path = url.replaceFirst('file://', '');
      return CachedVideoPlayerPlus.file(File(path));
    }

    if (url.startsWith('asset://')) {
      final assetPath = url
          .replaceFirst('asset:///', '')
          .replaceFirst('asset://', '');
      return CachedVideoPlayerPlus.asset(assetPath);
    }

    if (_looksLikeLocalPath(url)) {
      return CachedVideoPlayerPlus.file(File(url));
    }

    // HLS streams (.m3u8) and MP4s both work via networkUrl.
    // On iOS, AVPlayer handles HLS natively — no additional setup needed.
    // On Android, ExoPlayer handles both.
    return CachedVideoPlayerPlus.networkUrl(
      Uri.parse(url),
      cacheKey: '${cacheKey ?? ""}|$url',
      // Let the native player stream. The cache package otherwise starts a
      // second whole-file download for every preload, including HLS manifests.
      skipCache: true,
      invalidateCacheIfOlderThan: const Duration(days: 7),
    );
  }

  static CachedVideoPlayerPlus? createPlayerForContent(ContentModel content) {
    final url = resolveVideoUrl(content);
    if (url.isEmpty) {
      _log('ContentMediaResolver.createPlayerForContent: empty url');
      return null;
    }

    _log('ContentMediaResolver.createPlayerForContent: $url');
    return createPlayerForUrl(url, cacheKey: sourceKey(content));
  }

  static CachedVideoPlayerPlus? createPlayerForSource(String source) {
    final url = resolveUrl(source);
    if (url.isEmpty) return null;
    return createPlayerForUrl(url, cacheKey: url);
  }

  static bool _looksLikeLocalPath(String url) {
    if (url.startsWith('/')) return true;
    return RegExp(r'^[A-Za-z]:\\').hasMatch(url);
  }
}
