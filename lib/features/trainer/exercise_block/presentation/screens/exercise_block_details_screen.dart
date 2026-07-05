import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/controllers/exercise_block_details_controller.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/widgets/exercise_block_details_content.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/widgets/exercise_block_shimmer.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ExerciseBlockDetailsScreen extends StatelessWidget {
  const ExerciseBlockDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ExerciseBlockDetailsController.to;

    return SliverScaffold(
      appBar: const CustomSliverAppBar(
        title: 'Exercise block details',
        pinned: true,
      ),
      onRefresh: controller.refresh,
      refreshEdgeOffset: MediaQuery.sizeOf(context).height * 0.1,
      bodyList: [
        Obx(() {
          switch (controller.loadingState) {
            case LoadingState.initial:
            case LoadingState.loading:
              return const ExerciseBlockShimmer(itemCount: 3).asSliver;
            case LoadingState.offline:
            case LoadingState.error:
              return EmptyDataWidget(
                message: 'Failed to load exercise block details.',
                onRefresh: controller.refresh,
              ).asFillRemainingSliver();
            case LoadingState.loaded:
              final block = controller.block;
              if (block == null) {
                return const EmptyDataWidget(
                  message: 'Exercise block not found.',
                ).asFillRemainingSliver();
              }
              return ExerciseBlockDetailsContent(block: block)
                  .asSliverWithPadding(horizontal: 16.w);
          }
        }),
        SizedBox(height: 70.h).asSliver,
      ],
    );
  }
}
