import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/settings/presentation/controllers/invoices_controller.dart';
import 'package:pler_to_pler_app/features/settings/widgets/invoice_card_shimmer.dart';
import 'package:pler_to_pler_app/features/settings/widgets/invoice_card_widget.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = InvoicesController.to;

    return SliverScaffold(
      refreshEdgeOffset: MediaQuery.sizeOf(context).height * 0.16,
      onRefresh: controller.refresh,
      paginationList: controller.invoicesList,
      appBar: CustomSliverAppBar(
        title: 'Invoices',
        pinned: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56.h),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
            child: Obx(
              () => CustomContainer(
                color: Colors.white,
                radiusAll: 16.r,
                paddingAll: 4.r,
                child: Row(
                  children: [
                    _buildTabItem(
                      controller: controller,
                      label: 'All',
                      index: 0,
                    ),
                    _buildTabItem(
                      controller: controller,
                      label: 'Received',
                      index: 1,
                    ),
                    _buildTabItem(
                      controller: controller,
                      label: 'Pending',
                      index: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bodyList: [
        Obx(() => _buildInvoiceList(controller)),
        PaginationLoaderSliver(controller: controller),
        SizedBox(height: 120.h).asSliver,
      ],
    );
  }

  Widget _buildTabItem({
    required InvoicesController controller,
    required String label,
    required int index,
  }) {
    final isSelected = controller.selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.onTabSelected(index),
        child: CustomContainer(
          radiusAll: 12.r,
          paddingVertical: 12.h,
          color: isSelected ? AppColors.textPrimary : Colors.transparent,
          alignment: Alignment.center,
          child: CustomText(
            text: label,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceList(InvoicesController controller) {
    switch (controller.loadingState) {
      case LoadingState.initial:
      case LoadingState.loading:
        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => const InvoiceCardShimmer(),
              childCount: 5,
            ),
          ),
        );
      case LoadingState.offline:
      case LoadingState.error:
        return SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 40.h, 16.w, 120.h),
          sliver: SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyDataWidget(
              message: 'Failed to load invoices. Please try again.',
              onRefresh: controller.refresh,
            ),
          ),
        );
      case LoadingState.loaded:
        if (controller.invoices.isEmpty) {
          return SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 40.h, 16.w, 120.h),
            sliver: SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyDataWidget(
                message: _emptyMessage(controller.selectedTab),
                onRefresh: controller.refresh,
              ),
            ),
          );
        }

        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: SliverList.builder(
            itemCount: controller.invoices.length,
            itemBuilder: (context, index) {
              final invoice = controller.invoices[index];
              return InvoiceCardWidget(
                invoice: invoice,
                onTap: () => controller.onInvoiceTap(invoice),
              );
            },
          ),
        );
    }
  }

  String _emptyMessage(int selectedTab) {
    switch (selectedTab) {
      case 1:
        return 'No received invoices found';
      case 2:
        return 'No pending invoices found';
      default:
        return 'No invoices found';
    }
  }
}
