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

  static String resolveVideoUrl(ContentModel content) {
    return resolveUrl(content.videoUrl);
  }

  static String resolveThumbnailUrl(ContentModel content) {
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

    return CachedVideoPlayerPlus.networkUrl(
      Uri.parse(url),
      cacheKey: cacheKey ?? url,
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
    return createPlayerForUrl(url, cacheKey: content.id ?? url);
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
