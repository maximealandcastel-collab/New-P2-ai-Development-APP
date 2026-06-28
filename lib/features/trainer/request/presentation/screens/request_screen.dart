import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/home/widgets/feed_app_bar.dart';
import 'package:pler_to_pler_app/features/search/model/search_model.dart';
import 'package:pler_to_pler_app/features/search/search_screen.dart';
import 'package:pler_to_pler_app/features/trainer/request/data/models/trainer_request_model.dart';
import 'package:pler_to_pler_app/features/trainer/request/presentation/controllers/requests_controller.dart';
import 'package:pler_to_pler_app/features/trainer/request/presentation/widgets/request_card.dart';
import 'package:pler_to_pler_app/features/trainer/request/presentation/widgets/request_shimmer.dart';
import 'package:pler_to_pler_app/widgets/custom_search_field.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class RequestScreen extends StatelessWidget {
  const RequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = RequestsController.to;

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.backgroundLight,
      onRefresh: controller.refresh,
      edgeOffset: MediaQuery.heightOf(context) * 0.19,
      child: CustomScrollView(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          FeedAppBarSliver(
            pinned: true,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(58.h),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
                child: CustomSearchField(
                  readOnly: true,
                  onTap: () => _openSearch(context, controller),
                  searchController: controller.searchController,
                  hintText: 'Search by name or condition',
                ),
              ),
            ),
          ),
          Obx(() {
            switch (controller.loadingState) {
              case LoadingState.initial:
              case LoadingState.loading:
                return const RequestShimmer().asSliver;
              case LoadingState.offline:
              case LoadingState.error:
                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 130.h),
                  sliver: SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyDataWidget(
                      message: 'Failed to load requests. Please try again.',
                      onRefresh: controller.refresh,
                    ),
                  ),
                );
              case LoadingState.loaded:
                if (controller.requests.isEmpty) {
                  return SliverPadding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 130.h),
                    sliver: SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyDataWidget(
                        message: 'No requests found',
                        onRefresh: controller.refresh,
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 130.h),
                  sliver: SliverList.builder(
                    itemCount: controller.requests.length,
                    itemBuilder: (context, index) {
                      final request = controller.requests[index];
                      return RequestCard(request: request);
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

  void _openSearch(BuildContext context, RequestsController controller) {
    showSearch(
      context: context,
      delegate: SearchScreen(
        hintText: 'Search by name or condition',
        onSearch: (String query) async {
          await controller.search.search(query);
          return controller.search.results
              .map(
                (request) => SearchModel(
                  model: request,
                  title: request.clientName,
                  image: request.userId?.profilePicture,
                  subtitle: request.statusLabel,
                ),
              )
              .toList();
        },
        onResultTap: (result) {
          controller.search.clear();
          final request = result.model as TrainerRequestModel?;
          if (request != null) {
            Get.back();
            controller.applySearchQuery(request.clientName);
            return;
          }
          controller.applySearchQuery(result.title ?? '');
          Get.back();
        },
      ),
    );
  }
}
