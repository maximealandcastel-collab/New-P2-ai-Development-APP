import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/custom_assets/assets.gen.dart';
import 'package:pler_to_pler_app/custom_assets/fonts.gen.dart';
import 'package:pler_to_pler_app/features/settings/children/invoices_screen.dart';
import 'package:pler_to_pler_app/features/settings/widgets/transation_history_widget.dart';
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
        title: 'Earnings',
        actions: [
          GestureDetector(
            onTapDown: (details) async {
              final selected = await MenuShowHelper.showCustomMenu(
                context: context,
                details: details,
                options: ['Payout method', 'Invoices'],
              );

              if (selected == 'Payout method') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payout method management is not available yet.'),
                  ),
                );
              } else if (selected == 'Invoices') {
                Get.to(() => const InvoicesScreen());
              }
            },
            child: Padding(
              padding: EdgeInsets.all(8.0.r),
              child: Assets.icons.more.svg(),
            ),
          ),
        ],
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
                      text: 'Available balance',
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
                        text: '48.54',
                        children: [
                          TextSpan(
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                              fontSize: 20.sp,
                            ),
                            text: ' USD',
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
                        text: 'Pending balance ',
                        children: [
                          TextSpan(
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                            text: ' 48.54',
                          ),
                          TextSpan(text: ' USD'),
                        ],
                      ),
                    ),
                  ),
                  CustomText(
                    text: 'Transaction history',
                    fontWeight: FontWeight.w600,
                    fontSize: 18.sp,
                    bottom: 12.h,
                    top: 24.h,
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => const TransationHistoryWidget(),
                childCount: 10,
              ),
            ),
          ),

          // FIXED HERE: Wrapped in SliverToBoxAdapter
          SliverToBoxAdapter(
            child: SizedBox(height: 30.h),
          ),
        ],
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: CustomButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Withdrawals require a configured payout method and withdrawal service.',
                  ),
                ),
              );
            },
            label: 'Withdraw',
            width: double.infinity,
          ),
        ),
      ),
    );
  }
}



