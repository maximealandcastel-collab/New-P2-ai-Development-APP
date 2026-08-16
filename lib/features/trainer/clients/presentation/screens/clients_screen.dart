import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/home/widgets/feed_app_bar.dart';
import 'package:pler_to_pler_app/features/search/model/search_model.dart';
import 'package:pler_to_pler_app/features/search/search_screen.dart';
import 'package:pler_to_pler_app/features/trainer/balance/presentation/screens/balance_dashboard_view.dart';
import 'package:pler_to_pler_app/features/trainer/clients/data/models/client_invoice_model.dart';
import 'package:pler_to_pler_app/features/trainer/clients/presentation/controllers/clients_controller.dart';
import 'package:pler_to_pler_app/features/trainer/clients/presentation/screens/widgets/client_card_widget.dart';
import 'package:pler_to_pler_app/features/trainer/clients/presentation/screens/widgets/client_shimmer.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ClientsController.to;

    return Obx(() {
      final isBalance = controller.topTab.value == 1;

      return RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.backgroundLight,
        onRefresh: controller.refresh,
        edgeOffset: MediaQuery.heightOf(context) * 0.25,
        child: CustomScrollView(
          controller: isBalance ? null : controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // ── App bar with Clients | Balance pill ─────────────────
            FeedAppBarSliver(
              pinned: true,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(isBalance ? 60.h : 116.h),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Top-level Clients | Balance pill ──────────
                      CustomContainer(
                        radiusAll: 14.r,
                        color: Colors.white,
                        paddingAll: 4.r,
                        child: Row(
                          children: [
                            _buildTopTab(controller, 'Clients', Icons.people_rounded, 0),
                            _buildTopTab(controller, 'Balance', Icons.account_balance_wallet_rounded, 1),
                          ],
                        ),
                      ),

                      // ── Search + Paid/Invoice sub-tabs (Clients only) ──
                      if (!isBalance) ...[
                        SizedBox(height: 8.h),
                        CustomSearchField(
                          readOnly: true,
                          onTap: () => _openSearch(context, controller),
                          searchController: controller.searchController,
                          hintText: 'Search by name or condition',
                        ),
                        SizedBox(height: 8.h),
                        Obx(() => CustomContainer(
                          radiusAll: 14.r,
                          color: Colors.white,
                          paddingAll: 4.r,
                          child: Row(children: [
                            _buildSubTab(controller, 'Paid', 0),
                            _buildSubTab(controller, 'Invoice sent', 1),
                          ]),
                        )),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // ── Body ────────────────────────────────────────────────
            if (isBalance)
              SliverFillRemaining(
                hasScrollBody: true,
                child: const BalanceDashboardView(),
              )
            else ...[
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
                            onChatTap: controller.selectedTab == 1
                                ? null
                                : () => controller.onChatTap(invoice),
                          );
                        },
                      ),
                    );
                }
              }),
              PaginationLoaderSliver(controller: controller),
            ],
          ],
        ),
      );
    });
  }

  void _openSearch(BuildContext context, ClientsController controller) {
    showSearch(
      context: context,
      delegate: SearchScreen(
        hintText: 'Search by name or condition',
        onSearch: (String query) async {
          await controller.search.search(query);
          return controller.search.results
              .map((invoice) => SearchModel(
                    model: invoice,
                    title: invoice.clientName,
                    image: invoice.userId?.profilePicture,
                    subtitle: invoice.subscriptionPeriod,
                  ))
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

  Widget _buildTopTab(ClientsController controller, String label, IconData icon, int index) {
    final isSelected = controller.topTab.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.onTopTabSelected(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14.sp, color: isSelected ? Colors.white : Colors.grey),
              SizedBox(width: 5.w),
              Text(label,
                  style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubTab(ClientsController controller, String label, int index) {
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
