import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/features/user/contents/data/models.dart';
import 'package:pler_to_pler_app/features/user/contents/presentations/video_details_screens.dart';
import 'package:pler_to_pler_app/features/home/widgets/feed_app_bar.dart';




// ═══════════════════════════════════════════════════════════════════════════════
// SCREEN 1 — FEED
// ═══════════════════════════════════════════════════════════════════════════════

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['Relevant', 'Shorts', 'Updates', 'Tips &'];

  final List<VideoPost> _posts = const [
    VideoPost(
      title: 'Refreshing Workouts You Can Do Anywhere!',
      category: 'Light workout',
      views: '1.6k views',
      imageUrl: 'https://images.unsplash.com/photo-1549576490-b0b4831ef60a?w=600',
      isNew: true,
    ),
    VideoPost(
      title: 'Energize Your Day with a 15-Minute Workout!',
      category: 'Light workout',
      views: '1.6k views',
      imageUrl: 'https://images.unsplash.com/photo-1581009137042-c552e485697a?w=600',
      isNew: true,
    ),
    VideoPost(
      title: 'Simple Workouts to Lift Your Spirits!',
      category: 'Light workout',
      views: '1.6k views',
      imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=600',
      isNew: false,
    ),
    VideoPost(
      title: 'Refreshing Workouts You Can Do Anywhere!',
      category: 'Light workout',
      views: '1.6k views',
      imageUrl: 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=600',
      isNew: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 14.h),
            _TabBar(
              tabs: _tabs,
              selected: _selectedTab,
              onChanged: (i) => setState(() => _selectedTab = i),
            ),
            SizedBox(height: 14.h),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: _posts.length,
                itemBuilder: (_, i) => _VideoPostCard(
                  post: _posts[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VideoDetailScreen(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// ─── Tab Bar ──────────────────────────────────────────────────────────────────
class _TabBar extends StatelessWidget {
  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onChanged;

  const _TabBar({required this.tabs, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: tabs.length,
        itemBuilder: (_, i) {
          final isSelected = i == selected;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: isSelected
                    ? []
                    : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
              ),
              child: Text(
                tabs[i],
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black54,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Video Post Card ──────────────────────────────────────────────────────────
class _VideoPostCard extends StatelessWidget {
  final VideoPost post;
  final VoidCallback onTap;

  const _VideoPostCard({required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                  child: Image.network(
                    post.imageUrl,
                    width: double.infinity,
                    height: 190.h,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 190.h,
                      color: const Color(0xFFEEEEEE),
                      child: Icon(Icons.play_circle_outline, size: 48.sp, color: Colors.grey),
                    ),
                  ),
                ),
                if (post.isNew)
                  Positioned(
                    top: 10.h,
                    left: 10.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF7A00),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'New',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Meta
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${post.category} · ${post.views}',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}