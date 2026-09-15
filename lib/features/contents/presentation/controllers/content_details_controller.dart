import 'dart:async';

import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:floating/floating.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/contents/core/content_media_resolver.dart';
import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';
import 'package:video_player/video_player.dart';

class ContentDetailsController extends GetxController with WidgetsBindingObserver {
  ContentDetailsController({
    this.content,
    this.videoUrl,
  }) : assert(
          content != null || (videoUrl != null && videoUrl.trim().isNotEmpty),
          'Either content or videoUrl is required.',
        );

  final ContentModel? content;
  final String? videoUrl;

  CachedVideoPlayerPlus? _cachedPlayer;
  final Floating _floating = Floating();

  final RxDouble playbackSpeed = 1.0.obs;
  final RxBool pipAvailable = false.obs;
  final RxBool isLoadingMedia = true.obs;
  final RxString mediaError = ''.obs;
  final RxBool isPlaying = false.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> duration = Duration.zero.obs;

  bool _isClosed = false;
  int _loadGeneration = 0;
  bool _pausedExternally = false; // set when tab switch or app background pauses the video
  VoidCallback? _videoListener;

  static const playbackSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  static ContentDetailsController get to => Get.find<ContentDetailsController>();

  VideoPlayerController? get videoPlayerController =>
      isVideoReady ? _cachedPlayer!.controller : null;

  bool get isVideoReady => _cachedPlayer?.isInitialized ?? false;

  double get aspectRatio {
    final controller = videoPlayerController;
    if (controller == null || !controller.value.isInitialized) return 1;
    final ratio = controller.value.aspectRatio;
    return ratio == 0 ? 1 : ratio;
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadMedia();
    _checkPipAvailability();
  }

  @override
  void onReady() {
    super.onReady();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      unawaited(_ensureAutoPlay());
    });
  }

  Future<void> _loadMedia() async {
    if (_isClosed) return;
    final generation = ++_loadGeneration;
    isLoadingMedia.value = true;
    mediaError.value = '';
    await _disposePlayer();
    final urls = content != null
        ? ContentMediaResolver.videoCandidates(content!)
        : [ContentMediaResolver.resolveUrl(videoUrl)].where((url) => url.isNotEmpty).toList();
    try {
      if (urls.isEmpty) {
        if (!_isClosed && generation == _loadGeneration) {
          mediaError.value = 'No video available for this content.';
        }
        return;
      }
      for (final url in urls) {
        if (_isClosed || generation != _loadGeneration) return;
        final player = ContentMediaResolver.createPlayerForUrl(url);
        try {
          await ContentMediaResolver.initializePlayer(player);
          if (_isClosed || generation != _loadGeneration) {
            await player.dispose();
            return;
          }
          final controller = player.controller;
          await controller.setLooping(true);
          await controller.setPlaybackSpeed(playbackSpeed.value);
          if (_isClosed || generation != _loadGeneration) {
            await player.dispose();
            return;
          }
          _cachedPlayer = player;
          _attachVideoListener();
          await _ensureAutoPlay();
          return;
        } catch (error) {
          try { await player.dispose(); } catch (_) {}
          if (_isClosed || generation != _loadGeneration) return;
          if (identical(_cachedPlayer, player)) _cachedPlayer = null;
          if (kDebugMode) debugPrint('Video load failed: ${error.runtimeType}');
        }
      }
      if (!_isClosed && generation == _loadGeneration) {
        mediaError.value = 'Unable to load this video. Check your connection and retry.';
      }
    } finally {
      if (!_isClosed && generation == _loadGeneration) isLoadingMedia.value = false;
    }
  }

  Future<void> retryLoad() => _loadMedia();

  Future<void> _ensureAutoPlay() async {
    if (_isClosed || _pausedExternally || mediaError.value.isNotEmpty) return;
    final controller = videoPlayerController;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      if (!controller.value.isPlaying) {
        await controller.play();
        if (_isClosed || _pausedExternally || controller != videoPlayerController) {
          await controller.pause();
          return;
        }
        isPlaying.value = true;
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('ContentDetailsController._ensureAutoPlay: $error');
      }
    }
  }

  Future<void> togglePlayback() async {
    final controller = videoPlayerController;
    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.isPlaying) {
      await controller.pause();
      isPlaying.value = false;
    } else {
      _pausedExternally = false; // user explicitly resumed
      await controller.play();
      isPlaying.value = true;
    }
  }

  Future<void> seekTo(Duration target) async {
    final controller = videoPlayerController;
    if (controller == null || !controller.value.isInitialized) return;
    await controller.seekTo(target);
    position.value = target;
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
    final controller = videoPlayerController;
    if (controller == null || !controller.value.isInitialized) return;
    await controller.setPlaybackSpeed(speed);
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

  void _attachVideoListener() {
    _detachVideoListener();
    final controller = videoPlayerController;
    if (controller == null) return;

    _videoListener = () {
      if (_isClosed) return;
      if (controller.value.hasError) {
        mediaError.value = 'Playback stopped. Please retry this video.';
        isPlaying.value = false;
        return;
      }
      position.value = controller.value.position;
      duration.value = controller.value.duration;
      isPlaying.value = controller.value.isPlaying;
    };
    controller.addListener(_videoListener!);
    _videoListener!();
  }

  void _detachVideoListener() {
    final controller = videoPlayerController;
    if (_videoListener != null && controller != null) {
      controller.removeListener(_videoListener!);
    }
    _videoListener = null;
  }

  Future<void> _disposePlayer() async {
    _detachVideoListener();
    final player = _cachedPlayer;
    _cachedPlayer = null;
    try {
      await player?.dispose();
    } catch (_) {}
  }

  /// Pause the video immediately. Safe to call from outside the controller
  /// (e.g. tab switch, app background). Sets [_pausedExternally] so that
  /// [_ensureAutoPlay] does not auto-resume until the user taps play.
  void pauseVideo() {
    _pausedExternally = true;
    final ctrl = videoPlayerController;
    if (ctrl != null && ctrl.value.isInitialized && ctrl.value.isPlaying) {
      ctrl.pause();
      isPlaying.value = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      pauseVideo();
    }
  }

  @override
  void onClose() {
    _isClosed = true;
    _loadGeneration++;
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_disposePlayer());
    super.onClose();
  }
}
