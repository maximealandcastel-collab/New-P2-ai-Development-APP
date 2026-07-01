import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
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
        CustomContainer(
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
              CustomText(
                text:
                    'Enter the persona ID from Anam Lab to enable AI video calls for your clients.',
                fontSize: 13.sp,
                color: Colors.grey,
                bottom: 12.h,
              ),
              CustomTextField(
                controller: _controller.personaController,
                hintText: 'Enter your persona ID',
              ),
              SizedBox(height: 16.h),
              Obx(
                () => CustomButton(
                  onPressed: _controller.connectPersona,
                  label: 'Connect',
                  isLoading:
                      _controller.submitState.value == LoadingState.loading,
                ),
              ),
            ],
          ),
        ).asSliverWithPadding(horizontal: 16.w),
      ],
    );
  }
}
