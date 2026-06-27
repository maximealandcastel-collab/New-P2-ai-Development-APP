import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/controllers/subscribe_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class PromoCodeScreen extends StatelessWidget {
  const PromoCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SubscribeController.to;

    return SliverScaffold(
      appBar: const CustomSliverAppBar(
        title: 'Apply Promo Code',
      ),
      bodyList: [
        SizedBox(height: 24.h).asSliver,
        Center(
          child: CustomContainer(
            width: 88.w,
            height: 88.w,
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.12),
            child: Icon(
              Icons.local_offer_rounded,
              size: 40.sp,
              color: AppColors.primary,
            ),
          ),
        ).asSliver,
        CustomText(
          top: 20.h,
          text: 'Got a promo code?',
          fontSize: 22.sp,
          fontWeight: FontWeight.w600,
          textAlign: TextAlign.center,
        ).asSliverWithPadding(horizontal: 20.w),
        CustomText(
          top: 8.h,
          text:
              'Enter your code below to unlock exclusive\ndiscounts on your subscription.',
          fontSize: 13.sp,
          color: AppColors.textSecondary,
          textAlign: TextAlign.center,
        ).asSliverWithPadding(horizontal: 20.w),
        SizedBox(height: 28.h).asSliver,
        CustomTextField(
          controller: controller.promoCodeController,
          labelText: 'Promo code',
          hintText: 'e.g. P2PTECH20',
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => controller.applyPromoCode(popOnSuccess: true),
          validator: (_) => null,
        ).asSliverWithPadding(horizontal: 20.w),
        SizedBox(height: 20.h).asSliver,
        _PromoInfoCard(
          items: const [
            _PromoInfoItem(
              icon: Icons.percent,
              title: 'Instant discount',
              subtitle: 'Save on your first month instantly',
            ),
            _PromoInfoItem(
              icon: Icons.verified_outlined,
              title: 'One code per order',
              subtitle: 'Apply before completing payment',
            ),
            _PromoInfoItem(
              icon: Icons.schedule_outlined,
              title: 'Limited time offers',
              subtitle: 'Some codes may expire soon',
            ),
          ],
        ).asSliverWithPadding(horizontal: 20.w),
        SizedBox(height: 120.h).asSliver,
      ],
      bottomNavigationBar: Obx(
        () => CustomButton(
          label: 'Apply Code',
          isLoading: controller.isApplyingPromo,
          onPressed: () => controller.applyPromoCode(popOnSuccess: true),
        ),
      ),
    );
  }
}

class _PromoInfoCard extends StatelessWidget {
  const _PromoInfoCard({required this.items});

  final List<_PromoInfoItem> items;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      width: double.infinity,
      paddingAll: 16.r,
      radiusAll: 16.r,
      color: Colors.white,
      bordersColor: AppColors.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: 'How it works',
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            bottom: 12.h,
            textAlign: TextAlign.start,
          ),
          ...items.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomContainer(
                    width: 36.w,
                    height: 36.w,
                    radiusAll: 10.r,
                    color: AppColors.primary.withValues(alpha: 0.1),
                    child: Icon(
                      item.icon,
                      size: 18.sp,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: item.title,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          textAlign: TextAlign.start,
                        ),
                        CustomText(
                          text: item.subtitle,
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoInfoItem {
  const _PromoInfoItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}
