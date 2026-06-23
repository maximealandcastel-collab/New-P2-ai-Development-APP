import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final TextEditingController _messageController = TextEditingController();

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
    {"text": "Let’s catch up at the café.", "time": "10:32 AM", "isMe": false},
    {"text": "Perfect, see you then!", "time": "10:35 AM", "isMe": true},
  ];

  @override
  Widget build(BuildContext context) {
    return SliverScaffold(
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
            text: 'John Adams',
          ),
          CustomText(
            left: 8.w,
            fontSize: 12.sp,
            textAlign: TextAlign.start,
            color: AppColors.textSecondary,
            text: 'Active now',
          ),
        ],
      ),
      actions: [
        if (!LoginController.to.isTrainer())
          IconButton(onPressed: () {}, icon: Assets.icons.aiChat.svg()),
      ],

      body: Column(
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
          _buildMessageSender(),
        ],

      ),
    );
  }

  Widget _buildMessageSender() {
    return SafeArea(
      top: false,
      child: Container(
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
              onTap: () {
                if (_messageController.text.isNotEmpty) {
                  setState(() {
                    _dummyMessages.add({
                      "text": _messageController.text,
                      "time": "Now",
                      "isMe": true,
                    });
                  });
                  _messageController.clear();
                }
              },
              child: Padding(
                padding:  EdgeInsets.only(bottom: 7.h),
                child: Assets.icons.send.svg(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
