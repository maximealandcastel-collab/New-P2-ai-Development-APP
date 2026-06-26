import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/search/model/search_model.dart';
import 'package:pler_to_pler_app/features/search/search_screen.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/controllers/subscribe_controller.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/screens/widgets/find_trainer_card.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/screens/widgets/find_trainer_shimmer.dart';
import 'package:pler_to_pler_app/widgets/custom_search_field.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class FindTrainerScreen extends StatelessWidget {
  const FindTrainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SubscribeController.to;

    return SliverScaffold(
      appBar: CustomSliverAppBar(
        title: 'Find trainer',
        flexibleChild: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
          child: CustomSearchField(
            readOnly: true,
            onTap: () => _openSearch(context, controller),
            searchController: controller.searchController,
            hintText: 'Search trainer by name or needs',
          ),
        ),
      ),
      onRefresh: controller.refresh,
      scrollController: controller.scrollController,
      bodyList: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 4.h),
              child: Obx(() {
                if (controller.loadingState != LoadingState.loaded) {
                  return const SizedBox.shrink();
                }

                final count = controller.trainers.length;
                return CustomText(
                  textAlign: TextAlign.start,
                  text: count == 0
                      ? 'No trainers available right now'
                      : '$count trainer${count == 1 ? '' : 's'} available',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                );
              }),
            ),
          ),
          Obx(() {
            switch (controller.loadingState) {
              case LoadingState.initial:
              case LoadingState.loading:
                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 130.h),
                  sliver: const SliverToBoxAdapter(child: FindTrainerShimmer()),
                );
              case LoadingState.offline:
              case LoadingState.error:
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyDataWidget(
                    message: 'Failed to load trainers. Please try again.',
                    onRefresh: controller.refresh,
                  ),
                );
              case LoadingState.loaded:
                if (controller.trainers.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyDataWidget(
                      message: 'No trainers found.',
                      onRefresh: controller.refresh,
                    ),
                  );
                }

                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 130.h),
                  sliver: SliverList.separated(
                    itemCount: controller.trainers.length,
                    separatorBuilder: (_, _) => SizedBox(height: 10.h),
                    itemBuilder: (_, index) {
                      return FindTrainerCard(
                        trainer: controller.trainers[index],
                      );
                    },
                  ),
                );
            }
          }),
          PaginationLoaderSliver(controller: controller),
        ],
    );
  }

  void _openSearch(BuildContext context, SubscribeController controller) {
    showSearch(
      context: context,
      delegate: SearchScreen(
        onSearch: (String query) async {
          await controller.search.search(query);
          return controller.search.results
              .map(
                (trainer) => SearchModel(
                  model: trainer,
                  title: trainer.userId?.fullName,
                  image: trainer.userId?.profilePicture,
                  subtitle: trainer.subscriptionPrice?.premium.toString(),
                ),
              )
              .toList();
        },
        onResultTap: (result) {
          controller.search.clear();
          Get.toNamed(
            AppRoute.trainerProfileScreen,
            arguments: result.model.sId as String,
          );
        },
      ),
    );
  }
}
