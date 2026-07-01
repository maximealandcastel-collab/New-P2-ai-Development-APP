import 'package:anam_flutter_sdk/anam_flutter_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/anam/domain/services/anam_service.dart';
import 'package:pler_to_pler_app/features/anam/presentation/arguments/anam_call_args.dart';
import 'package:pler_to_pler_app/features/anam/presentation/controllers/anam_call_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

class AnamCallScreen extends StatelessWidget {
  const AnamCallScreen({super.key});

  AnamCallController get _controller => Get.find<AnamCallController>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _controller.endCall();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          title: _controller.trainerName,
          actions: [
            Obx(() {
              final remaining = _controller.usage.value?.minutesRemaining;
              if (remaining == null) return const SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: Center(
                  child: CustomText(
                    text: '$remaining min left',
                    fontSize: 12.sp,
                    color: Colors.black,
                  ),
                ),
              );
            }),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(child: _buildVideoArea()),
              _buildStatusSection(),
              _buildControls(),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoArea() {
    return Obx(() {
      if (_controller.hasError) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.videocam_off_outlined,
                  color: Colors.black,
                  size: 48.r,
                ),
                SizedBox(height: 16.h),
                CustomText(
                  text: _controller.errorMessage.value ??
                      'Could not start video call',
                  fontSize: 14.sp,
                  color: Colors.black,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                CustomButton(
                  label: 'Try again',
                  onPressed: _controller.startCall,
                ),
                SizedBox(height: 12.h),
                CustomButton(
                  label: 'Go back',
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.black,
                  onPressed: _controller.endCall,
                ),
              ],
            ),
          ),
        );
      }

      final renderer = _controller.renderer;
      final ready = _controller.isStreamReady.value;
      final micOn = _controller.micEnabled.value;

      if (renderer != null && ready) {
        return AnamAvatarView(
          renderer: renderer,
          isMicEnabled: micOn,
          showControls: false,
          borderRadius: 0,
          backgroundColor: Colors.black,
        );
      }

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CustomLoader(),
            SizedBox(height: 16.h),
            CustomText(
              text: _controller.statusLabel(),
              fontSize: 14.sp,
              color: Colors.black,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatusSection() {
    return Obx(() {
      final suggested = _controller.lastSuggestedTitle.value;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          children: [
            CustomText(
              text: _controller.statusLabel(),
              fontSize: 14.sp,
              color: Colors.black,
              textAlign: TextAlign.center,
            ),
            if (suggested != null && suggested.isNotEmpty) ...[
              SizedBox(height: 8.h),
              CustomContainer(
                paddingAll: 8.r,
                radiusAll: 20.r,
                color: AppColors.primary.withValues(alpha: 0.2),
                child: CustomText(
                  text: 'Suggested: $suggested',
                  fontSize: 12.sp,
                  color: Colors.black,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildControls() {
    return Obx(() {
      if (_controller.hasError) return const SizedBox.shrink();

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(
              _controller.micEnabled.value ? Icons.mic : Icons.mic_off,
              color: Colors.black,
              size: 28.sp,
            ),
            onPressed: _controller.toggleMic,
          ),
          GestureDetector(
            onTap: _controller.endCall,
            child: Container(
              width: 64.r,
              height: 64.r,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.call_end,
                color: Colors.black,
                size: 28.sp,
              ),
            ),
          ),
        ],
      );
    });
  }
}

Future<void> openAnamVideoCall({
  required String trainerId,
  required String trainerName,
}) async {
  if (LoginController.to.isTrainer()) {
    ToastMessageHelper.show('Only clients can start AI video calls');
    return;
  }

  final micStatus = await Permission.microphone.request();
  if (!micStatus.isGranted) {
    ToastMessageHelper.show('Microphone permission is required for video calls');
    return;
  }

  await Get.toNamed(AppRoute.anamCallScreen, arguments: AnamCallArgs(
    trainerId: trainerId,
    trainerName: trainerName,
  ));
}

Future<void> prefetchAnamUsage(AnamService service) async {
  try {
    await service.getUsage();
  } catch (_) {}
}
