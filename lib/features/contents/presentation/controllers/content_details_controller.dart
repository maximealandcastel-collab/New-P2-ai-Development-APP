import 'dart:async';

import 'package:floating/floating.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:pler_to_pler_app/features/contents/core/content_media_resolver.dart';
import 'package:pler_to_pler_app/features/contents/core/reel_player_pool.dart';
import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';

class ContentDetailsController extends GetxController {
  ContentDetailsController({
    this.content,
    this.videoUrl,
    this.handoff,
    this.onHandoffRelease,
  }) : assert(
          content != null || (videoUrl != null && videoUrl.trim().isNotEmpty),
          'Either content or videoUrl is required.',
        );

  final ContentModel? content;
  final String? videoUrl;
  final ReelPlayerHandoff? handoff;
  final void Function(ReelPlayerHandoff handoff)? onHandoffRelease;

  late final Player player;
  late final VideoController videoController;
  late final bool _ownsPlayer;
  final Floating _floating = Floating();

  final RxDouble playbackSpeed = 1.0.obs;
  final RxBool pipAvailable = false.obs;
  final RxBool isLoadingMedia = true.obs;
  final RxBool hasMediaOpened = false.obs;
  final RxString mediaError = ''.obs;
  final RxList<SubtitleTrack> subtitleTracks = <SubtitleTrack>[].obs;
  final Rxn<SubtitleTrack> selectedSubtitle = Rxn<SubtitleTrack>();

  StreamSubscription<String>? _errorSub;
  bool _isClosed = false;
  String? _loadedMediaUri;
  Future<void>? _loadFuture;

  static const playbackSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  static ContentDetailsController get to => Get.find<ContentDetailsController>();

  @override
  void onInit() {
    super.onInit();

    if (handoff != null) {
      _ownsPlayer = false;
      player = handoff!.slot.player;
      videoController = handoff!.slot.videoController;
      isLoadingMedia.value = false;
      hasMediaOpened.value = true;
    } else {
      _ownsPlayer = true;
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
    }

    _listenTracks();
    _listenPlayerErrors();
    _checkPipAvailability();

    if (handoff != null) {
      unawaited(_prepareHandoffPlayback());
    } else {
      _loadFuture = _loadMedia();
    }
  }

  void _listenTracks() {
    player.stream.tracks.listen((tracks) {
      subtitleTracks.assignAll(tracks.subtitle);
    });
    player.stream.track.listen((track) {
      selectedSubtitle.value =
          track.subtitle.id == 'no' ? null : track.subtitle;
    });
  }

  void _listenPlayerErrors() {
    _errorSub = player.stream.error.listen((error) {
      if (error.isEmpty) return;
      mediaError.value = 'Player error: $error';
      if (kDebugMode) {
        debugPrint('ContentDetailsController player error: $error');
      }
    });
  }

  Future<void> _prepareHandoffPlayback() async {
    if (_isClosed) return;

    try {
      await player.setPlaylistMode(PlaylistMode.loop);
      await player.setRate(playbackSpeed.value);
      if (!player.state.playing) {
        await player.play();
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('ContentDetailsController._prepareHandoffPlayback: $error');
      }
    }
  }

  Future<void> _loadMedia() async {
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
        return;
      }

      if (_loadedMediaUri == media.uri && hasMediaOpened.value) {
        isLoadingMedia.value = false;
        return;
      }

      isLoadingMedia.value = true;

      await player.setPlaylistMode(PlaylistMode.loop);
      await player.open(media, play: true);
      await player.setRate(playbackSpeed.value);
      _loadedMediaUri = media.uri;
      hasMediaOpened.value = true;
    } catch (error, stack) {
      mediaError.value = 'Unable to play this video.';
      if (kDebugMode) {
        debugPrint('_loadMedia ERROR: $error');
        debugPrint('_loadMedia STACK: $stack');
      }
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
    _isClosed = true;
    unawaited(_errorSub?.cancel());

    if (!_ownsPlayer) {
      final activeHandoff = handoff;
      if (activeHandoff != null && onHandoffRelease != null) {
        onHandoffRelease!(activeHandoff);
      }
    } else {
      unawaited(_loadFuture);
      player.dispose();
    }

    super.onClose();
  }
}
