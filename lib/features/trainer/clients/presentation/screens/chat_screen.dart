import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/anam/domain/services/anam_service.dart';
import 'package:pler_to_pler_app/features/anam/presentation/arguments/anam_call_args.dart';
import 'package:pler_to_pler_app/features/anam/presentation/screens/anam_call_screen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late final ChatScreenArgs _args;

  // Dummy Chat List
  final List<Map<String, dynamic>> _dummyMessages = [
    {"text": "Hey! How are you?", "time": "10:20 AM", "isMe": false},
    {"text": "I'm good, what about you?", "time": "10:22 AM", "isMe": true},
    {
      "text": "Doing well, thanks for asking!",
      "time": "10:25 AM",
      "isMe": false,
    },
    {"text": "Are you free this evening?", "time": "10:28 AM", "isMe": false},
    {"text": "Yes, I am. Any plans?", "time": "10:30 AM", "isMe": true},
    {"text": "Let's catch up at the café.", "time": "10:32 AM", "isMe": false},
    {"text": "Perfect, see you then!", "time": "10:35 AM", "isMe": true},
  ];

  bool get _canStartAiCall =>
      !LoginController.to.isTrainer() &&
      _args.isAnamEnabled &&
      (_args.trainerId?.isNotEmpty ?? false);

  @override
  void initState() {
    super.initState();
    _args = Get.arguments is ChatScreenArgs
        ? Get.arguments as ChatScreenArgs
        : const ChatScreenArgs(displayName: 'John Adams');
    _prefetchAnamUsage();
  }

  void _prefetchAnamUsage() {
    if (!_canStartAiCall || !Get.isRegistered<AnamService>()) return;
    prefetchAnamUsage(Get.find<AnamService>());
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        centerTitle: false,
        titleWidget: Column(
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
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                itemCount: _dummyMessages.length,
                itemBuilder: (context, index) {
                  final message = _dummyMessages[index];
                  return ChatBubbleMessage(
                    text: message["text"],
                    time: message["time"],
                    isMe: message["isMe"],
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: _buildMessageSender(),
            ),
          ],
        ),
      ),
    );
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

  Widget _buildMessageSender() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: CustomTextField(
              validator: (_) => null,
              controller: _messageController,
              hintText: 'Type message...',
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _sendMessage,
            child: Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Assets.icons.send.svg(),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _dummyMessages.add({
        "text": _messageController.text.trim(),
        "time": "Now",
        "isMe": true,
      });
    });
    _messageController.clear();
  }
}
