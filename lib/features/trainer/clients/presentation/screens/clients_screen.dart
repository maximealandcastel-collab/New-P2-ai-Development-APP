import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/home/widgets/feed_app_bar.dart';
import 'package:pler_to_pler_app/features/search/model/search_model.dart';
import 'package:pler_to_pler_app/features/search/search_screen.dart';
import 'package:pler_to_pler_app/features/trainer/clients/data/models/client_invoice_model.dart';
import 'package:pler_to_pler_app/features/trainer/clients/presentation/controllers/clients_controller.dart';
import 'package:pler_to_pler_app/features/trainer/clients/presentation/screens/widgets/client_card_widget.dart';
import 'package:pler_to_pler_app/features/trainer/clients/presentation/widgets/client_shimmer.dart';
import 'package:pler_to_pler_app/widgets/custom_search_field.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ClientsController.to;

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.backgroundLight,
      onRefresh: controller.refresh,
      edgeOffset: MediaQuery.heightOf(context) * 0.25,
      child: CustomScrollView(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          FeedAppBarSliver(
            pinned: true,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(116.h),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomSearchField(
                      readOnly: true,
                      onTap: () => _openSearch(context, controller),
                      searchController: controller.searchController,
                      hintText: 'Search by name or condition',
                    ),
                    SizedBox(height: 12.h),
                    Obx(
                      () => CustomContainer(
                        radiusAll: 14.r,
                        color: Colors.white,
                        paddingAll: 4.r,
                        child: Row(
                          children: [
                            _buildTabItem(
                              controller: controller,
                              label: 'Paid',
                              index: 0,
                            ),
                            _buildTabItem(
                              controller: controller,
                              label: 'Invoice sent',
                              index: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Obx(() {
            switch (controller.loadingState) {
              case LoadingState.initial:
              case LoadingState.loading:
                return const ClientShimmer().asSliver;
              case LoadingState.offline:
              case LoadingState.error:
                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 130.h),
                  sliver: SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyDataWidget(
                      message: 'Failed to load clients. Please try again.',
                      onRefresh: controller.refresh,
                    ),
                  ),
                );
              case LoadingState.loaded:
                if (controller.clients.isEmpty) {
                  return SliverPadding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 130.h),
                    sliver: SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyDataWidget(
                        message: controller.selectedTab == 0
                            ? 'No paid clients found'
                            : 'No invoice sent clients found',
                        onRefresh: controller.refresh,
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 130.h),
                  sliver: SliverList.builder(
                    itemCount: controller.clients.length,
                    itemBuilder: (context, index) {
                      final invoice = controller.clients[index];
                      return ClientCardWidget(
                        invoice: invoice,
                        onTap: () => controller.onClientTap(invoice),
                        onChatTap: () => controller.onChatTap(invoice),
                      );
                    },
                  ),
                );
            }
          }),
          PaginationLoaderSliver(controller: controller),
        ],
      ),
    );
  }

  void _openSearch(BuildContext context, ClientsController controller) {
    showSearch(
      context: context,
      delegate: SearchScreen(
        hintText: 'Search by name or condition',
        onSearch: (String query) async {
          await controller.search.search(query);
          return controller.search.results
              .map(
                (invoice) => SearchModel(
                  model: invoice,
                  title: invoice.clientName,
                  image: invoice.userId?.profilePicture,
                  subtitle: invoice.subscriptionPeriod,
                ),
              )
              .toList();
        },
        onResultTap: (result) {
          controller.search.clear();
          final invoice = result.model as ClientInvoiceModel?;
          if (invoice != null) {
            Get.back();
            controller.onClientTap(invoice);
            return;
          }
          controller.applySearchQuery(result.title ?? '');
          Get.back();
        },
      ),
    );
  }

  Widget _buildTabItem({
    required ClientsController controller,
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
          color: isSelected ? Colors.black : Colors.transparent,
          alignment: Alignment.center,
          child: CustomText(
            text: label,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }
}
