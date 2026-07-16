import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/anam/presentation/controllers/anam_connect_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class AiVideoChatConnectScreen extends StatelessWidget {
  const AiVideoChatConnectScreen({super.key});

  AnamConnectController get _controller => Get.find<AnamConnectController>();

  @override
  Widget build(BuildContext context) {
    return SliverScaffold(
      appBar: CustomSliverAppBar(title: 'Ai Video Chat'),
      bodyList: [
        SizedBox(height: 24.h).asSliver,
        Obx(
          () => CustomContainer(
            paddingAll: 14.r,
            radiusAll: 16.r,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  text: 'Anam Persona ID',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  bottom: 10.h,
                ),
                if (_controller.hasConfiguredPersona.value)
                  ..._buildConfiguredContent()
                else
                  ..._buildSetupContent(),
              ],
            ),
          ).asSliverWithPadding(horizontal: 16.w),
        ),
      ],
    );
  }

  List<Widget> _buildConfiguredContent() {
    return [
      CustomText(
        text: 'AI video chat is already enabled for your account.',
        fontSize: 13.sp,
        color: AppColors.textSecondary,
        bottom: 12.h,
      ),
      CustomContainer(
        width: double.infinity,
        paddingAll: 12.r,
        radiusAll: 12.r,
        color: AppColors.backgroundLight,
        child: CustomText(
          text: _controller.configuredPersonaId ?? '',
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          textAlign: TextAlign.start,
        ),
      ),
    ];
  }

  List<Widget> _buildSetupContent() {
    return [
      CustomText(
        text:
            'Set your Anam Lab persona ID so your subscribed clients can start AI video calls with you.',
        fontSize: 13.sp,
        color: Colors.grey,
        bottom: 12.h,
      ),
      CustomTextField(
        controller: _controller.personaController,
        hintText: 'Enter your persona ID',
      ),
      SizedBox(height: 16.h),
      CustomButton(
        onPressed: _controller.connectPersona,
        label: 'Save persona ID',
        isLoading: _controller.submitState.value == LoadingState.loading,
      ),
    ];
  }
}
