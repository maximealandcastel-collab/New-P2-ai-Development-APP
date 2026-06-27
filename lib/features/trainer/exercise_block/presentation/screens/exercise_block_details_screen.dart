import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/controllers/exercise_block_details_controller.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/widgets/block_exercise_details_card.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/widgets/exercise_block_details_info.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/widgets/exercise_block_shimmer.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ExerciseBlockDetailsScreen extends StatelessWidget {
  const ExerciseBlockDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ExerciseBlockDetailsController.to;

    return Obx(() {
      final block = controller.block;

      return SliverScaffold(
        appBar: CustomSliverAppBar(
          title: block?.title ?? 'Exercise block details',
          pinned: true,
        ),
        onRefresh: controller.refresh,
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
                if (block == null) {
                  return const EmptyDataWidget(
                    message: 'Exercise block not found.',
                  ).asFillRemainingSliver();
                }

                final exercises = block.exercises ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExerciseBlockDetailsInfo(block: block),
                    SizedBox(height: 20.h),
                    CustomText(
                      text: 'Exercises (${exercises.length})',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: 12.h),
                    if (exercises.isEmpty)
                      const EmptyDataWidget(message: 'No exercises in this block.')
                    else
                      ...exercises.map(
                        (exercise) => BlockExerciseDetailsCard(exercise: exercise),
                      ),
                  ],
                ).asSliverWithPadding(horizontal: 16.w);
            }
          }),
          SizedBox(height: 24.h).asSliver,
        ],
      );
    });
  }
}
