import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/search/model/search_model.dart';
import 'package:pler_to_pler_app/features/search/search_screen.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/controllers/subscribe_controller.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/screens/widgets/find_trainer_card.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/screens/widgets/find_trainer_shimmer.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class FindTrainerScreen extends StatelessWidget {
  const FindTrainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SubscribeController.to;

    return SliverScaffold(
      appBar: CustomSliverAppBar(
        expandedHeight: 134.h,
        title: 'Find trainer',
        flexiblePaddingTop: 16.h,
        flexibleChild: CustomSearchField(
          readOnly: true,
          onTap: () => _openSearch(context, controller),
          searchController: controller.searchController,
          hintText: 'Search trainer by name or needs',
        ),
      ),
      onRefresh: controller.refresh,
      refreshEdgeOffset: MediaQuery.sizeOf(context).height * 0.1,
      paginationList: controller.trainersList,
      bodyList: [
        Obx(() {
          switch (controller.loadingState) {
            case LoadingState.initial:
            case LoadingState.loading:
              return const FindTrainerShimmer().asSliver;
            case LoadingState.offline:
            case LoadingState.error:
              return EmptyDataWidget(
                message: 'Failed to load trainers. Please try again.',
                onRefresh: controller.refresh,
              ).asFillRemainingSliver();
            case LoadingState.loaded:
              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.h,
                    childAspectRatio: 3 / 4.8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, index) => FindTrainerCard(
                      trainer: controller.trainers[index],
                    ),
                    childCount: controller.trainers.length,
                  ),
                ),
              );
          }
        }),
        PaginationLoaderSliver(controller: controller),
        SizedBox(height: 130.h).asSliver,
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
                  subtitle:
                      trainer.subscriptionPrice?.premium.toString(),
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
