import 'dart:developer';

import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/constants/app_constants.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:pler_to_pler_app/core/services/video_playback_manager.dart';
import 'package:pler_to_pler_app/services/api_urls.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// CONTENTS SCREEN — TikTok-style vertical video feed
// Dark full-screen vertical swipe feed. Each page shows one exercise video
// streamed from the backend video library (GET /content/feed).
// Community tab  → workout reels from all trainers
// My Trainer tab → videos from the subscriber's assigned trainer
//
// PLAYBACK OWNERSHIP — read before changing anything here.
// This screen is a tab inside an IndexedStack, so its State is NOT disposed
// when the user switches tabs and dispose() is therefore useless as a teardown
// hook. Playback is instead owned by VideoPlaybackManager and gated two ways:
//   1. A screen-level VisibilityDetector enters/exits the manager's video
//      module. Leaving the tab, or pushing any route on top, drops visibility
//      to zero and hard-stops every player — this is what stopped audio from
//      following the user onto the dashboard.
//   2. Only the centred page is marked active, so the pages PageView builds
//      ahead of and behind it stay silent instead of stacking audio.
// ═══════════════════════════════════════════════════════════════════════════════

class _FeedVideo {
  final String title;
  final String? videoUrl;
  final String? thumbnailUrl;
  const _FeedVideo({required this.title, this.videoUrl, this.thumbnailUrl});
}

/// Server origin without the /api/v1 suffix — used for relative media URLs.
String _origin() => ApiUrls.baseUrl.replaceFirst(RegExp(r'/api/v1/?$'), '');

String? _absolute(String? u) {
  if (u == null || u.isEmpty) return null;
  return u.startsWith('http') ? u : '${_origin()}$u';
}

/// GET helper. The session token lives in Hive via CacheService — this used to
/// read SharedPreferences('accessToken'), which the login flow never writes, so
/// every feed request went out unauthenticated.
Future<Response> _get(String path) async {
  String? token;
  try {
    token = Get.find<CacheService>().get<String>(AppConstants.accessToken);
  } catch (_) {
    token = null;
  }
  final connect = GetConnect();
  return connect.get(
    '${ApiUrls.baseUrl}$path',
    headers: {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    },
  );
}

class ContentsScreen extends StatefulWidget {
  const ContentsScreen({super.key});

  @override
  State<ContentsScreen> createState() => _ContentsScreenState();
}

class _ContentsScreenState extends State<ContentsScreen> {
  int _tab = 0; // 0 = Community, 1 = My Trainer
  final PageController _pageCtrl = PageController();

  bool _loading = true;
  List<_FeedVideo> _community = const [];
  List<_FeedVideo> _trainer = const [];

  /// Index of the page currently centred in the pager. Only this page plays.
  int _currentPage = 0;

  /// Whether this screen is on screen right now. Drives the manager's module
  /// gate, and is passed down so pages re-evaluate when the tab comes back.
  bool _visible = false;

