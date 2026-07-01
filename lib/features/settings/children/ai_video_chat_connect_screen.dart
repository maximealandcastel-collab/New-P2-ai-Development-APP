import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class AiVideoChatConnectScreen extends StatelessWidget {
  const AiVideoChatConnectScreen({super.key});

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
                text: 'Personal ID',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                bottom: 10.h,
              ),
              CustomTextField(hintText: 'Enter your personal ID'),

              SizedBox(height: 16.h),

              CustomButton(onPressed: () {}, label: 'Connect'),
            ],
          ),
        ).asSliverWithPadding(horizontal: 16.w),
      ],
    );
  }
}
