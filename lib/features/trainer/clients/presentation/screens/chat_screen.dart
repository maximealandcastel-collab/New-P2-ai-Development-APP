import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pler_to_pler_app/services/socket_services.dart';
import 'package:pler_to_pler_app/services/trainer_messaging_service.dart';

class ChatScreenArgs {
  const ChatScreenArgs({
    required this.displayName,
    this.subtitle = 'trainer',
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

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _messaging = TrainerMessagingService.instance;

  TrainerConversation? _conversation;
  late ChatScreenArgs _args;
  bool _loading = true;
  bool _sending = false;
  bool _otherPersonTyping = false;
  String? _error;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _args = Get.arguments is ChatScreenArgs
        ? Get.arguments as ChatScreenArgs
        : const ChatScreenArgs(displayName: 'Your trainer');
    _loadConversation();
    _connectRealtime();
  }

  Future<void> _connectRealtime() async {
    await SocketServices.init();
    SocketServices().on('trainer-message', _handleRealtimeMessage);
    SocketServices().on('trainer-typing', _handleRealtimeTyping);
  }

  void _handleRealtimeTyping(dynamic payload) {
    if (!mounted || payload is! Map) return;
    if (payload['conversationId']?.toString() != _conversation?.id) return;
    if (payload['senderUserId']?.toString() ==
        _conversation?.currentUserId) {
      return;
    }
    setState(() => _otherPersonTyping = payload['isTyping'] == true);
  }

  void _onComposerChanged(String text) {
    _typingTimer?.cancel();
    _sendTyping(text.trim().isNotEmpty);
    if (text.trim().isNotEmpty) {
      _typingTimer = Timer(
        const Duration(milliseconds: 1200),
        () => _sendTyping(false),
      );
    }
  }

  Future<void> _sendTyping(bool isTyping) async {
    if (_conversation == null) return;
    try {
      await _messaging.setTyping(
        isTyping: isTyping,
        customerUserId: _args.otherUserId,
      );
    } catch (_) {
      // Typing status is ephemeral; message delivery remains available.
    }
  }

  void _handleRealtimeMessage(dynamic payload) {
    if (!mounted || payload is! Map) return;
    final activeConversationId = _conversation?.id;
    final incomingConversationId = payload['conversationId']?.toString();
    if (activeConversationId == null ||
        incomingConversationId != activeConversationId) {
      return;
    }
    final rawMessage = payload['message'];
    if (rawMessage is! Map) return;
    final incoming = TrainerChatMessage.fromJson(
      Map<String, dynamic>.from(rawMessage),
    );
    if (_conversation!.messages.any((message) => message.id == incoming.id)) {
      return;
    }
    setState(() => _conversation!.messages.add(incoming));
    _scrollToBottom();
  }

  Future<void> _loadConversation() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final conversation = await _messaging.load(
        customerUserId: _args.otherUserId,
      );
      if (!mounted) return;
      setState(() {
        _conversation = conversation;
        _loading = false;
      });
      _scrollToBottom();
    } on TrainerMessagingException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Messages are unavailable right now. Please try again.';
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _sending) return;
    FocusScope.of(context).unfocus();
    setState(() => _sending = true);
    _typingTimer?.cancel();
    _sendTyping(false);
    try {
      final sent = await _messaging.send(
        message: text,
        customerUserId: _args.otherUserId,
      );
      if (!mounted) return;
      _messageController.clear();
      if (_conversation != null &&
          !_conversation!.messages.any((message) => message.id == sent.id)) {
        setState(() => _conversation!.messages.add(sent));
      }
      _scrollToBottom();
    } on TrainerMessagingException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your message could not be sent. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    SocketServices().off('trainer-message', _handleRealtimeMessage);
    SocketServices().off('trainer-typing', _handleRealtimeTyping);
    _typingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trainer = _conversation?.trainer;
    final customer = _conversation?.customer;
    final isTrainerView = _args.subtitle.toLowerCase() == 'client';
    final person = isTrainerView ? customer : trainer;
    final displayName = person?.name.isNotEmpty == true
        ? person!.name
        : _args.displayName;
    final image = person?.profileImage?.isNotEmpty == true
        ? person!.profileImage
        : _args.otherUserImage;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F5),
      appBar: _buildAppBar(displayName, image),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(child: _buildConversation(displayName)),
            _buildComposer(displayName),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(String displayName, String? image) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      toolbarHeight: 76.h,
      leadingWidth: 42.w,
      leading: IconButton(
        onPressed: Get.back,
        icon: const Icon(Icons.chevron_left_rounded, color: Colors.black),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 22.r,
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                backgroundImage:
                    image == null ? null : NetworkImage(image),
                child: image == null
                    ? Text(
                        displayName.isEmpty
                            ? '?'
                            : displayName[0].toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : null,
              ),
              Positioned(
                right: -1,
                bottom: 1,
                child: Container(
                  width: 10.r,
                  height: 10.r,
                  decoration: BoxDecoration(
                    color: SocketServices.socket?.connected == true
                        ? const Color(0xFF31B84A)
                        : Colors.grey.shade400,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  SocketServices.socket?.connected == true
                      ? 'Messaging connected'
                      : 'Trainer conversation',
                  style: TextStyle(
                    color: SocketServices.socket?.connected == true
                        ? const Color(0xFF3D9C4C)
                        : Colors.grey.shade600,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40.r,
            height: 40.r,
            margin: EdgeInsets.only(right: 8.w),
            decoration: const BoxDecoration(
              color: Color(0xFFF3F3F5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.phone_outlined, size: 20.r),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Trainer calling will be available soon.'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversation(String displayName) {
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 34.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 46.r,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 12.h),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14.sp),
              ),
              SizedBox(height: 14.h),
              TextButton(
                onPressed: _loadConversation,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    final messages = _conversation?.messages ?? const <TrainerChatMessage>[];
    if (messages.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 38.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64.r,
                height: 64.r,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.waving_hand_outlined,
                  size: 30.r,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Start your conversation',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Send $displayName a message about your goals, workouts, meals, or next check-in.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13.sp,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      onRefresh: _loadConversation,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 20.h),
        itemCount: messages.length + 1 + (_otherPersonTyping ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == 0) return _dateDivider(messages.first.createdAt);
          if (_otherPersonTyping && index == messages.length + 1) {
            return _typingIndicator();
          }
          final message = messages[index - 1];
          return _messageBubble(
            message,
            message.isMine(_conversation!.currentUserId),
          );
        },
      ),
    );
  }

  Widget _typingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.r),
            topRight: Radius.circular(18.r),
            bottomRight: Radius.circular(18.r),
            bottomLeft: Radius.circular(5.r),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            3,
            (index) => Container(
              width: 6.r,
              height: 6.r,
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade500,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dateDivider(DateTime date) {
    final now = DateTime.now();
    final local = date.toLocal();
    final isToday = now.year == local.year &&
        now.month == local.month &&
        now.day == local.day;
    return Center(
      child: Container(
        margin: EdgeInsets.only(bottom: 22.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: const Color(0xFFE5E5E8),
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Text(
          isToday ? 'Today' : DateFormat('MMM d').format(local),
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp),
        ),
      ),
    );
  }

  Widget _messageBubble(TrainerChatMessage message, bool isMine) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: 292.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
              decoration: BoxDecoration(
                color: isMine ? Theme.of(context).colorScheme.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.r),
                  topRight: Radius.circular(18.r),
                  bottomLeft: Radius.circular(isMine ? 18.r : 5.r),
                  bottomRight: Radius.circular(isMine ? 5.r : 18.r),
                ),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isMine ? Colors.white : Colors.black,
                  fontSize: 15.sp,
                  height: 1.35,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('h:mm a').format(message.createdAt.toLocal()),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 10.sp),
                ),
                if (isMine) ...[
                  SizedBox(width: 4.w),
                  Icon(
                    message.readAt == null
                        ? Icons.check_rounded
                        : Icons.done_all_rounded,
                    color: message.readAt == null
                        ? Colors.grey.shade500
                        : Theme.of(context).colorScheme.primary,
                    size: 13.r,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComposer(String displayName) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 9.h, 12.w, 11.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8E8EA))),
      ),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F3F5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Plan and media sharing will be available soon.'),
                ),
              ),
              icon: Icon(Icons.add_rounded, color: Colors.grey.shade700),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: !_loading && _error == null,
              textCapitalization: TextCapitalization.sentences,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Message ${_firstName(displayName)}...',
                hintStyle: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade500,
                ),
                filled: true,
                fillColor: const Color(0xFFF3F3F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 15.w,
                  vertical: 11.h,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
              onChanged: _onComposerChanged,
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 42.r,
              height: 42.r,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: _sending
                  ? SizedBox(
                      width: 18.r,
                      height: 18.r,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20.r,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _firstName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'trainer';
    return trimmed.split(RegExp(r'\s+')).first;
  }
}
