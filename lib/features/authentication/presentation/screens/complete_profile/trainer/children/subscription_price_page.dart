import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/profile_complete_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/widgets/complete_profile_page_title.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class SubscriptionPricePage extends StatelessWidget {
  const SubscriptionPricePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileCompleteController.to;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CompleteProfilePageTitle(
          text: 'Set your subscription price',
          center: true,
        ),
        SizedBox(height: 12.h),
        Center(
          child: CustomText(
            text: 'Choose a monthly price for your premium plan',
            fontSize: 14.sp,
            color: AppColors.textSecondary,
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 24.h),
        CustomContainer(
          paddingAll: 20.r,
          radiusAll: 20.r,
          width: double.infinity,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: 'monthly',
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
              SizedBox(height: 4.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomText(
                    text: '\$',
                    fontSize: 36.sp,
                    fontWeight: FontWeight.w800,
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: CustomTextField(
                      hintText: '00',
                      keyboardType: TextInputType.number,
                      controller: controller.premiumPriceController,
                      inputFormatter: [FilteringTextInputFormatter.digitsOnly],
                      contentPaddingHorizontal: 12.w,
                      contentPaddingVertical: 8.h,
                      hintextSize: 36.sp,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a subscription price';
                        }
                        final price = int.tryParse(value.trim());
                        if (price == null || price <= 0) {
                          return 'Please enter a valid price';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Assets.icons.trainerSubIcons.svg(),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ],
    );
  }
}
