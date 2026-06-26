import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ExerciseBlockScreen extends StatefulWidget {
  const ExerciseBlockScreen({super.key});

  @override
  State<ExerciseBlockScreen> createState() => _ExerciseBlockScreenState();
}

class _ExerciseBlockScreenState extends State<ExerciseBlockScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
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
                  TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              unselectedLabelStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(text: 'Manual', height: 40.h),
                Tab(text: 'Auto generate', height: 40.h),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabContent('No manual exercise block'),
          _buildTabContent('No auto generated exercise block'),
        ],
      ),
    );
  }

  Widget _buildTabContent(String emptyMessage) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyDataWidget(message: emptyMessage),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 120.h)),
      ],
    );
  }
}
