import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/controllers/workout_video_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class WorkoutVideoScreen extends StatelessWidget {
  const WorkoutVideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WorkoutVideoController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: const CustomAppBar(
        title: 'Workout video',
      ),
      body: Obx(
        () => Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Video(
                  controller: controller.videoController,
                  controls: MaterialVideoControls,
                  fill: AppColors.backgroundDark,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            if (controller.isLoadingMedia.value)
              const ColoredBox(
                color: Colors.black54,
                child: Center(child: CustomLoader()),
              ),
            if (!controller.isLoadingMedia.value &&
                controller.mediaError.value.isNotEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: CustomText(
                    text: controller.mediaError.value,
                    color: AppColors.textWhite,
                    fontSize: 14.sp,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
