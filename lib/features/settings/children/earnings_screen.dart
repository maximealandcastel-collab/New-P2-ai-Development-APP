import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(
        title: 'Deposits',
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CustomText(
                      text: 'Available tokens',
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                      color: AppColors.textSecondary,
                      bottom: 8.h,
                      top: 24.h,
                    ),
                  ),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 40.sp,
                        ),
                        text: '0',
                        children: [
                          TextSpan(
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                              fontSize: 20.sp,
                            ),
                            text: ' tokens',
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  CustomContainer(
                    width: double.infinity,
                    radiusAll: 16.r,
                    color: Colors.white,
                    paddingAll: 18.r,
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 16.sp,
                        ),
                        text: 'Deposited balance ',
                        children: [
                          TextSpan(
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                            text: ' \$0.00',
                          ),
                          const TextSpan(text: ' USD'),
                        ],
                      ),
                    ),
                  ),
                  CustomText(
                    text: 'How tokens are used',
                    fontWeight: FontWeight.w600,
                    fontSize: 18.sp,
                    bottom: 12.h,
                    top: 24.h,
                  ),
                  _buildProviderCard(
                    badge: 'A',
                    name: 'Anam AI',
                    description: 'Interactive AI coach voice and avatar sessions.',
                    color: const Color(0xFF7C3AED),
                  ),
                  _buildProviderCard(
                    badge: 'C',
                    name: 'Claude',
                    description: 'Primary workout planning and coaching intelligence.',
                    color: const Color(0xFFD97706),
                  ),
                  _buildProviderCard(
                    badge: 'G',
                    name: 'ChatGPT',
                    description: 'Backup assistance when the primary coach is unavailable.',
                    color: const Color(0xFF059669),
                  ),
                  SizedBox(height: 20.h),
                  CustomText(
                    text: 'Deposit history',
                    fontWeight: FontWeight.w600,
                    fontSize: 18.sp,
                    bottom: 12.h,
                  ),
                  CustomContainer(
                    width: double.infinity,
                    radiusAll: 16.r,
                    color: Colors.white,
                    paddingAll: 22.r,
                    child: Column(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 34.r,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(height: 10.h),
                        CustomText(
                          text: 'No deposits yet',
                          fontWeight: FontWeight.w500,
                        ),
                        SizedBox(height: 4.h),
                        CustomText(
                          text: 'Your completed token refills will appear here.',
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 30.h),
          ),
        ],
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: CustomButton(
              onPressed: _showRefillSheet,
              label: 'Refill tokens',
            width: double.infinity,
          ),
        ),
      ),
    );
  }

  Widget _buildProviderCard({
    required String badge,
    required String name,
    required String description,
    required Color color,
  }) {
    return CustomContainer(
      width: double.infinity,
      radiusAll: 16.r,
      color: Colors.white,
      paddingAll: 14.r,
      marginBottom: 8.h,
      child: Row(
        children: [
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: CustomText(
              text: badge,
              color: color,
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: name,
                  textAlign: TextAlign.start,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 3.h),
                CustomText(
                  text: description,
                  textAlign: TextAlign.start,
                  fontSize: 11.sp,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRefillSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 24.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              SizedBox(height: 18.h),
              CustomText(
                text: 'Refill tokens',
                textAlign: TextAlign.start,
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 8.h),
              CustomText(
                text:
                    'Token package amounts are being finalized. No charge will be made until a secure package and price are shown for your approval.',
                textAlign: TextAlign.start,
                fontSize: 13.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 18.h),
              CustomContainer(
                width: double.infinity,
                radiusAll: 14.r,
                paddingAll: 14.r,
                color: AppColors.primary.withOpacity(0.08),
                child: CustomText(
                  text:
                      'Tokens can be used for fresh workout generation, AI coach chat, and Anam AI sessions.',
                  textAlign: TextAlign.start,
                  fontSize: 13.sp,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 18.h),
              CustomButton(
                onPressed: () => Navigator.pop(sheetContext),
                label: 'Got it',
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}



