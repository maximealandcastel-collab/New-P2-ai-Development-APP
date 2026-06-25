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
import 'package:pler_to_pler_app/widgets/custom_search_field.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class FindTrainerScreen extends StatelessWidget {
  const FindTrainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SubscribeController.to;

    return SliverScaffold(
      floating: false,
      appBarTitle: 'Find trainer',
      expandedHeight: 134.h,
      flexiblePaddingTop: 16.h,
      scrollController: controller.scrollController,
      onRefresh: controller.refresh,
      flexibleChild: CustomSearchField(
        readOnly: true,
        onTap: () {
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
        },
        searchController: controller.searchController,
        hintText: 'Search trainer by name or needs',
      ),
      slivers: (BuildContext context) => [
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
              ).asSliver;
            case LoadingState.loaded:
              if (controller.trainers.isEmpty) {
                return const EmptyDataWidget(
                  message: 'No trainers found.',
                ).asSliver;
              }
              return SliverList.separated(
                itemCount: controller.trainers.length,
                itemBuilder: (_, i) {
                  return FindTrainerCard(trainer: controller.trainers[i]);
                },
                separatorBuilder: (context, index) => SizedBox(height: 10.h),
              ).asPaddedSliver(horizontal: 16.w);
          }
        }),
        PaginationLoaderSliver(controller: controller),
        SizedBox(height: 70.h).asSliver,
      ],
    );
  }
}