  VideoPlaybackManager? get _vpm =>
      Get.isRegistered<VideoPlaybackManager>()
          ? Get.find<VideoPlaybackManager>()
          : null;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    try {
      final response = await _get('/content/feed');
      if (response.statusCode == 200 && response.body is Map) {
        final data = (response.body as Map)['data'];
        if (data is Map) {
          List<_FeedVideo> parse(dynamic list) {
            if (list is! List) return const [];
            return list.whereType<Map>().map((v) => _FeedVideo(
              title: v['title']?.toString() ?? 'Workout',
              videoUrl: _absolute(v['videoUrl']?.toString()),
              thumbnailUrl: _absolute(v['thumbnailUrl']?.toString()),
            )).toList();
          }
          setState(() {
            _community = parse(data['community']);
            _trainer = parse(data['trainer']);
            _loading = false;
          });
          return;
        }
      }
    } catch (e) {
      log('feed load error: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  List<_FeedVideo> get _videos => _tab == 0 ? _community : _trainer;

  void _switchTab(int tab) {
    if (tab == _tab) return;
    setState(() {
      _tab = tab;
      _currentPage = 0;
    });
    if (_pageCtrl.hasClients) _pageCtrl.jumpToPage(0);
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    final visible = info.visibleFraction > 0.5;
    if (visible == _visible) return;

    final manager = _vpm;
    if (visible) {
      manager?.enterVideoModule();
    } else {
      // exitVideoModule() hard-stops every tracked player. This is the single
      // line that eliminates the dashboard audio bleed.
      manager?.exitVideoModule();
    }
    if (mounted) setState(() => _visible = visible);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _vpm?.exitVideoModule();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('contentsScreenVisibility'),
      onVisibilityChanged: _onVisibilityChanged,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // ── Full-screen vertical video pager ──────────────────────────
            if (_loading)
              const Center(child: CircularProgressIndicator(color: Colors.white))
            else if (_videos.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: Text(
                    _tab == 1
                        ? 'No trainer videos yet.\nSubscribe to a trainer to see their content.'
                        : 'No community videos available yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15.sp,
                      height: 1.6,
                    ),
                  ),
                ),
              )
            else
              PageView.builder(
                controller: _pageCtrl,
                scrollDirection: Axis.vertical,
                itemCount: _videos.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (ctx, i) => _VideoPage(
                  video: _videos[i],
                  // PageView builds neighbours; only the centred page is
                  // allowed to play, which is what stops overlapping audio.
                  isActive: i == _currentPage && _visible,
                ),
              ),

            // ── Top pill tabs ─────────────────────────────────────────────
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(3.r),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _pill('Community', 0),
                      _pill('My Trainer', 1),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String label, int index) {
    final active = _tab == index;
    return GestureDetector(
      onTap: () => _switchTab(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.black : Colors.white70,
            fontSize: 13.sp,
            fontWeight: active ? AppFontWeight.section : AppFontWeight.emphasis,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single full-screen video page
// ─────────────────────────────────────────────────────────────────────────────
class _VideoPage extends StatefulWidget {
  final _FeedVideo video;

  /// True only for the centred page of a visible feed. Everything else stays
  /// paused and muted, however many pages the PageView has built.
  final bool isActive;

  const _VideoPage({required this.video, required this.isActive});

  @override
  State<_VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<_VideoPage> {
  VideoPlayerController? _ctrl;
  bool _ready = false;
  bool _tapped = false;

  /// Set when the user explicitly pauses, so becoming active again does not
  /// override their choice.
  bool _userPaused = false;

  VideoPlaybackManager? get _vpm =>
      Get.isRegistered<VideoPlaybackManager>()
          ? Get.find<VideoPlaybackManager>()
          : null;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(covariant _VideoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      _userPaused = false;
      _syncPlayback();
    }
  }

  Future<void> _init() async {
    final url = widget.video.videoUrl;
    if (url == null || url.isEmpty) return;
    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url))
        ..setLooping(true);
      _ctrl = controller;
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _ready = true);
      _syncPlayback();
    } catch (e) {
      log('video init error: $e');
    }
  }

  /// Single place that decides whether this page's player should be running.
  /// Routing through the manager rather than calling play() directly is what
  /// enforces one-player-at-a-time and the module gate.
  void _syncPlayback() {
    final controller = _ctrl;
    final manager = _vpm;
    if (controller == null || !controller.value.isInitialized) return;

    if (widget.isActive && !_userPaused) {
      if (manager != null) {
        manager.play(controller);
      } else {
        controller.play();
      }
    } else {
      controller.pause();
    }
  }

  @override
  void dispose() {
    final controller = _ctrl;
    if (controller != null) {
      _vpm?.unregisterPlayer(controller);
      controller.dispose();
    }
    super.dispose();
  }

  void _togglePlay() {
    final controller = _ctrl;
    if (controller == null || !controller.value.isInitialized) return;
    setState(() {
      _tapped = true;
      if (controller.value.isPlaying) {
        _userPaused = true;
        controller.pause();
      } else {
        _userPaused = false;
        _vpm?.play(controller) ?? controller.play();
      }
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _tapped = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlay,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail while video loads
          if (widget.video.thumbnailUrl != null && !_ready)
            Image.network(
              widget.video.thumbnailUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const ColoredBox(color: Colors.black),
            )
          else if (!_ready)
            const ColoredBox(color: Colors.black),

          // Video
          if (_ready && _ctrl != null)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _ctrl!.value.size.width,
                height: _ctrl!.value.size.height,
                child: VideoPlayer(_ctrl!),
              ),
            ),

          // Loading spinner
          if (!_ready)
            const Center(
              child: CircularProgressIndicator(color: Colors.white54),
            ),

          // Pause/play icon flash on tap
          if (_tapped)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _ctrl?.value.isPlaying ?? false
                      ? Icons.play_arrow_rounded
                      : Icons.pause_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),

          // Title overlay at bottom
          Positioned(
            left: 16,
            right: 80,
            bottom: 100,
            child: Text(
              widget.video.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: AppFontWeight.label,
                shadows: [Shadow(blurRadius: 8, color: Colors.black87)],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
