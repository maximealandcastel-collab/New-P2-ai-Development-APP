import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import 'package:pler_to_pler_app/custom_assets/assets.gen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/complete_profile/payment_success_screen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class TrainerUpgradeScreen extends StatefulWidget {
  const TrainerUpgradeScreen({super.key});

  @override
  State<TrainerUpgradeScreen> createState() => _TrainerUpgradeScreenState();
}

class _TrainerUpgradeScreenState extends State<TrainerUpgradeScreen> {
  final List<Map<String, dynamic>> features = [
    {'icon': Icons.lock, 'text': 'Unlimited P2bot access'},
    {'icon': Icons.lock, 'text': 'Unlimited client management'},
    {'icon': Icons.lock, 'text': 'Smart exercise plan generator'},
    {'icon': Icons.lock, 'text': 'Advanced progress analytics'},
  ];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomContainer(
                  height: 286.h,
                  image: DecorationImage(
                    image: AssetImage(Assets.images.img1.path),
                    fit: BoxFit.cover,
                  ),
                  child: CustomContainer(
                    marginTop: 100.h,
                    linearColors: [
                      AppColors.backgroundLight.withAlpha(0),
                      AppColors.backgroundLight,
                    ],

                  ),
                ),

                /// Welcome text section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      CustomText(text:
                        'Upgrade to\nAdvanced Trainer',
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w600,
                        textAlign: TextAlign.start,
                        bottom: 8.h,

                      ),
                      // Subtitle
                      CustomText(text:
                        'Unlock AI-powered recovery insights and\ngrow your coaching business',
                          color: AppColors.textSecondary,
                        textAlign: TextAlign.start,

                      ),
                      SizedBox(height: 24.h),

                      // Pricing
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CustomText(text:
                          '\$32',
                            fontSize: 40.sp,
                            fontWeight: FontWeight.w800,
                          ),
                          SizedBox(width: 6.w),
                          CustomText(
                            bottom: 8.h,
                            text:
                            'per month',
                            color: AppColors.textSecondary,

                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      CustomText(text:
                      'Unlock These Advanced Features',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        textAlign: TextAlign.start,

                      ),
                      SizedBox(height: 4.h),
                      CustomText(text:
                      'Gain access to powerful tools to enhance\nyour coaching:',
                        color: AppColors.textSecondary,
                        textAlign: TextAlign.start,
                      ),
                      SizedBox(height: 20.h),

                      // Features list with animation
                      ...List.generate(
                        features.length,
                            (index) => Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: Row(
                            children: [
                              CustomContainer(
                                radiusAll: 8.r,
                                paddingAll: 8.r,
                                color: Colors.white,
                                child: Icon(
                                  features[index]['icon'],
                                  size: 16.sp,
                                  color: Colors.grey.shade900,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              CustomText(text:
                                features[index]['text'],
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  textAlign: TextAlign.start,

                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Close button
          Positioned(
            top: 6.h,
            right: 16.w,
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
            ],
          ),
        ),
      ),
    );
  }
}