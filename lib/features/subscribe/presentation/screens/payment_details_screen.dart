import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/screens/payment_success_screen.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/plan_model.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/controllers/subscribe_controller.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/screens/widgets/subscribe_card.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class TrainerUpgradeScreen extends StatefulWidget {
  const TrainerUpgradeScreen({super.key});

  @override
  State<TrainerUpgradeScreen> createState() => _TrainerUpgradeScreenState();
}

class _TrainerUpgradeScreenState extends State<TrainerUpgradeScreen> {

  @override
  Widget build(BuildContext context) {
    final controller = SubscribeController.to;
    return CustomScaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 60.h),
                Center(child: Assets.images.logo.image(height: 110.h)),
                CustomText(
                  top: 10.h,
                  text: 'Unlock Your Full\nAi Fitness Experience',fontSize: 26.sp,fontWeight: FontWeight.w600,),
                
                CustomText(
                  top: 10.h,
                    bottom: 20.h,
                    text: 'Get personalized plans, expert guidance\nand real results.'),


                CustomContainer(
                  paddingAll: 16.r,
                  radiusAll: 20.r,
                  width: double.infinity,
                  color: Colors.white,
                  child: Column(
                    children: [
                      Assets.icons.subscribeIcons.svg(),

                      SizedBox(height: 20.h),
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: PlanModel.plans.length,
                        itemBuilder: (context, index) {
                          return Obx(
                                  () {
                                return SubscribeCard(
                                    plan: PlanModel.plans[index],
                                    isSelected: controller.selectedIndex == index,
                                    onTap: () =>  controller.onChange(index)
                                );
                              }
                          );
                        },
                      )
                    ],
                  ),
                ),

                SizedBox(height: 20.h),
                // Upgrade Button
                CustomButton(onPressed: () {
                  Get.to(() => const PaymentSuccessScreen());
                }, label: "Upgrade Now"),
                SizedBox(height: 16.h),
                CustomText(text:
                'Cancel anytime • No hidden fees',
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),

                SizedBox(height: 20.h),

              ],
            ),
          ),

          // Close button
          Positioned(
            top: 6.h,
            right: 0,
            child: SafeArea(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: CustomContainer(
                  shape: BoxShape.circle,
                  paddingAll: 8.r,
                  color: Colors.white,
                  child:  Assets.icons.clean.svg(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}