import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pler_to_pler_app/services/api_urls.dart';
import 'package:video_player/video_player.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// CONTENTS SCREEN — TikTok-style vertical video feed
// ═══════════════════════════════════════════════════════════════════════════════

class _FeedVideo {
  final String title;
  final String videoUrl;
  const _FeedVideo({required this.title, required this.videoUrl});
}

/// Server origin (strips /api/v1 suffix).
String _origin() => ApiUrls.baseUrl.replaceFirst(RegExp(r'/api/v1/?$'), '');

String _absolute(String u) =>
    u.startsWith('http') ? u : '${_origin()}$u';

/// Fetch the feed using the http package — reliable, no GetConnect quirks.
Future<Map<String, dynamic>?> _fetchFeed() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final uri = Uri.parse('${ApiUrls.baseUrl}/content/feed');
    final res = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    }).timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) {
      return json.decode(res.body) as Map<String, dynamic>;
    }
    log('feed: HTTP ${res.statusCode}');
  } catch (e) {
    log('feed fetch error: $e');
  }
  return null;
}

List<_FeedVideo> _parseVideos(dynamic list) {
  if (list is! List) return const [];
  return list.whereType<Map>().map((v) {
    final rawUrl = v['videoUrl']?.toString() ?? '';
    return _FeedVideo(
      title: v['title']?.toString() ?? 'Workout',
      videoUrl: rawUrl.isEmpty ? '' : _absolute(rawUrl),
    );
  }).where((v) => v.videoUrl.isNotEmpty).toList();
}

class ContentsScreen extends StatefulWidget {
  const ContentsScreen({super.key});

  @override
  State<ContentsScreen> createState() => _ContentsScreenState();
}

class _ContentsScreenState extends State<ContentsScreen> {
  int _tab = 0;
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  bool _loading = true;
  String? _error;
  List<_FeedVideo> _community = const [];
  List<_FeedVideo> _trainer = const [];

  @override
  void initState() {
    super.initState();
    _pageCtrl.addListener(_onScroll);
    _loadFeed();
  }

  void _onScroll() {
    final page = _pageCtrl.page?.round() ?? 0;
    if (page != _currentPage) setState(() => _currentPage = page);
  }

  Future<void> _loadFeed() async {
    setState(() { _loading = true; _error = null; });
    final data = await _fetchFeed();
    if (!mounted) return;
    if (data == null) {
      setState(() { _loading = false; _error = 'Could not load videos. Pull down to retry.'; });
      return;
    }
    final feedData = data['data'];
    setState(() {
      _loading = false;
      if (feedData is Map) {
        _community = _parseVideos(feedData['community']);
        _trainer   = _parseVideos(feedData['trainer']);
      }
    });
  }

  List<_FeedVideo> get _videos => _tab == 0 ? _community : _trainer;

  void _switchTab(int tab) {
    if (tab == _tab) return;
    setState(() { _tab = tab; _currentPage = 0; });
    if (_pageCtrl.hasClients) _pageCtrl.jumpToPage(0);
  }

  @override
  void dispose() {
    _pageCtrl.removeListener(_onScroll);
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Body ─────────────────────────────────────────────────────
          if (_loading)
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else if (_error != null)
            Center(
              child: GestureDetector(
                onTap: _loadFeed,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.refresh_rounded, color: Colors.white54, size: 40),
                      SizedBox(height: 12.h),
                      Text(_error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, fontSize: 14.sp, height: 1.5)),
                    ],
                  ),
                ),
              ),
            )
          else if (_videos.isEmpty)
            Center(
              child: Text(
                _tab == 1
                    ? 'No trainer videos yet.\nSubscribe to a trainer to unlock their content.'
                    : 'No videos yet.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 15.sp, height: 1.6),
              ),
            )
          else
            // Only mount the current page's video — swipe activates the next
            PageView.builder(
              controller: _pageCtrl,
              scrollDirection: Axis.vertical,
              itemCount: _videos.length,
              itemBuilder: (ctx, i) => _VideoPage(
                video: _videos[i],
                active: i == _currentPage,
              ),
            ),

          // ── Pill tabs ─────────────────────────────────────────────────
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
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  _pill('Community', 0),
                  _pill('My Trainer', 1),
                ]),
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
        child: Text(label, style: TextStyle(
          color: active ? Colors.black : Colors.white70,
          fontSize: 13.sp,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
        )),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single video page — only initialises the player when active=true
// ─────────────────────────────────────────────────────────────────────────────
class _VideoPage extends StatefulWidget {
  final _FeedVideo video;
  final bool active;
  const _VideoPage({required this.video, required this.active});

  @override
  State<_VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<_VideoPage> {
  VideoPlayerController? _ctrl;
  bool _ready = false;
  bool _showIcon = false;
  bool _iconIsPlay = false;

  @override
  void initState() {
    super.initState();
    if (widget.active) _initPlayer();
  }

  @override
  void didUpdateWidget(_VideoPage old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) {
      // Page became active — start player
      if (_ctrl == null) _initPlayer(); else _ctrl!.play();
    } else if (!widget.active && old.active) {
      // Page left — pause to save bandwidth
      _ctrl?.pause();
    }
  }

  Future<void> _initPlayer() async {
    try {
      final ctrl = VideoPlayerController.networkUrl(
        Uri.parse(widget.video.videoUrl),
      );
      await ctrl.initialize();
      if (!mounted) { ctrl.dispose(); return; }
      ctrl.setLooping(true);
      ctrl.play();
      setState(() { _ctrl = ctrl; _ready = true; });
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
    if (_ctrl == null || !_ready) return;
    final willPlay = !_ctrl!.value.isPlaying;
    willPlay ? _ctrl!.play() : _ctrl!.pause();
    setState(() { _showIcon = true; _iconIsPlay = willPlay; });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _showIcon = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlay,
      child: Stack(fit: StackFit.expand, children: [
        // Black base
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

        // Spinner while loading
        if (!_ready)
          const Center(child: CircularProgressIndicator(color: Colors.white54)),

        // Pause/play flash
        if (_showIcon)
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
              child: Icon(
                _iconIsPlay ? Icons.play_arrow_rounded : Icons.pause_rounded,
                color: Colors.white, size: 52,
              ),
            ),
          ),

        // Title
        Positioned(
          left: 16, right: 80, bottom: 110,
          child: Text(widget.video.title,
            style: const TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600,
              shadows: [Shadow(blurRadius: 8, color: Colors.black87)],
            ),
            maxLines: 2, overflow: TextOverflow.ellipsis,
          ),
        ),
      ]),
    );
  }
}
