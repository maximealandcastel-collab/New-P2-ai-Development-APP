import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/contents/presentation/arguments/video_player_args.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/content_details_controller.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/content_video_player.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class VideoPlayerScreen extends StatelessWidget {
  const VideoPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as VideoPlayerArgs;
    final controller = ContentDetailsController.to;

    return Scaffold(
      backgroundColor: AppColors.textWhite,
      appBar: CustomAppBar(
        title: args.title ?? 'Video',
        foregroundColor: Colors.black,
        backgroundColor: AppColors.textWhite,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: ContentVideoPlayer(
            controller: controller,
            showActions: true,
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }
}
