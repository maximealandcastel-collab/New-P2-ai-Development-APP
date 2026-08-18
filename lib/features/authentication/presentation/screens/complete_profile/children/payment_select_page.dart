import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import 'package:pler_to_pler_app/custom_assets/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class PaymentSelectPage extends StatefulWidget {
  const PaymentSelectPage({super.key});

  @override
  State<PaymentSelectPage> createState() => _PaymentSelectPageState();
}

class _PaymentSelectPageState extends State<PaymentSelectPage> {
  String selectedPayment = 'Payoneer';

  final TextEditingController emailController = TextEditingController();

  final List<Map<String, dynamic>> paymentOptions = [
    {
      'label': 'Payoneer',
      'icon': Assets.icons.payoneer.path,
    },
    {
      'label': 'PayPal',
      'icon': Assets.icons.paypal.path,
    },
    {
      'label': 'Stripe',
      'icon': Assets.icons.stripe.path,
    },{
      'label': 'Wire transfer',
      'icon': Assets.icons.transfer.path,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: 'Select payout method',
          fontSize: 24.sp,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 32.h),
          ...paymentOptions.map((gender) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _buildGenderOption(gender),
          )),
          SizedBox(height: 16.h),
          CustomText(text: '$selectedPayment detail'),
          SizedBox(height: 8.h),
      
      
          CustomContainer(
            paddingAll: 16.r,
            color: Colors.white,
            radiusAll: 16.r,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  prefixIcon: Assets.icons.emailIcon.image(height: 24.h, width: 24.w),
                  labelText: '$selectedPayment mail',
                  hintText: 'Enter your $selectedPayment email',
                  controller: emailController,
                ),
      
                CustomContainer(
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: 40.h,
                  radiusAll: 12.r,
                  color: Colors.black.withOpacity(0.04),
                  child: CustomText(
                    color: AppColors.textSecondary,
                    fontSize: 10.sp,
                    textAlign: TextAlign.start,
                      text: 'A verification mail will be sent to connect to $selectedPayment.'),
                )
      
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGenderOption(Map<String, dynamic> option) {
    final isSelected = selectedPayment == option['label'];

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPayment = option['label'];
        });
      },
      child: CustomContainer(
        paddingHorizontal: 16.w,
        paddingVertical: 16.h,
          color: Colors.white,
          radiusAll: 16.r,
        child: Row(
          children: [
            SvgPicture.asset(option['icon'], width: 40.w, height: 40.h),
            SizedBox(width: 12.w),
            CustomText(
              textAlign: TextAlign.start,
              text: option['label'],
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
            Spacer(),
            CustomContainer(
              width: 24.w,
              height: 24.h,
                shape: BoxShape.circle,
                bordersColor: isSelected ? Colors.black : Colors.grey.shade400,
                borderWidth: isSelected ? 2 : 1,
                color: isSelected ? Colors.black : Colors.transparent,
              child: isSelected
                  ? Icon(
                Icons.circle,
                size: 12.sp,
                color: Colors.white,
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}