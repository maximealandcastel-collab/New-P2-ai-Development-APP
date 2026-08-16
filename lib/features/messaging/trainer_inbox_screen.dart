import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';
import 'package:pler_to_pler_app/features/trainer/clients/presentation/screens/chat_screen.dart';
import 'package:pler_to_pler_app/services/stream_chat_service.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

/// Trainer's messaging inbox — shows every subscriber they have an active
/// channel with, ordered by most-recently-active.
///
/// Subscribers: tapping a row opens [ChatScreen] wired to the real Stream channel.
class TrainerInboxScreen extends StatefulWidget {
  const TrainerInboxScreen({super.key});

  @override
  State<TrainerInboxScreen> createState() => _TrainerInboxScreenState();
}

class _TrainerInboxScreenState extends State<TrainerInboxScreen> {
  final StreamChatService _svc = StreamChatService.instance;

  @override
  void initState() {
    super.initState();
    if (!_svc.isConnected) {
      _svc.initFromBackend();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_svc.isConnected) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: _appBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final myId = _svc.client.state.currentUser?.id ?? '';

    return StreamChatCore(
      client: _svc.client,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: _appBar(),
        body: ChannelListCore(
          filter: Filter.and([
            Filter.equal('type', 'messaging'),
            Filter.in_('members', [myId]),
          ]),
          sort: const [SortOption('last_message_at', direction: SortOption.DESC)],
          limit: 30,
          errorBuilder: (context, error) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_off_rounded, size: 48.r, color: AppColors.textSecondary),
                SizedBox(height: 12.h),
                CustomText(text: 'Could not load messages', color: AppColors.textSecondary),
                SizedBox(height: 8.h),
                TextButton(onPressed: () => setState(() {}), child: const Text('Retry')),
              ],
            ),
          ),
          loadingBuilder: (context) => ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            itemCount: 8,
            separatorBuilder: (_, __) => Divider(height: 1.h, color: Colors.grey.shade200),
            itemBuilder: (_, __) => _ShimmerRow(),
          ),
          emptyBuilder: (context) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chat_bubble_outline_rounded, size: 64.r, color: AppColors.textSecondary),
                SizedBox(height: 16.h),
                CustomText(
                  text: 'No conversations yet',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 8.h),
                CustomText(
                  text: 'Open a client\'s profile and tap\n"Message" to start a chat.',
                  textAlign: TextAlign.center,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          listBuilder: (context, channels) => RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => () => setState(() {})(),
            child: ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              itemCount: channels.length,
              separatorBuilder: (_, __) => Divider(
                height: 1.h,
                indent: 72.w,
                color: Colors.grey.shade200,
              ),
              itemBuilder: (context, index) =>
                  _ChannelTile(channel: channels[index], myId: myId),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _appBar() => AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: CustomText(
          text: 'Messages',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
        centerTitle: false,
      );
}

// ─── Individual channel row ───────────────────────────────────────────────────
class _ChannelTile extends StatelessWidget {
  const _ChannelTile({required this.channel, required this.myId});
  final Channel channel;
  final String myId;

  @override
  Widget build(BuildContext context) {
    final other = channel.state?.members
        .where((m) => m.user?.id != myId)
        .firstOrNull
        ?.user;

    final name        = other?.name ?? channel.extraData['name'] as String? ?? 'Subscriber';
    final avatar      = other?.image;
    final lastMsg     = channel.state?.messages.lastOrNull;
    final lastText    = lastMsg?.text ?? 'Tap to open chat';
    final unreadCount = channel.state?.unreadCount ?? 0;
    final lastTime    = lastMsg?.createdAt;

    return InkWell(
      onTap: () => _openChat(context, name, avatar),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24.r,
              backgroundColor: AppColors.primary.withOpacity(0.15),
              backgroundImage: avatar != null ? NetworkImage(avatar) : null,
              child: avatar == null
                  ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ))
                  : null,
            ),
            SizedBox(width: 12.w),
            // Name + last message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomText(
                          text: name,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (lastTime != null)
                        CustomText(
                          text: _formatTime(lastTime),
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: CustomText(
                          text: lastText,
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                          maxline: 1,
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          margin: EdgeInsets.only(left: 8.w),
                          padding: EdgeInsets.symmetric(
                              horizontal: 7.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            '$unreadCount',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openChat(BuildContext context, String name, String? avatar) {
    Get.to(
      () => const ChatScreen(),
      arguments: ChatScreenArgs(
        displayName: name,
        subtitle: 'subscriber',
        channelId: channel.id ?? '',
        channelType: channel.type,
        otherUserImage: avatar,
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[dt.weekday - 1];
    } else {
      return '${dt.day}/${dt.month}';
    }
  }
}

// ─── Shimmer placeholder row ──────────────────────────────────────────────────
class _ShimmerRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 48.w, height: 48.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14.h, width: 120.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  height: 12.h, width: 200.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}