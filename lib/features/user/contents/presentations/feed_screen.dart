import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/features/user/contents/presentations/video_details_screens.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// SCREEN 1 — VIDEO FEED (Community / My Trainer)
// Dark full-screen vertical video feed. Each page shows one exercise video.
// TODO(backend): replace _videos with the exercise video library served from
// object storage once the video files are uploaded (GET /content/videos).
// ═══════════════════════════════════════════════════════════════════════════════

class ExerciseVideo {
  final String title;
  final String? videoUrl; // network URL once backend serves the library
  final String? thumbnailUrl;

  const ExerciseVideo({required this.title, this.videoUrl, this.thumbnailUrl});
}

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  int _selectedTab = 0; // 0 = Community, 1 = My Trainer
  final PageController _pageController = PageController();

  // Placeholder library — replaced by the real video folder when uploaded.
  final List<ExerciseVideo> _communityVideos = const [
    ExerciseVideo(title: '180 Jump Turns'),
    ExerciseVideo(title: 'Air Squats'),
    ExerciseVideo(title: 'Alternating Lunges'),
    ExerciseVideo(title: 'Arm Circles'),
  ];

  final List<ExerciseVideo> _trainerVideos = const [
    ExerciseVideo(title: 'Bench Press Form'),
    ExerciseVideo(title: 'Deadlift Setup'),
  ];

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
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _videos.length,
            itemBuilder: (_, i) => _VideoPage(video: _videos[i]),
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
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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

class _VideoPage extends StatelessWidget {
  final ExerciseVideo video;

  const _VideoPage({required this.video});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Video area (white letterboxed player) ──
        Center(
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Container(
              color: Colors.white,
              child: video.thumbnailUrl != null
                  ? Image.network(video.thumbnailUrl!, fit: BoxFit.contain)
                  : Center(
                      child: Icon(Icons.fitness_center,
                          size: 64.sp, color: Colors.grey.shade300),
                    ),
              // TODO(backend): swap for a looping video player once the
              // exercise video files are uploaded to object storage.
            ),
          ),
        ),

        // ── Title bottom-left ──
        Positioned(
          left: 24.w,
          bottom: 130.h,
          child: Text(
            video.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
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
