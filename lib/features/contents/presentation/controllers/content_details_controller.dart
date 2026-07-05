import 'package:floating/floating.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:pler_to_pler_app/features/contents/core/content_media_resolver.dart';
import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';

class ContentDetailsController extends GetxController {
  ContentDetailsController({
    this.content,
    this.videoUrl,
  }) : assert(
  content != null || (videoUrl != null && videoUrl.trim().isNotEmpty),
  'Either content or videoUrl is required.',
  );

  final ContentModel? content;
  final String? videoUrl;

  late final Player player;
  late final VideoController videoController;
  final Floating _floating = Floating();

  final RxDouble playbackSpeed = 1.0.obs;
  final RxBool pipAvailable = false.obs;
  final RxBool isLoadingMedia = true.obs;
  final RxString mediaError = ''.obs;
  final RxList<SubtitleTrack> subtitleTracks = <SubtitleTrack>[].obs;
  final Rxn<SubtitleTrack> selectedSubtitle = Rxn<SubtitleTrack>();

  static const playbackSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  static ContentDetailsController get to => Get.find<ContentDetailsController>();

  @override
  void onInit() {
    super.onInit();
    player = Player(
      configuration: const PlayerConfiguration(
        libass: true,
      ),
    );
    videoController = VideoController(
      player,
      configuration: const VideoControllerConfiguration(
        enableHardwareAcceleration: true,
      ),
    );
    _listenTracks();
    _loadMedia();
    _checkPipAvailability();
  }

  void _listenTracks() {
    player.stream.tracks.listen((tracks) {
      subtitleTracks.assignAll(tracks.subtitle);
    });
    player.stream.track.listen((track) {
      selectedSubtitle.value = track.subtitle.id == 'no' ? null : track.subtitle;
    });
  }

  Future<void> _loadMedia() async {
    isLoadingMedia.value = true;
    mediaError.value = '';

    try {
      final Media? media;
      if (content != null) {
        media = ContentMediaResolver.mediaFromContent(content!);
      } else {
        final url = videoUrl?.trim() ?? '';
        media = url.isEmpty ? null : ContentMediaResolver.mediaFromSource(url);
      }

      if (media == null) {
        mediaError.value = 'No video available for this content.';
        debugPrint('_loadMedia: media is null');
        return;
      }

      debugPrint('_loadMedia: opening media → ${media.uri}');
      await player.open(media);
      debugPrint('_loadMedia: player opened successfully');
      await player.setRate(playbackSpeed.value);

      // player stream থেকে error listen করো
      player.stream.error.listen((error) {
        debugPrint('_loadMedia player.stream.error → $error');
        if (error.isNotEmpty) {
          mediaError.value = 'Player error: $error';
        }
      });

      // buffering state
      player.stream.buffering.listen((isBuffering) {
        debugPrint('_loadMedia player.stream.buffering → $isBuffering');
      });

      // playing state
      player.stream.playing.listen((isPlaying) {
        debugPrint('_loadMedia player.stream.playing → $isPlaying');
      });

    } catch (error, stack) {
      mediaError.value = 'Unable to play this video.';
      debugPrint('_loadMedia ERROR: $error');
      debugPrint('_loadMedia STACK: $stack');
    } finally {
      isLoadingMedia.value = false;
    }
  }

  Future<void> _checkPipAvailability() async {
    try {
      pipAvailable.value = await _floating.isPipAvailable;
    } catch (_) {
      pipAvailable.value = false;
    }
  }

  Future<void> setPlaybackSpeed(double speed) async {
    playbackSpeed.value = speed;
    await player.setRate(speed);
  }

  Future<void> disableSubtitles() async {
    selectedSubtitle.value = null;
    await player.setSubtitleTrack(SubtitleTrack.no());
  }

  Future<void> selectSubtitle(SubtitleTrack track) async {
    selectedSubtitle.value = track;
    await player.setSubtitleTrack(track);
  }

  Future<void> loadExternalSubtitle(String source) async {
    final uri = ContentMediaResolver.resolveUrl(source);
    if (uri.isEmpty) return;

    await player.setSubtitleTrack(
      SubtitleTrack.uri(uri, title: 'External subtitle'),
    );
  }

  Future<void> enterPictureInPicture() async {
    if (!pipAvailable.value) return;

    try {
      await _floating.enable(
        ImmediatePiP(aspectRatio: const Rational(16, 9)),
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('ContentDetailsController.enterPictureInPicture: $error');
      }
    }
  }

  String subtitleLabel(SubtitleTrack track) {
    final title = track.title?.trim();
    if (title != null && title.isNotEmpty) return title;

    final language = track.language?.trim();
    if (language != null && language.isNotEmpty) return language;

    return 'Subtitle ${track.id}';
  }

  @override
  void onClose() {
    player.dispose();
    super.onClose();
  }
}