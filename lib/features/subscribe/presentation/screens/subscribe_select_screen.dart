import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/controllers/subscribe_controller.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/screens/widgets/subscribe_option_card.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class SubscribeSelectScreen extends StatelessWidget {
  const SubscribeSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SubscribeController.to;
    return SliverScaffold(
      appBar: CustomSliverAppBar(
        title: 'Subscribe',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            CustomText(
              top: 8.h,
              textAlign: TextAlign.start,
              text:
              'Unlock everything\nP2P Tech has to offer',
                fontSize: 22.sp,
                fontWeight: FontWeight.w600,
              ),
            CustomText(
              top: 8.h,
              text:
              'Choose the plan that works best for you\nand start achieving your goals.',
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 24.h),
            Obx(() => SubscribeOptionCard(
                icon: Assets.icons.defultTrainer.svg(),
                title: 'Use app default trainer',
                price: '\$19.99',
                features: const [
                  'AI-guided plans & workouts',
                  'Track progress & analytics',
                  'Access to all core features',
                ],
                isSelected: controller.selected == 0,
                onTap: () => controller.selected = 0,
                showBadge: true,
                badgeTitle: 'Most Popular',
                badgeSubtitle: 'Great for getting started',
              ),
            ),
            SizedBox(height: 14.h),
            Obx(
                  () => SubscribeOptionCard(
                icon: Assets.icons.personalTrainer.svg(),
                title: 'Choose personal trainer',
                price: 'Custom',
                features: const [
                  'Everything in default trainer',
                  '1-on-1 trainer sessions',
                  'Personalized plans & support',
                ],
                isSelected: controller.selected == 1,
                onTap: () => controller.selected = 1,
              ),
            ),
            SizedBox(height: 24.h),
            // Trust row

            SizedBox(height: 24.h),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _trustItem(Icons.lock_outline, 'Secure Payment'),
              _trustItem(Icons.shield_outlined, 'Cancel Anytime'),
              _trustItem(Icons.headset_mic_outlined, '24/7 Support'),
            ],
          ),
          SizedBox(height: 16.h),
          CustomButton(
            onPressed: () {
              if (SubscribeController.to.selected == 0) {
                Get.toNamed(AppRoute.trainerUpgradeScreen);
              } else {
                Get.toNamed(AppRoute.findTrainerScreen);
              }
            },
            label: 'Continue',
          ),
          SizedBox(height: 10.h),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
              children: [
                const TextSpan(text: 'By continuing, you agree to our '),
                TextSpan(
                  text: 'Terms of Service',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _trustItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: Colors.grey[500]),
        SizedBox(width: 4.h),
        CustomText(text:
          label,
          fontSize: 10.sp, color: Colors.grey[500],
        ),
      ],
    );
  }
}