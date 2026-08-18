import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/features/user/contents/data/models.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// SCREEN 2 — VIDEO DETAIL
// ═══════════════════════════════════════════════════════════════════════════════

class VideoDetailScreen extends StatefulWidget {
  const VideoDetailScreen({super.key});

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  bool _isPlaying = false;
  double _progress = 0.085; // ~34s of 6:40
  final TextEditingController _commentCtrl = TextEditingController();

  final List<Comment> _comments = const [
    Comment(
      user: 'Jive Johnny',
      avatarUrl: 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=100',
      timeAgo: '5 hours ago',
      text: 'Nice vibe!',
      likes: 219,
      dislikes: 2,
      replies: 1,
    ),
    Comment(
      user: 'Rockabilly Lou',
      avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100',
      timeAgo: '22 hrs ago',
      text: 'Super chill!!',
      likes: 847,
      dislikes: 2,
      replies: 1,
    ),
    Comment(
      user: "Swingin' Sam",
      avatarUrl: 'https://images.unsplash.com/photo-1552058544-f2b08422138a?w=100',
      timeAgo: '3 days ago',
      text: "That's awesome!",
      likes: 532,
      dislikes: 2,
      replies: 1,
    ),
  ];

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  String _formatTime(double progress, int totalSeconds) {
    final secs = (progress * totalSeconds).toInt();
    final m = secs ~/ 60;
    final s = secs % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    const totalSeconds = 400; // 6:40

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Video Player Area
            _VideoPlayer(
              progress: _progress,
              isPlaying: _isPlaying,
              elapsed: _formatTime(_progress, totalSeconds),
              total: '6:40',
              onBack: () => Navigator.maybePop(context),
              onPlayPause: () => setState(() => _isPlaying = !_isPlaying),
              onSeek: (v) => setState(() => _progress = v),
            ),

            // ── Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'Ultimate Cardio Blast: Feel the Burn!',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '2.4K views · 2 days ago',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
                    ),
                    SizedBox(height: 10.h),

                    // Trainer row
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14.r,
                          backgroundImage: const NetworkImage(
                            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Alex kanzi',
                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),

                    // Like / dislike / share row
                    Row(
                      children: [
                        _ActionChip(
                          icon: Icons.thumb_up_outlined,
                          label: '966',
                          onTap: () {},
                        ),
                        SizedBox(width: 10.w),
                        _ActionChip(
                          icon: Icons.thumb_down_outlined,
                          label: '2',
                          onTap: () {},
                        ),
                        const Spacer(),
                        _ActionChip(
                          icon: Icons.share_outlined,
                          label: 'Share',
                          onTap: () {},
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),
                    Divider(color: Colors.grey.shade200, height: 1),
                    SizedBox(height: 16.h),

                    // Comments header
                    Row(
                      children: [
                        Text(
                          'Comments',
                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          '40',
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Add comment field
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: TextField(
                        controller: _commentCtrl,
                        style: TextStyle(fontSize: 13.sp),
                        decoration: InputDecoration.collapsed(
                          hintText: 'Add a comment',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.sp),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Comment list
                    ..._comments.map((c) => _CommentTile(comment: c)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Video Player Widget ──────────────────────────────────────────────────────
class _VideoPlayer extends StatelessWidget {
  final double progress;
  final bool isPlaying;
  final String elapsed;
  final String total;
  final VoidCallback onBack;
  final VoidCallback onPlayPause;
  final ValueChanged<double> onSeek;

  const _VideoPlayer({
    required this.progress,
    required this.isPlaying,
    required this.elapsed,
    required this.total,
    required this.onBack,
    required this.onPlayPause,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Thumbnail
        Image.network(
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800',
          width: double.infinity,
          height: 230.h,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 230.h,
            color: Colors.black87,
            child: Icon(Icons.play_circle_outline, size: 60.sp, color: Colors.white30),
          ),
        ),

        // Dark overlay
        Container(
          height: 230.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.5), Colors.transparent, Colors.black.withOpacity(0.6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
        ),

        // Top bar
        Positioned(
          top: 12.h,
          left: 12.w,
          child: GestureDetector(
            onTap: onBack,
            child: Container(
              width: 32.w,
              height: 32.h,
              decoration: BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.chevron_left, color: Colors.white, size: 20.sp),
            ),
          ),
        ),

        // Bottom controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
            child: Column(
              children: [
                // Time row
                Row(
                  children: [
                    Text(elapsed, style: TextStyle(color: Colors.white, fontSize: 11.sp)),
                    const Spacer(),
                    Text(total, style: TextStyle(color: Colors.white70, fontSize: 11.sp)),
                  ],
                ),
                SizedBox(height: 4.h),

                // Seek bar + controls row
                Row(
                  children: [
                    // Play/pause
                    GestureDetector(
                      onTap: onPlayPause,
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 26.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),

                    // Seek slider
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 3.h,
                          activeTrackColor: const Color(0xFFFF7A00),
                          inactiveTrackColor: Colors.white30,
                          thumbColor: const Color(0xFFFF7A00),
                          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5.r),
                          overlayShape: SliderComponentShape.noOverlay,
                        ),
                        child: Slider(
                          value: progress,
                          onChanged: onSeek,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),

                    // Volume
                    Icon(Icons.volume_up, color: Colors.white, size: 20.sp),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Action Chip ──────────────────────────────────────────────────────────────
class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.sp, color: Colors.black87),
            SizedBox(width: 5.w),
            Text(
              label,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Comment Tile ─────────────────────────────────────────────────────────────
class _CommentTile extends StatelessWidget {
  final Comment comment;

  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 18.r,
            backgroundImage: NetworkImage(comment.avatarUrl),
            onBackgroundImageError: (_, __) {},
            backgroundColor: const Color(0xFFEEEEEE),
          ),
          SizedBox(width: 10.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + time
                Row(
                  children: [
                    Text(
                      comment.user,
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      comment.timeAgo,
                      style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade400),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),

                // Comment text
                Text(
                  comment.text,
                  style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                ),
                SizedBox(height: 8.h),

                // Reactions row
                Row(
                  children: [
                    _ReactionBtn(icon: Icons.thumb_up_outlined, count: comment.likes),
                    SizedBox(width: 12.w),
                    _ReactionBtn(icon: Icons.thumb_down_outlined, count: comment.dislikes),
                    SizedBox(width: 12.w),
                    _ReactionBtn(icon: Icons.chat_bubble_outline, count: comment.replies, label: 'Reply'),
                  ],
                ),
              ],
            ),
          ),

          Icon(Icons.more_vert, size: 18.sp, color: Colors.black38),
        ],
      ),
    );
  }
}

class _ReactionBtn extends StatelessWidget {
  final IconData icon;
  final int count;
  final String? label;

  const _ReactionBtn({required this.icon, required this.count, this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: Colors.grey.shade500),
        SizedBox(width: 4.w),
        Text(
          label != null ? '${count} $label' : '$count',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}
