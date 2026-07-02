import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';

class VideoPlayerArgs {
  const VideoPlayerArgs({
    required this.videoUrl,
    this.title,
  });

  final String videoUrl;
  final String? title;

  static Future<T?>? open<T>({
    required String videoUrl,
    String? title,
  }) {
    return Get.toNamed<T>(
      AppRoute.videoPlayerScreen,
      arguments: VideoPlayerArgs(
        videoUrl: videoUrl,
        title: title,
      ),
    );
  }
}
