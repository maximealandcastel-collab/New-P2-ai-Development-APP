import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:pler_to_pler_app/features/contents/core/content_media_resolver.dart';

class WorkoutVideoController extends GetxController {
  WorkoutVideoController({required this.videoUrl});

  final String videoUrl;

  late final Player player;
  late final VideoController videoController;

  final RxBool isLoadingMedia = true.obs;
  final RxString mediaError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    player = Player();
    videoController = VideoController(player);
    _loadMedia();
  }

  Future<void> _loadMedia() async {
    isLoadingMedia.value = true;
    mediaError.value = '';

    try {
      final media = ContentMediaResolver.mediaFromSource(videoUrl);
      await player.open(media);
    } catch (error) {
      mediaError.value = 'Unable to play this video.';
      if (kDebugMode) debugPrint('WorkoutVideoController._loadMedia: $error');
    } finally {
      isLoadingMedia.value = false;
    }
  }

  @override
  void onClose() {
    player.dispose();
    super.onClose();
  }
}
