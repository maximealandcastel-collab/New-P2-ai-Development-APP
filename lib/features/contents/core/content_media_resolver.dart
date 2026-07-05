import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';

class ContentMediaResolver {
  ContentMediaResolver._();

  static String resolveUrl(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) {
      debugPrint('ContentMediaResolver.resolveUrl: raw url is empty');
      return '';
    }

    String fullUrl;

    if (value.startsWith('http://') ||
        value.startsWith('https://') ||
        value.startsWith('file://') ||
        value.startsWith('asset://')) {
      fullUrl = value;
    } else if (value.startsWith('/')) {
      fullUrl = '${ApiConstants.baseUrl}$value';
    } else {
      fullUrl = '${ApiConstants.baseUrl}/$value';
    }

    debugPrint('ContentMediaResolver.resolveUrl: fullUrl (before encode) → $fullUrl');

    if (fullUrl.startsWith('asset://') || fullUrl.startsWith('file://')) {
      return fullUrl;
    }

    final encoded = Uri.encodeFull(fullUrl);
    debugPrint('ContentMediaResolver.resolveUrl: encoded → $encoded');
    return encoded;
  }

  static Media? mediaFromContent(ContentModel content) {
    debugPrint('ContentMediaResolver.mediaFromContent: videoUrl → ${content.videoUrl}');
    final url = resolveUrl(content.videoUrl);
    if (url.isEmpty) {
      debugPrint('ContentMediaResolver.mediaFromContent: resolved url is empty, returning null');
      return null;
    }
    debugPrint('ContentMediaResolver.mediaFromContent: final media url → $url');
    return Media(url);
  }

  static Media mediaFromSource(String source) {
    debugPrint('ContentMediaResolver.mediaFromSource: source → $source');
    final url = resolveUrl(source);
    if (url.startsWith('asset://')) {
      final assetUrl = url.replaceFirst('asset://', 'asset:///');
      debugPrint('ContentMediaResolver.mediaFromSource: asset url → $assetUrl');
      return Media(assetUrl);
    }
    debugPrint('ContentMediaResolver.mediaFromSource: final media url → $url');
    return Media(url);
  }

  static Media mediaFromAsset(String assetPath) {
    final normalized = assetPath.startsWith('assets/')
        ? assetPath
        : 'assets/$assetPath';
    final url = 'asset:///$normalized';
    debugPrint('ContentMediaResolver.mediaFromAsset: url → $url');
    return Media(url);
  }

  static Media mediaFromFile(String filePath) {
    debugPrint('ContentMediaResolver.mediaFromFile: filePath → $filePath');
    return Media('file://$filePath');
  }
}