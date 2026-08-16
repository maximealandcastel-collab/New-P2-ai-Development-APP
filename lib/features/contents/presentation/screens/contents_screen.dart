import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';
import 'package:pler_to_pler_app/features/contents/reels/core/reel_player_manager.dart';
import 'package:pler_to_pler_app/services/api_urls.dart';

class ContentsScreen extends StatefulWidget {
  const ContentsScreen({super.key});

  @override
  State<ContentsScreen> createState() => _ContentsScreenState();
}

class _ContentsScreenState extends State<ContentsScreen>
    with WidgetsBindingObserver {
  late final ReelPlayerManager _mgr = ReelPlayerManager(
    onUpdated: _onMgrUpdate,
  );

  final PageController _pageCtrl = PageController();
  int _tab = 0;
  int _currentPage = 0;

  bool _loading = true;
  String? _error;
  List<ContentModel> _community = const [];
  List<ContentModel> _trainerVideos = const [];

  List<ContentModel> get _videos => _tab == 0 ? _community : _trainerVideos;

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
    _mgr.releaseAll();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _mgr.pauseActive();
        break;
      case AppLifecycleState.resumed:
        _mgr.playActive();
        break;
    }
  }

  void _onMgrUpdate() {
    if (mounted) setState(() {});
  }

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

  Future<void> _loadFeed() async {
    setState(() { _loading = true; _error = null; });
    final t0 = DateTime.now();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';
      final uri   = Uri.parse('${ApiUrls.baseUrl}/content/feed');

      final res = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      }).timeout(const Duration(seconds: 15));

      final ms = DateTime.now().difference(t0).inMilliseconds;
      log('[ContentsScreen] fetch ${ms}ms status=${res.statusCode}');

      if (res.statusCode == 200) {
        final body     = json.decode(res.body) as Map<String, dynamic>;
        final feedData = body['data'] as Map<String, dynamic>?;
        if (feedData != null) {
          final community = _parseList(feedData['community']);
          final trainer   = _parseList(feedData['trainer']);
          log('[ContentsScreen] community=${community.length} trainer=${trainer.length}');

          if (!mounted) return;
          setState(() {
            _community     = community;
            _trainerVideos = trainer;
            _loading       = false;
            _currentPage   = 0;
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
      setState(() { _loading = false; _error = 'Could not load videos.\nTap to retry.'; });
    }
  }

  List<ContentModel> _parseList(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(ContentModel.fromJson)
        .where((c) => c.hasMuxHls || (c.videoUrl?.isNotEmpty ?? false))
        .toList();
  }

  void _switchTab(int tab) {
    if (tab == _tab) return;
    _mgr.pauseActive();
    setState(() { _tab = tab; _currentPage = 0; });
    if (_pageCtrl.hasClients) _pageCtrl.jumpToPage(0);
    if (_videos.isNotEmpty) {
      unawaited(_mgr.sync(index: 0, contents: _videos));
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('contents-screen'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction == 0) {
          _mgr.pauseActive();
        } else if (info.visibleFraction == 1) {
          _mgr.playActive();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(children: [
          _buildBody(context),
          _buildTabPills(context),
        ]),
      ),
    );
  }

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
            Text(_error!, textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 14.sp, height: 1.6)),
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

  Widget _buildVideoPage(int index) {
    final slot  = _mgr.slotFor(index);
    final ctrl  = _mgr.controllerFor(index);

    final isReady   = slot?.isReady ?? false;
    final isLoading = slot?.isLoading ?? (slot == null);
    final hasError  = slot != null && slot.error.isNotEmpty;

    return GestureDetector(
      onTap: () {
        if (ctrl == null) return;
        ctrl.value.isPlaying ? ctrl.pause() : ctrl.play();
        setState(() {});
      },
      child: Stack(fit: StackFit.expand, children: [
        const ColoredBox(color: Colors.black),

        if (isReady && ctrl != null)
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width:  ctrl.value.size.width,
              height: ctrl.value.size.height,
              child: VideoPlayer(ctrl),
            ),
          ),

        if (isLoading && !isReady && !hasError)
          const Center(child: CircularProgressIndicator(color: Colors.white30, strokeWidth: 2)),

        if (hasError)
          const Center(
            child: Icon(Icons.play_circle_outline_rounded, color: Colors.white30, size: 52),
          ),
      ]),
    );
  }

  Widget _buildTabPills(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 0, right: 0,
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
        child: Text(label, style: TextStyle(
          color:      active ? Colors.black : Colors.white70,
          fontSize:   13.sp,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
        )),
      ),
    );
  }
}
