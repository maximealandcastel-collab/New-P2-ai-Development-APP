import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/core/utils/fonts.gen.dart';

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
    return SliverScaffold(
      floating: false,
      appBarTitle: 'Earnings',
      actions: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) async {
            final selected = await MenuShowHelper.showCustomMenu(
              context: context,
              details: details,
              options: ['Payout method', 'Invoices'],
            );

            if (selected == 'Payout method') {
              debugPrint('Payout method selected');
            } else if (selected == 'Invoices') {
              Get.to(() => const InvoicesScreen());
            }
          },
          child: Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: Assets.icons.more.svg(height: 44.r,width: 44.r),
          ),
        ),
      ],
      expandedHeight: 240.h,
      flexibleChild: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CustomText(
                text: 'Available balance',
                fontWeight: FontWeight.w500,
                fontSize: 16.sp,
                color: AppColors.textSecondary,
                bottom: 8.h,
                top: 8.h,
              ),
            ),
            Center(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 40.sp,
                    fontFamily: FontFamily.figtree,
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
                    fontFamily: FontFamily.figtree,
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
          ],
        ),
      ),

        slivers: (c) => [
          CustomText(
            left: 16.w,
            bottom: 4.h,
            textAlign: TextAlign.start,
            text: 'Transaction history',
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
          ).asSliver,
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => const TransationHistoryWidget(),
                childCount: 10,
              ),
            ),
          ),
        ],

      bottomNavigationBar: CustomButton(
        onPressed: () {},
        label: 'Withdraw',
        width: double.infinity,
      ),
    );
  }
}
