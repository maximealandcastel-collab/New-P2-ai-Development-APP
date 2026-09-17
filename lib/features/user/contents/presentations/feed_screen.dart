import 'dart:developer';

import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/services/video_playback_manager.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:pler_to_pler_app/features/user/contents/presentations/video_details_screens.dart';
import 'package:pler_to_pler_app/services/api_urls.dart';
import 'package:pler_to_pler_app/services/network/api_client.dart';
import 'package:video_player/video_player.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// SCREEN 1 — VIDEO FEED (Community / My Trainer)
// Dark full-screen vertical video feed. Each page shows one exercise video
// streamed from the backend video library (GET /content/feed).
// ═══════════════════════════════════════════════════════════════════════════════

class ExerciseVideo {
  final String title;
  final String? videoUrl; // absolute network URL served by the backend
  final String? thumbnailUrl;

  const ExerciseVideo({required this.title, this.videoUrl, this.thumbnailUrl});
}

/// Server origin without the /api/v1 suffix — backend videoUrl values
/// already start with /api/v1/... so they must not be double-prefixed.
String _serverOrigin() =>
    ApiUrls.baseUrl.replaceFirst(RegExp(r'/api/v1/?$'), '');

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  int _selectedTab = 0; // 0 = Community, 1 = My Trainer
  final PageController _pageController = PageController();

  bool _loading = true;
  List<ExerciseVideo> _communityVideos = const [];
  List<ExerciseVideo> _trainerVideos = const [];

  VideoPlaybackManager get _vpm => Get.find<VideoPlaybackManager>();
  Worker? _navWorker;

  /// Resolved by identity, never by an integer literal.
  ///
  /// This was `static const _contentsTabIndex = 2` with a comment claiming
  /// "Contents tab is index 2 in the user nav bar". It is 3 — index 2 is Gyms.
  /// That is the same off-by-one that caused the original audio bleed (§22):
  /// every suspend/resume gate fired on exactly the wrong tab, so audio
  /// started on Gyms and stopped on Contents. Four other copies of this
  /// constant were replaced with an id lookup; this one was missed because the
  /// screen is unreachable, so nothing exercised it.
  int get _contentsTabIndex =>
      BottomNavBarController.to.contentsTabIndex;

  @override
  void initState() {
    super.initState();

    // Enter immediately — we are visible right now.
    _vpm.enterVideoModule();

    // Watch the nav index, because dispose() is not a reliable teardown hook
    // for anything living under the bottom nav — IndexedStack keeps every tab
    // mounted (handoff rule 4).
    //
    // This watched `NavBarController` from features/nav_bar/, which is a stub:
    // an RxInt and a setter that **nothing in the app ever calls**. So the
    // worker could never fire and the gate below was dead even on its own
    // terms. The live controller is BottomNavBarController.
    _navWorker = ever(BottomNavBarController.to.selectedIndexRx, (int index) {
      if (index == _contentsTabIndex) {
        _vpm.enterVideoModule();
      } else {
        _vpm.exitVideoModule();
      }
    });

    _loadFeed();
  }

  Future<void> _loadFeed() async {
    try {
      final response = await ApiClient.getData('/content/feed');
      if (response.statusCode == 200 && response.body is Map) {
        final data = (response.body as Map)['data'];
        if (data is Map) {
          List<ExerciseVideo> parse(dynamic list) {
            if (list is! List) return const [];
            final origin = _serverOrigin();
            return list.whereType<Map>().map((v) {
              final rawUrl = v['videoUrl']?.toString();
              final rawThumb = v['thumbnailUrl']?.toString();
              String? absolute(String? u) {
                if (u == null || u.isEmpty) return null;
                return u.startsWith('http') ? u : '$origin$u';
              }

              return ExerciseVideo(
                title: v['title']?.toString() ?? 'Workout',
                videoUrl: absolute(rawUrl),
                thumbnailUrl: absolute(rawThumb),
              );
            }).toList();
          }

          setState(() {
            _communityVideos = parse(data['community']);
            _trainerVideos = parse(data['trainer']);
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

  List<ExerciseVideo> get _videos =>
      _selectedTab == 0 ? _communityVideos : _trainerVideos;

  void _switchTab(int tab) {
    if (tab == _selectedTab) return;
    setState(() => _selectedTab = tab);
    // Reset paging so the controller never points past the new list's length.
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  @override
  void dispose() {
    _navWorker?.dispose(); // cancel the ever() worker
    _vpm.exitVideoModule(); // final hard-stop if widget is truly destroyed
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Full-screen vertical video pager ──
          if (_loading)
            const Center(
                child: CircularProgressIndicator(color: Colors.white))
          else if (_videos.isEmpty)
            Center(
              child: Text(
                _selectedTab == 1
                    ? 'Your trainer hasn\'t posted videos yet'
                    : 'No videos yet',
                style: TextStyle(color: Colors.white70, fontSize: 16.sp),
              ),
            )
          else
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: _videos.length,
              itemBuilder: (_, i) =>
                  _VideoPage(key: ValueKey('$_selectedTab-$i'), video: _videos[i]),
            ),

          // ── Top tabs: Community | My Trainer + search ──
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Row(
                children: [
                  const Spacer(),
                  _TopTab(
                    label: 'Community',
                    selected: _selectedTab == 0,
                    onTap: () => _switchTab(0),
                  ),
                  SizedBox(width: 22.w),
                  _TopTab(
                    label: 'My Trainer',
                    selected: _selectedTab == 1,
                    onTap: () => _switchTab(1),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      // TODO(backend): search across the video library
                    },
                    child: Icon(Icons.search,
                        color: Colors.white, size: 26.sp),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TopTab(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white70,
              fontSize: 17.sp,
              fontWeight: selected ? AppFontWeight.section : AppFontWeight.emphasis,
            ),
          ),
          SizedBox(height: 5.h),
          Container(
            height: 3,
            width: 34.w,
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoPage extends StatefulWidget {
  final ExerciseVideo video;

  const _VideoPage({super.key, required this.video});

  @override
  State<_VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<_VideoPage> {
  VideoPlayerController? _controller;
  bool _ready = false;

  VideoPlaybackManager get _vpm => Get.find<VideoPlaybackManager>();

  @override
  void initState() {
    super.initState();
    final url = widget.video.videoUrl;
    if (url != null) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(url))
        ..setLooping(true)
        ..initialize().then((_) {
          if (mounted) {
            setState(() => _ready = true);
            // Route through the manager — respects module-active gate
            _vpm.play(_controller!);
          }
        }).catchError((e) {
          log('video init error: $e');
        });
    }
  }

  @override
  void dispose() {
    // Hard-stop this controller before releasing it so the OS audio session
    // closes cleanly — prevents bleed onto the next screen.
    //
    // unregisterPlayer is the part that was missing. Without it the manager
    // keeps a reference to every controller this screen has ever built, long
    // after they are disposed — so the tracking set grows without bound and
    // every later stopAll() iterates dead controllers, each throwing into
    // _hardStop's catch. Pause alone does not drop the reference.
    final controller = _controller;
    if (controller != null) {
      _vpm.pause(controller);
      _vpm.unregisterPlayer(controller);
    }
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    final c = _controller;
    if (c == null || !_ready) return;
    if (c.value.isPlaying) {
      _vpm.pause(c);
    } else {
      _vpm.play(c);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Video area (white letterboxed player) ──
        Center(
          child: GestureDetector(
            onTap: _togglePlay,
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Container(
                color: Colors.white,
                child: _ready && _controller != null
                    ? FittedBox(
                        fit: BoxFit.contain,
                        clipBehavior: Clip.hardEdge,
                        child: SizedBox(
                          width: _controller!.value.size.width,
                          height: _controller!.value.size.height,
                          child: VideoPlayer(_controller!),
                        ),
                      )
                    : widget.video.thumbnailUrl != null
                        ? CachedNetworkImage(
                            imageUrl: widget.video.thumbnailUrl!,
                            fit: BoxFit.contain,
                            fadeInDuration: const Duration(milliseconds: 280),
                            placeholder: (_, __) => const ColoredBox(color: Color(0xFF1A1A1A)),
                            errorWidget: (_, __, ___) => const ColoredBox(color: Color(0xFF1A1A1A)),
                          )
                        : Center(
                            child: Icon(Icons.fitness_center,
                                size: 64.sp, color: Colors.grey.shade300),
                          ),
              ),
            ),
          ),
        ),

        // ── Title bottom-left ──
        Positioned(
          left: 24.w,
          bottom: 130.h,
          child: Text(
            widget.video.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: AppFontWeight.label,
            ),
          ),
        ),

        // ── Info button bottom-right ──
        Positioned(
          right: 20.w,
          bottom: 150.h,
          child: Column(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VideoDetailScreen()),
                ),
                child: Container(
                  width: 46.w,
                  height: 46.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.info_outline,
                      color: Colors.black, size: 24.sp),
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Info',
                style: TextStyle(color: Colors.white, fontSize: 12.sp),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
