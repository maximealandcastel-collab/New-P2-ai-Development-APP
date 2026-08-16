import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/anam/domain/services/anam_service.dart';
import 'package:pler_to_pler_app/features/anam/presentation/arguments/anam_call_args.dart';
import 'package:pler_to_pler_app/features/anam/presentation/screens/anam_call_screen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';
import 'package:pler_to_pler_app/services/stream_chat_service.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

/// Args passed via [Get.to] or [Get.toNamed] when opening the chat screen.
class ChatScreenArgs {
  const ChatScreenArgs({
    required this.displayName,
    this.subtitle = 'subscriber',
    this.isAnamEnabled = false,
    this.trainerId,
    this.channelId,
    this.channelType = 'messaging',
    this.otherUserId,
    this.otherUserImage,
  });

  final String displayName;
  final String subtitle;
  final bool isAnamEnabled;
  final String? trainerId;
  final String? channelId;
  final String channelType;
  final String? otherUserId;
  final String? otherUserImage;
}

// ─────────────────────────────────────────────────────────────────────────────

// Design constants matching the reference screenshot
const _kBgColor        = Color(0xFFEEEEEE);   // light gray background
const _kReceivedBg     = Color(0xFF2C2C2E);   // dark charcoal bubble
const _kReceivedText   = Colors.white;
const _kSentBg         = Colors.white;
const _kSentText       = Color(0xFF1C1C1E);
const _kTimestampColor = Color(0xFF8E8E93);
const _kInputBg        = Colors.white;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final ChatScreenArgs _args;
  Channel? _channel;
  StreamSubscription<List<Message>>? _msgSub;

  bool _channelReady = false;
  bool _sending      = false;
  List<Message> _messages = [];

  bool get _canStartAiCall =>
      !LoginController.to.isTrainer() &&
      _args.isAnamEnabled &&
      (_args.trainerId?.isNotEmpty ?? false);

  @override
  void initState() {
    super.initState();
    _args = Get.arguments is ChatScreenArgs
        ? Get.arguments as ChatScreenArgs
        : const ChatScreenArgs(displayName: 'Chat');
    _prefetchAnamUsage();
    _initChannel();
  }

  void _prefetchAnamUsage() {
    if (!_canStartAiCall || !Get.isRegistered<AnamService>()) return;
    prefetchAnamUsage(Get.find<AnamService>());
  }

  Future<void> _initChannel() async {
    final svc = StreamChatService.instance;
    if (!svc.isConnected) await svc.initFromBackend();
    if (!svc.isConnected) {
      if (mounted) setState(() => _channelReady = false);
      return;
    }

    String? cid = _args.channelId;
    if ((cid == null || cid.isEmpty) && _args.otherUserId != null) {
      cid = await svc.ensureChannel(subscriberId: _args.otherUserId!);
    }
    if (cid == null || cid.isEmpty) {
      if (mounted) setState(() => _channelReady = false);
      return;
    }

    final ch = svc.client.channel(_args.channelType, id: cid);
    await ch.watch();
    _channel  = ch;
    _messages = List<Message>.from(ch.state?.messages ?? []);
    _msgSub   = ch.state?.messagesStream.listen((msgs) {
      if (mounted) setState(() => _messages = msgs);
      _scrollToBottom();
    });
    if (mounted) setState(() => _channelReady = true);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _channel == null || _sending) return;
    setState(() => _sending = true);
    _messageController.clear();
    try {
      await _channel!.sendMessage(Message(text: text));
    } catch (_) {
      ToastMessageHelper.show('Failed to send message');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    _channel?.stopWatching();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBgColor,
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(child: _buildBody()),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Padding(
          padding: EdgeInsets.all(10.r),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFEEEEEE),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chevron_left_rounded,
              size: 22.r,
              color: const Color(0xFF1C1C1E),
            ),
          ),
        ),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          if (_args.otherUserImage != null)
            CircleAvatar(
              radius: 18.r,
              backgroundImage: NetworkImage(_args.otherUserImage!),
            )
          else
            CircleAvatar(
              radius: 18.r,
              backgroundColor: const Color(0xFFE0E0E0),
              child: Icon(Icons.person_rounded,
                  size: 20.r, color: const Color(0xFF8E8E93)),
            ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _args.displayName,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C1C1E),
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                _channelReady ? 'Active now' : _args.subtitle,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: _channelReady
                      ? const Color(0xFF34C759)  // green = online
                      : _kTimestampColor,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        if (_canStartAiCall)
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: GestureDetector(
              onTap: _onAiCallTap,
              child: Container(
                width: 38.w,
                height: 38.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFEEEEEE),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.videocam_rounded,
                    size: 20.r, color: const Color(0xFF1C1C1E)),
              ),
            ),
          )
        else
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: Container(
              width: 38.w,
              height: 38.w,
              decoration: const BoxDecoration(
                color: Color(0xFFEEEEEE),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.videocam_rounded,
                  size: 20.r, color: const Color(0xFF1C1C1E)),
            ),
          ),
      ],
    );
  }

  // ─── Body ─────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    if (!_channelReady) {
      return Center(
        child: _channel == null && !_channelReady
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2.5,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Connecting…',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: _kTimestampColor,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded,
                      size: 56.r, color: _kTimestampColor),
                  SizedBox(height: 16.h),
                  Text(
                    'Chat unavailable',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: _kSentText,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Please check your connection and try again.',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: _kTimestampColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('👋', style: TextStyle(fontSize: 48.sp)),
            SizedBox(height: 12.h),
            Text(
              'Say hello to ${_args.displayName}!',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: _kSentText,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Messages and workout plans\nwill appear here.',
              style: TextStyle(fontSize: 13.sp, color: _kTimestampColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final myId = StreamChatService.instance.client.state.currentUser?.id ?? '';

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg  = _messages[index];
        final isMe = msg.user?.id == myId;
        final time = _formatTime(msg.createdAt.toLocal());

        if (msg.attachments.isNotEmpty) {
          return _PlanCard(message: msg, isMe: isMe, time: time);
        }
        return _buildMessageBubble(
          text: msg.text ?? '',
          time: time,
          isMe: isMe,
        );
      },
    );
  }

  /// Renders a single chat bubble matching the design screenshot:
  /// • received  — dark charcoal pill, white text, timestamp below-left
  /// • sent      — white pill, dark text, timestamp below-right
  Widget _buildMessageBubble({
    required String text,
    required String time,
    required bool isMe,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // ── Bubble ──────────────────────────────────────────────────
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(Get.context!).size.width * 0.72,
            ),
            decoration: BoxDecoration(
              color: isMe ? _kSentBg : _kReceivedBg,
              borderRadius: BorderRadius.only(
                topLeft:     Radius.circular(20.r),
                topRight:    Radius.circular(20.r),
                bottomLeft:  Radius.circular(isMe ? 20.r : 4.r),
                bottomRight: Radius.circular(isMe ? 4.r  : 20.r),
              ),
              boxShadow: isMe
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 10.h,
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: isMe ? _kSentText : _kReceivedText,
                height: 1.35,
              ),
            ),
          ),
          // ── Timestamp ───────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.only(
              top: 4.h,
              left: isMe ? 0 : 4.w,
              right: isMe ? 4.w : 0,
            ),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 11.sp,
                color: _kTimestampColor,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Input bar ────────────────────────────────────────────────────────────

  Widget _buildInputBar() {
    return Container(
      color: _kInputBg,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Text field
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: _kBgColor,
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                  child: TextField(
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: _kSentText,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Message…',
                      hintStyle: TextStyle(
                        fontSize: 15.sp,
                        color: _kTimestampColor,
                      ),
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              // Send button
              GestureDetector(
                onTap: _sending ? null : _sendMessage,
                child: Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    color: _kReceivedBg,
                    shape: BoxShape.circle,
                  ),
                  child: _sending
                      ? Padding(
                          padding: EdgeInsets.all(11.r),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          Icons.arrow_upward_rounded,
                          color: Colors.white,
                          size: 20.r,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour   = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _onAiCallTap() async {
    final trainerId = _args.trainerId;
    if (trainerId == null || trainerId.isEmpty) {
      ToastMessageHelper.show('Trainer not available for video call');
      return;
    }
    await openAnamVideoCall(
      trainerId: trainerId,
      trainerName: _args.displayName,
    );
    _prefetchAnamUsage();
  }
}

// ─── Workout / Meal plan attachment card ─────────────────────────────────────

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.message,
    required this.isMe,
    required this.time,
  });

  final Message message;
  final bool    isMe;
  final String  time;

  @override
  Widget build(BuildContext context) {
    final attachment = message.attachments.first;
    final isWorkout  = attachment.type == 'workout_plan';
    final title      = attachment.title ?? message.text ?? '';
    final body       = attachment.text  ?? '';

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            decoration: BoxDecoration(
              color: isWorkout
                  ? AppColors.primary.withOpacity(0.08)
                  : Colors.green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isWorkout
                    ? AppColors.primary.withOpacity(0.25)
                    : Colors.green.withOpacity(0.25),
                width: 1,
              ),
            ),
            padding: EdgeInsets.all(14.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(isWorkout ? '💪' : '🥗',
                        style: TextStyle(fontSize: 16.sp)),
                    SizedBox(width: 6.w),
                    Text(
                      isWorkout ? 'Workout Plan' : 'Meal Plan',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: isWorkout
                            ? AppColors.primary
                            : Colors.green[700],
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C1C1E),
                  ),
                ),
                if (body.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    body,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF3C3C43),
                      height: 1.4,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 8.h),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    time,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFF8E8E93),
                    ),
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
