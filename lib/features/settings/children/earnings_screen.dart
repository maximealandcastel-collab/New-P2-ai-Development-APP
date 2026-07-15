import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/core/utils/fonts.gen.dart';

import 'package:pler_to_pler_app/features/settings/children/invoices_screen.dart';
import 'package:pler_to_pler_app/features/settings/presentation/controllers/earnings_controller.dart';
import 'package:pler_to_pler_app/features/settings/widgets/transation_history_widget.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EarningsController>();

    return SliverScaffold(
      refreshEdgeOffset: MediaQuery.heightOf(context) * 0.15,
      onRefresh: controller.refresh,
      paginationList: controller.paymentsList,
      appBar: CustomSliverAppBar(
        title: 'Earnings',
        expandedHeight: 240.h,
        flexibleChild: Obx(() {
          final earningsData = controller.earnings?.data;
          
          final availableRaw = earningsData?.formatted?.availableBalance ?? '\$0.00';
          final availableStr = availableRaw.replaceAll('\$', '').trim();
          
          final pendingRaw = earningsData?.formatted?.pendingWithdrawal ?? '\$0.00';
          final pendingStr = pendingRaw.replaceAll('\$', '').trim();

          return Padding(
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
                      text: availableStr,
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
                          text: ' $pendingStr',
                        ),
                        TextSpan(text: ' USD'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
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
              child: Assets.icons.more.svg(height: 44.r, width: 44.r),
            ),
          ),
        ],
      ),
      bodyList: _buildSlivers(context, controller),
      bottomNavigationBar: CustomButton(
        onPressed: () {},
        label: 'Withdraw',
        width: double.infinity,
      ),
    );
  }

  List<Widget> _buildSlivers(BuildContext context, EarningsController controller) => [
        CustomText(
          left: 16.w,
          bottom: 4.h,
          textAlign: TextAlign.start,
          text: 'Transaction history',
          fontWeight: FontWeight.w600,
          fontSize: 18.sp,
        ).asSliver,
        Obx(() {
          final payments = controller.payments;
          
          if (controller.isFirstTimePaymentsLoad.value && 
              (controller.paymentsState == LoadingState.initial || 
               controller.paymentsState == LoadingState.loading)) {
            return SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => const TransactionHistoryShimmer(),
                  childCount: 5,
                ),
              ),
            );
          }

          switch (controller.paymentsState) {
            case LoadingState.initial:
            case LoadingState.loading:
              if (payments.isEmpty) {
                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const TransactionHistoryShimmer(),
                      childCount: 5,
                    ),
                  ),
                );
              }
              break;
            case LoadingState.offline:
            case LoadingState.error:
              if (payments.isEmpty) {
                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 40.h, 16.w, 120.h),
                  sliver: SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyDataWidget(
                      message: 'Failed to load transaction history.',
                      onRefresh: () => controller.refresh(),
                    ),
                  ),
                );
              }
              break;
            case LoadingState.loaded:
              if (payments.isEmpty) {
                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 40.h, 16.w, 120.h),
                  sliver: SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyDataWidget(
                      message: 'No transaction history found.',
                      onRefresh: () => controller.refresh(),
                    ),
                  ),
                );
              }
              break;
          }

          return SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final transaction = payments[index];
                  return TransationHistoryWidget(transaction: transaction);
                },
                childCount: payments.length,
              ),
            ),
          );
        }),
        PaginationLoaderSliver(controller: controller),
        SizedBox(height: 120.h).asSliver,
      ];
}

class TransactionHistoryShimmer extends StatelessWidget {
  const TransactionHistoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: CustomContainer(
        marginTop: 8.h,
        radiusAll: 16.r,
        color: Colors.white,
        paddingHorizontal: 12.w,
        child: ListTile(
          leading: Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          contentPadding: EdgeInsets.zero,
          title: Container(
            width: 120.w,
            height: 16.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Container(
              width: 80.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
          trailing: Container(
            width: 60.w,
            height: 16.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ),
      ),
    );
  }
}
