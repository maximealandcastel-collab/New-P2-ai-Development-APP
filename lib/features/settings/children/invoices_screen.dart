import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import 'package:pler_to_pler_app/features/settings/widgets/invoice_card_widget.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';
class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      paddingSide: 0,
      appBar: CustomAppBar(title: 'Invoices'),
      body: Column(
        children: [
          // Tab Bar
          CustomContainer(
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
              labelStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(text: 'All',height: 40.h),
                Tab(text: 'Received',height: 40.h),
                Tab(text: 'Pending',height: 40.h),

              ],
            ),
          ),

          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFilesList(),
                _buildFilesList(),
                _buildFilesList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilesList() {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh logic here
      },
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        physics: BouncingScrollPhysics(),
        itemCount: 20,
        itemBuilder: (BuildContext context, int index) {
          return InvoiceCardWidget();
        },
      ),
    );
  }
}


