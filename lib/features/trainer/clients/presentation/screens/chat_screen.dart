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

  /// Display name shown in the app-bar.
  final String displayName;

  /// Subtitle shown under the display name (e.g. "subscriber", "trainer").
  final String subtitle;

  /// Whether to show the AI video-call button (subscriber side only).
  final bool isAnamEnabled;

  /// Trainer mongo _id — used to open an Anam AI video call.
  final String? trainerId;

  // ── Stream Chat ───────────────────────────────────────────────────────────

  /// Stream channel ID.  If null the screen shows a loading / setup state.
  final String? channelId;

  /// Stream channel type — almost always 'messaging'.
  final String channelType;

  /// Stream user ID of the other participant (trainer or subscriber).
  final String? otherUserId;

  /// Avatar URL for the other participant (shown in the app-bar).
  final String? otherUserImage;
}

// ─────────────────────────────────────────────────────────────────────────────

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

  // ── Anam AI call ─────────────────────────────────────────────────────────
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

    // Connect to Stream if not already connected
    if (!svc.isConnected) {
      await svc.initFromBackend();
    }

    if (!svc.isConnected) {
      // Still not connected — nothing to show
      if (mounted) setState(() => _channelReady = false);
      return;
    }

    String? cid = _args.channelId;

    // If no channel ID yet, ask the backend to create one (trainer-side flow)
    if ((cid == null || cid.isEmpty) && _args.otherUserId != null) {
      cid = await svc.ensureChannel(subscriberId: _args.otherUserId!);
    }

    if (cid == null || cid.isEmpty) {
      if (mounted) setState(() => _channelReady = false);
      return;
    }

    final ch = svc.client.channel(_args.channelType, id: cid);
    await ch.watch();

    _channel = ch;
    _messages = List<Message>.from(ch.state?.messages ?? []);

    _msgSub = ch.state?.messagesStream.listen((msgs) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        centerTitle: false,
        titleWidget: Row(
          children: [
            if (_args.otherUserImage != null)
              Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: CircleAvatar(
                  radius: 18.r,
                  backgroundImage: NetworkImage(_args.otherUserImage!),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  left: 8.w,
                  textAlign: TextAlign.start,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  text: _args.displayName,
                ),
                CustomText(
                  left: 8.w,
                  fontSize: 12.sp,
                  textAlign: TextAlign.start,
                  color: AppColors.textSecondary,
                  text: _args.subtitle,
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (_canStartAiCall)
            IconButton(
              onPressed: _onAiCallTap,
              icon: Assets.icons.aiChat.svg(),
            ),
        ],
      ),
      body: KeyboardDismissOnTap(
        child: Column(
          children: [
            // ── Message list ──────────────────────────────────────────────
            Expanded(child: _buildBody()),
            // ── Input bar ─────────────────────────────────────────────────
            if (_channelReady) _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (!_channelReady) {
      return Center(
        child: _channel == null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  SizedBox(height: 16.h),
                  CustomText(
                    text: 'Setting up chat…',
                    color: AppColors.textSecondary,
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded,
                      size: 56.r, color: AppColors.textSecondary),
                  SizedBox(height: 16.h),
                  CustomText(
                    text: 'Chat unavailable',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: 8.h),
                  CustomText(
                    text: 'Please check your connection and try again.',
                    color: AppColors.textSecondary,
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
            Icon(Icons.waving_hand_rounded,
                size: 48.r, color: AppColors.primary.withOpacity(0.6)),
            SizedBox(height: 12.h),
            CustomText(
              text: 'Say hello to ${_args.displayName}!',
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
            SizedBox(height: 6.h),
            CustomText(
              text: 'Messages, workout plans, and meal plans\nwill all appear here.',
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final myId = StreamChatService.instance.client.state.currentUser?.id ?? '';

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg  = _messages[index];
        final isMe = msg.user?.id == myId;
        final time = _formatTime(msg.createdAt.toLocal());

        // Plan attachment card
        if (msg.attachments.isNotEmpty) {
          return _PlanCard(message: msg, isMe: isMe, time: time);
        }

        return ChatBubbleMessage(
          text: msg.text,
          time: time,
          isMe: isMe,
        );
      },
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          border: Border(
            top: BorderSide(color: AppColors.borderColor, width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: CustomTextField(
                validator: (_) => null,
                controller: _messageController,
                hintText: 'Type a message…',
                onFieldSubmitted: (_) => _sendMessage(),
              ),
            ),
            SizedBox(width: 10.w),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _sending ? null : _sendMessage,
              child: Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: _sending
                    ? SizedBox(
                        width: 24.w, height: 24.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : Assets.icons.send.svg(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
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

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
        constraints: BoxConstraints(maxWidth: 280.w),
        decoration: BoxDecoration(
          color: isWorkout
              ? AppColors.primary.withOpacity(0.1)
              : Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isWorkout ? AppColors.primary.withOpacity(0.3) : Colors.green.withOpacity(0.3),
          ),
        ),
        padding: EdgeInsets.all(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(isWorkout ? '💪' : '🥗',
                    style: TextStyle(fontSize: 18.sp)),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    isWorkout ? 'Workout Plan' : 'Meal Plan',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: isWorkout ? AppColors.primary : Colors.green[700],
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(title,
                style: TextStyle(
                    fontSize: 14.sp, fontWeight: FontWeight.w600)),
            if (body.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(body,
                  style: TextStyle(
                      fontSize: 12.sp, color: Colors.black87),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis),
            ],
            SizedBox(height: 6.h),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(time,
                  style: TextStyle(
                      fontSize: 10.sp, color: Colors.black45)),
            ),
          ],
        ),
      ),
    );
  }
}