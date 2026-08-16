import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/services/api_urls.dart';
import 'package:pler_to_pler_app/services/network/api_client.dart';
import 'package:video_player/video_player.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// CONTENTS SCREEN — TikTok-style vertical video feed
// Dark full-screen vertical swipe feed. Each page shows one exercise video
// streamed from the backend video library (GET /content/feed).
// Community tab  → workout reels from all trainers
// My Trainer tab → videos from the subscriber's assigned trainer
// ═══════════════════════════════════════════════════════════════════════════════

class _FeedVideo {
  final String title;
  final String? videoUrl;
  final String? thumbnailUrl;
  const _FeedVideo({required this.title, this.videoUrl, this.thumbnailUrl});
}

/// Server origin without the /api/v1 suffix.
String _origin() => ApiUrls.baseUrl.replaceFirst(RegExp(r'/api/v1/?$'), '');

String? _absolute(String? u) {
  if (u == null || u.isEmpty) return null;
  return u.startsWith('http') ? u : '${_origin()}$u';
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

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    try {
      final response = await ApiClient.getData('/content/feed');
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
    setState(() => _tab = tab);
    if (_pageCtrl.hasClients) _pageCtrl.jumpToPage(0);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Full-screen vertical video pager ──────────────────────────
          if (_loading)
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else if (_videos.isEmpty)
            Center(
              child: Text(
                _tab == 1
                    ? 'No trainer videos yet.\nSubscribe to a trainer to see their content.'
                    : 'No community videos available yet.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            )
          else
            PageView.builder(
              controller: _pageCtrl,
              scrollDirection: Axis.vertical,
              itemCount: _videos.length,
              itemBuilder: (ctx, i) => _VideoPage(video: _videos[i]),
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
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
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
  const _VideoPage({required this.video});

  @override
  State<_VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<_VideoPage> {
  VideoPlayerController? _ctrl;
  bool _ready = false;
  bool _tapped = false; // show pause icon briefly on tap

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final url = widget.video.videoUrl;
    if (url == null || url.isEmpty) return;
    try {
      _ctrl = VideoPlayerController.networkUrl(Uri.parse(url))
        ..setLooping(true)
        ..initialize().then((_) {
          if (mounted) {
            setState(() => _ready = true);
            _ctrl!.play();
          }
        });
    } catch (e) {
      log('video init error: $e');
    }
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_ctrl == null) return;
    setState(() {
      _tapped = true;
      _ctrl!.value.isPlaying ? _ctrl!.pause() : _ctrl!.play();
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
              child: AnimatedOpacity(
                opacity: _tapped ? 1 : 0,
                duration: const Duration(milliseconds: 200),
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
                fontWeight: FontWeight.w600,
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
