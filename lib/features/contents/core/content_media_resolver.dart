import 'package:media_kit/media_kit.dart';
import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';

class ContentMediaResolver {
  ContentMediaResolver._();

  static String resolveUrl(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return '';

    if (value.startsWith('http://') ||
        value.startsWith('https://') ||
        value.startsWith('file://') ||
        value.startsWith('asset://')) {
      return value;
    }

    if (value.startsWith('/')) {
      return '${ApiConstants.baseUrl}$value';
    }

    return '${ApiConstants.baseUrl}/$value';
  }

  static Media? mediaFromContent(ContentModel content) {
    final url = resolveUrl(content.videoUrl);
    if (url.isEmpty) return null;
    return Media(url);
  }

  static Media mediaFromSource(String source) {
    final url = resolveUrl(source);
    if (url.startsWith('asset://')) {
      return Media(url.replaceFirst('asset://', 'asset:///'));
    }
    return Media(url);
  }

  static Media mediaFromAsset(String assetPath) {
    final normalized = assetPath.startsWith('assets/')
        ? assetPath
        : 'assets/$assetPath';
    return Media('asset:///$normalized');
  }

  static Media mediaFromFile(String filePath) {
    return Media('file://$filePath');
  }
}
