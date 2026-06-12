import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/controllers/subscribe_controller.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/screens/widgets/subscribe_option_card.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class TrainerProfileScreen extends StatelessWidget {
  const TrainerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SubscribeController.to;

    return CustomScaffold(
      paddingSide: 0,
      appBar: CustomAppBar(title: 'Subscribe'),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            SizedBox(height: 24.h),
            Obx(
              () => SubscribeOptionCard(
                icon: Assets.icons.defultTrainer.svg(),
                title: 'Use app default trainer \$19.99',
                description:
                    'Get access to a certified trainer assigned by the app.'
                    ' Enjoy personalized workout guidance and continuous'
                    ' support at an affordable monthly price.',
                isSelected: controller.selected == 0,
                onTap: () => controller.selected = 0,
              ),
            ),
            SizedBox(height: 14.h),
            Obx(
              () => SubscribeOptionCard(
                icon: Assets.icons.personalTrainer.svg(),
                title: 'Choose personal trainer',
                description:
                    'Select your preferred trainer and receive a customized '
                    'fitness plan tailored to your goals, schedule, and '
                    'training preferences.',
                isSelected: controller.selected == 1,
                onTap: () => controller.selected = 1,
              ),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.all(16.r),
          child: CustomButton(
            onPressed: () {
              Get.toNamed(AppRoute.trainerUpgradeScreen);
            },
            label: 'Continue',
          ),
        ),
      ),
    );
  }
}
