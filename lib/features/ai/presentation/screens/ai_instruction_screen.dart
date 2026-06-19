import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/custom_app_bar.dart';
import 'package:pler_to_pler_app/widgets/custom_button.dart';
import 'package:pler_to_pler_app/widgets/custom_scaffold.dart';
import 'package:pler_to_pler_app/widgets/custom_text.dart';

class AiInstructionScreen extends StatelessWidget {
  const AiInstructionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: CustomScaffold(
        appBar: CustomAppBar(
          actions: [
            IconButton(
              onPressed: () {
                Get.offAllNamed(AppRoute.bottonNavBar);
              },
              icon: CustomText(
                right: 6.w,
                text: "Skip",
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Assets.images.appLogo.image(height: 84.h,width: 84.w),
            SizedBox(height: 24.h),
            CustomText(text: 'Instruction',fontWeight: FontWeight.w600,fontSize: 24.sp,),

            CustomText(
              top: 16.h,
              color: AppColors.textSecondary,
              text: 'Please provide your information carefully.'
                ' We are collecting this data to train your personalized '
                'AI model, ensuring it can deliver accurate responses '
                'that closely reflect your style and preferences.',
             ),
            SizedBox(height: 200.h)
          ],
        ),

        bottomNavigationBar: SafeArea(
            child: Padding(
              padding:  EdgeInsets.all(16.r),
              child: CustomButton(onPressed: (){
                Get.offAllNamed(AppRoute.trainAiScreen);
              },label: 'Train your personal AI',),
            )),
      ),
    );
  }
}
