import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/data/models/exercise_block_model.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/controllers/create_exercise_block_controller.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/controllers/exercise_block_controller.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/widgets/exercise_block_card.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/widgets/exercise_block_fab.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/widgets/exercise_block_shimmer.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ExerciseBlockScreen extends StatefulWidget {
  const ExerciseBlockScreen({super.key});

  @override
  State<ExerciseBlockScreen> createState() => _ExerciseBlockScreenState();
}

class _ExerciseBlockScreenState extends State<ExerciseBlockScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final controller = ExerciseBlockController.to;
  final createController = CreateExerciseBlockController.to;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {});
  }

  bool get _isManualTab => _tabController.index == 0;

  void _onDeleteBlock(ExerciseBlockModel block) {
    showDialog(
      context: context,
      builder: (context) {
        return Obx(
          () => CustomDialog(
            title: 'Delete exercise block',
            description:
                'Are you sure you want to delete "${block.title}"? This action cannot be undone.',
            rightButtonLabel: 'Yes, Delete',
            isLoading: controller.deleteLoadingState.isLoading,
            onTapLeftButton: () => Get.back(),
            onTapRightButton: () => controller.deleteBlock(block.id ?? ''),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverScaffold(
      appBar: CustomSliverAppBar(
        title: 'Exercise block',
        pinned: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: CustomContainer(
            horizontalMargin: 16,
            verticalMargin: 6.h,
            color: Colors.white,
            radiusAll: 16.r,
            child: TabBar(
              padding: EdgeInsets.zero,
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(16.r),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle:
                  TextStyle(fontSize: 16.sp, fontWeight: AppFontWeight.label),
              unselectedLabelStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: AppFontWeight.emphasis,
              ),
              tabs: [
                Tab(text: 'Manual', height: 40.h),
                Tab(text: 'Auto generate', height: 40.h),
              ],
            ),
          ),
        ),
      ),
      onRefresh: controller.refresh,
      refreshEdgeOffset: MediaQuery.sizeOf(context).height * 0.2,
      paginationList: controller.blocksList,
      bodyList: [
        Obx(() {
          switch (controller.loadingState) {
            case LoadingState.initial:
            case LoadingState.loading:
              return const ExerciseBlockShimmer().asSliver;
            case LoadingState.offline:
            case LoadingState.error:
              return EmptyDataWidget(
                message: 'Failed to load exercise blocks. Please try again.',
                onRefresh: controller.refresh,
              ).asFillRemainingSliver();
            case LoadingState.loaded:
              if (controller.blocks.isEmpty) {
                return const EmptyDataWidget(
                  message: 'No exercise block',
                ).asFillRemainingSliver();
              }
              return SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                sliver: SliverList.separated(
                  itemCount: controller.blocks.length,
                  separatorBuilder: (_, _) => SizedBox(height: 10.h),
                  itemBuilder: (_, index) {
                    final block = controller.blocks[index];
                    return ExerciseBlockCard(
                      block: block,
                      onTap: () => controller.onBlockTap(block),
                      onEdit: () => controller.onEditBlock(block),
                      onDelete: () => _onDeleteBlock(block),
                    );
                  },
                ),
              );
          }
        }),
        PaginationLoaderSliver(controller: controller),
        SizedBox(height: 160.h).asSliver,
      ],
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 8.h, right: 4.w),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: ExerciseBlockFab(
            key: ValueKey(_isManualTab),
            label: _isManualTab ? 'Add exercise block' : 'Generate exercise',
            icon: _isManualTab ? Icons.add_rounded : Icons.auto_awesome_rounded,
            onPressed: _isManualTab
                ? createController.onAddExerciseBlock
                : createController.onGenerateExercise,
          ),
        ),
      ),
    );
  }
}
