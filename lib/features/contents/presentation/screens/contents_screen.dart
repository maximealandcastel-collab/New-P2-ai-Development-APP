import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';
import 'package:pler_to_pler_app/features/contents/reels/core/reel_player_manager.dart';
import 'package:pler_to_pler_app/services/api_urls.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// CONTENTS SCREEN  ·  TikTok-style vertical video feed
//
// Architecture:
//  • ReelPlayerManager owns ALL VideoPlayerController instances.
//    It keeps a 5-slot pool: current + 2 forward + 1 backward + 1 reserve.
//    Every other slot is disposed → only ONE video plays at a time.
//  • _switchTab() calls pauseActive() before swapping state so there is
//    never ghost audio playing from the previous tab.
//  • WidgetsBindingObserver pauses / resumes on background / foreground.
// ═══════════════════════════════════════════════════════════════════════════════

class ContentsScreen extends StatefulWidget {
  const ContentsScreen({super.key});

  @override
  State<ContentsScreen> createState() => _ContentsScreenState();
}

class _ContentsScreenState extends State<ContentsScreen>
    with WidgetsBindingObserver {
  // ── Player manager (single source of truth for all controllers) ────────────
  late final ReelPlayerManager _mgr = ReelPlayerManager(
    onUpdated: _onMgrUpdate,
  );

  // ── Page / tab ─────────────────────────────────────────────────────────────
  final PageController _pageCtrl = PageController();
  int _tab = 0;         // 0 = Community, 1 = My Trainer
  int _currentPage = 0;

  // ── Feed state ─────────────────────────────────────────────────────────────
  bool _loading = true;
  String? _error;
  List<ContentModel> _community = const [];
  List<ContentModel> _trainerVideos = const [];

  List<ContentModel> get _videos => _tab == 0 ? _community : _trainerVideos;

  // ──────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageCtrl.addListener(_onPageScroll);
    _loadFeed();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageCtrl.removeListener(_onPageScroll);
    _pageCtrl.dispose();
    _mgr.releaseAll(); // dispose every slot before leaving screen
    super.dispose();
  }

  // ── App lifecycle: pause on background, resume on foreground ───────────────
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        _mgr.pauseActive();
        break;
      case AppLifecycleState.resumed:
        _mgr.playActive();
        break;
      case AppLifecycleState.hidden:
        _mgr.pauseActive();
        break;
    }
  }

  // ── Manager rebuild callback ───────────────────────────────────────────────
  void _onMgrUpdate() {
    if (mounted) setState(() {});
  }

  // ── PageView listener: sync manager whenever page changes ─────────────────
  void _onPageScroll() {
    final page = _pageCtrl.page?.round() ?? 0;
    if (page != _currentPage) {
      _currentPage = page;
      unawaited(_mgr.sync(
        index: page,
        contents: _videos,
        prioritizeNextPreload: true,
      ));
    }
  }

  // ── Fetch feed from backend ────────────────────────────────────────────────
  Future<void> _loadFeed() async {
    setState(() { _loading = true; _error = null; });
    final t0 = DateTime.now();
    log('[ContentsScreen] fetch start');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';
      final uri   = Uri.parse('${ApiUrls.baseUrl}/content/feed');

      final res = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      }).timeout(const Duration(seconds: 15));

      final ms = DateTime.now().difference(t0).inMilliseconds;
      log('[ContentsScreen] fetch done ${ms}ms  status=${res.statusCode}');

      if (res.statusCode == 200) {
        final body     = json.decode(res.body) as Map<String, dynamic>;
        final feedData = body['data'] as Map<String, dynamic>?;
        if (feedData != null) {
          final community = _parseList(feedData['community']);
          final trainer   = _parseList(feedData['trainer']);
          log('[ContentsScreen] community=${community.length}  trainer=${trainer.length}');

          if (!mounted) return;
          setState(() {
            _community      = community;
            _trainerVideos  = trainer;
            _loading        = false;
            _currentPage    = 0;
          });

          if (_videos.isNotEmpty) {
            unawaited(_mgr.sync(index: 0, contents: _videos));
          }
          return;
        }
      }
    } catch (e) {
      log('[ContentsScreen] fetch error: $e');
    }

    if (mounted) {
      setState(() {
        _loading = false;
        _error   = 'Could not load videos.\nTap to retry.';
      });
    }
  }

  /// Parse a raw JSON list into ContentModel, filtering out entries with no
  /// playable URL. Mux HLS takes priority; legacy videoUrl is the fallback.
  List<ContentModel> _parseList(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(ContentModel.fromJson)
        .where((c) => c.hasMuxHls || (c.videoUrl?.isNotEmpty ?? false))
        .toList();
  }

  // ── Switch Community ↔ My Trainer ──────────────────────────────────────────
  void _switchTab(int tab) {
    if (tab == _tab) return;
    _mgr.pauseActive(); // stop audio before changing the video list
    setState(() { _tab = tab; _currentPage = 0; });
    if (_pageCtrl.hasClients) _pageCtrl.jumpToPage(0);
    if (_videos.isNotEmpty) {
      unawaited(_mgr.sync(index: 0, contents: _videos));
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // BUILD
  // ──────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        _buildBody(context),
        _buildTabPills(context),
      ]),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2),
      );
    }
    if (_error != null) {
      return GestureDetector(
        onTap: _loadFeed,
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.refresh_rounded, color: Colors.white38, size: 46),
            SizedBox(height: 14.h),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 14.sp, height: 1.6),
            ),
          ]),
        ),
      );
    }
    if (_videos.isEmpty) {
      return Center(
        child: Text(
          _tab == 1
            ? 'No trainer videos yet.\nSubscribe to a trainer to see their content.'
            : 'No community videos yet.\nCheck back soon.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54, fontSize: 15.sp, height: 1.6),
        ),
      );
    }
    return PageView.builder(
      controller: _pageCtrl,
      scrollDirection: Axis.vertical,
      itemCount: _videos.length,
      itemBuilder: (ctx, i) => _buildVideoPage(i),
    );
  }

  // ── Individual video page (controller lives in _mgr, not here) ─────────────
  Widget _buildVideoPage(int index) {
    final slot  = _mgr.slotFor(index);
    final ctrl  = _mgr.controllerFor(index);
    final video = _videos[index];

    final isReady   = slot?.isReady ?? false;
    final isLoading = slot?.isLoading ?? (slot == null);
    final hasError  = slot != null && slot.error.isNotEmpty;

    return GestureDetector(
      // Tap to toggle play / pause
      onTap: () {
        if (ctrl == null) return;
        if (ctrl.value.isPlaying) {
          ctrl.pause();
        } else {
          ctrl.play();
        }
        setState(() {});
      },
      child: Stack(fit: StackFit.expand, children: [
        const ColoredBox(color: Colors.black),

        // ── Video ──────────────────────────────────────────────────────
        if (isReady && ctrl != null)
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width:  ctrl.value.size.width,
              height: ctrl.value.size.height,
              child: VideoPlayer(ctrl),
            ),
          ),

        // ── Loading spinner (only while genuinely initialising) ────────
        if (isLoading && !isReady && !hasError)
          const Center(
            child: CircularProgressIndicator(
              color: Colors.white30, strokeWidth: 2),
          ),

        // ── Error state ────────────────────────────────────────────────
        if (hasError)
          Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.play_circle_outline_rounded,
                  color: Colors.white30, size: 52),
              const SizedBox(height: 8),
              const Text(
                'Unable to play this video',
                style: TextStyle(color: Colors.white30, fontSize: 13),
              ),
            ]),
          ),

        // ── Title overlay ──────────────────────────────────────────────
        Positioned(
          left: 16, right: 80, bottom: 110,
          child: Text(
            video.title ?? '',
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
      ]),
    );
  }

  // ── Community / My Trainer pills ───────────────────────────────────────────
  Widget _buildTabPills(BuildContext context) {
    return Positioned(
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
            color:      active ? Colors.black : Colors.white70,
            fontSize:   13.sp,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
