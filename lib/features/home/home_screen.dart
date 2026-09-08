import 'package:flutter/material.dart';
import 'widgets/home_gym_brand.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import 'package:pler_to_pler_app/features/home/data/trainer_dashboard_stats.dart';
import 'package:pler_to_pler_app/features/nav_bar/controllers/nav_bar_controller.dart';
import 'package:pler_to_pler_app/features/trainer/assignedPlan/presentation/screen/assigned_plan_screen.dart';
import 'package:pler_to_pler_app/features/user/rate_my_peel/presentation/widgets/rate_my_peel_banner.dart';
import 'package:pler_to_pler_app/services/api_urls.dart';
import 'package:pler_to_pler_app/services/network/api_client.dart';
import 'package:pler_to_pler_app/widgets/app_bar.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TrainerDashboardStats _stats = const TrainerDashboardStats.empty();
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    final response = await ApiClient.getData(ApiUrls.trainerDashboardStats);
    if (!mounted) return;

    final body = response.body;
    final data = body is Map ? body['data'] : null;
    if (response.statusCode == 200 && data is Map) {
      setState(() {
        _stats = TrainerDashboardStats.fromJson(
          Map<String, dynamic>.from(data),
        );
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = false;
      _loadError = response.statusText ?? 'Dashboard data is unavailable.';
    });
  }

  String _value(int value) => _isLoading ? '—' : '$value';

  void _openClients() {
    Get.find<NavBarController>().onChange(1);
  }

  void _openAssignedPlans() {
    Get.to(() => const AssignedPlanScreen());
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.primary,
        onRefresh: _loadDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.only(bottom: 24.h),
          child: Column(
            children: [
              const FeedAppBar(),
              const HomeGymBrand(),
              SizedBox(height: 18.h),
              if (_loadError != null) _buildLoadError(),
              _buildClientOverview(),
              SizedBox(height: 12.h),
              const RateMyPeelBanner(),
              SizedBox(height: 12.h),
              _buildPaidClients(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadError() {
    return Semantics(
      liveRegion: true,
      child: Container(
        margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3ED),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.24)),
        ),
        child: Row(
          children: [
            Icon(Icons.cloud_off_outlined, size: 18.r, color: Theme.of(context).colorScheme.primary),
            SizedBox(width: 8.w),
            const Expanded(
              child: Text(
                'Dashboard totals could not be refreshed.',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
            TextButton(onPressed: _loadDashboard, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildClientOverview() {
    return CustomContainer(
      width: double.infinity,
      paddingAll: 18.r,
      radiusAll: 24.r,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: 'Client Overview',
            textAlign: TextAlign.start,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            bottom: 16.h,
          ),
          Row(
            children: [
              Expanded(
                child: _buildOverviewCard(
                  icon: Icons.people_alt_outlined,
                  label: 'Active Clients',
                  value: _value(_stats.activeClients),
                  onTap: _openClients,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildOverviewCard(
                  icon: Icons.star_outline_rounded,
                  label: 'New Clients (7 Days)',
                  value: _value(_stats.newClientsLast7Days),
                  onTap: _openClients,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildCompactOverviewCard(
                  icon: Icons.calendar_view_week_outlined,
                  label: 'This Week',
                  value: _value(_stats.newClientsThisWeek),
                  onTap: _openClients,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildCompactOverviewCard(
                  icon: Icons.restaurant_menu_rounded,
                  label: 'Meals Assigned',
                  value: _value(_stats.mealsAssigned),
                  onTap: _openAssignedPlans,
                  showAdd: true,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildCompactOverviewCard(
                  icon: Icons.fitness_center_rounded,
                  label: 'Workouts Assigned',
                  value: _value(_stats.workoutsAssigned),
                  onTap: _openAssignedPlans,
                  showAdd: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return _DashboardCard(
      onTap: onTap,
      height: 128.h,
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 30.r, color: Colors.black),
          CustomText(
            text: label,
            textAlign: TextAlign.start,
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
          CustomText(
            text: value,
            textAlign: TextAlign.start,
            fontSize: 30.sp,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactOverviewCard({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    bool showAdd = false,
  }) {
    return _DashboardCard(
      onTap: onTap,
      height: 148.h,
      padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 12.h),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 27.r, color: Colors.black),
              CustomText(
                text: label,
                textAlign: TextAlign.start,
                maxline: 2,
                textOverflow: TextOverflow.ellipsis,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              CustomText(
                text: value,
                textAlign: TextAlign.start,
                fontSize: 28.sp,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          if (showAdd)
            Positioned(
              top: -2.h,
              right: -2.w,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap,
                child: Container(
                  width: 30.r,
                  height: 30.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 21.r,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaidClients() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openClients,
        borderRadius: BorderRadius.circular(24.r),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(18.r),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text: 'Paid Clients',
                      textAlign: TextAlign.start,
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    Semantics(
                      button: true,
                      label: 'View all paid clients',
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 6.h,
                        ),
                        child: CustomText(
                          text: 'View all',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Container(
                  width: 70.r,
                  height: 70.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F3F3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.assignment_ind_outlined,
                    size: 32.r,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 14.h),
                CustomText(
                  text: 'Not enough data to view',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 42.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.child,
    required this.onTap,
    required this.height,
    required this.padding,
  });

  final Widget child;
  final VoidCallback onTap;
  final double height;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Ink(
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: child,
        ),
      ),
    );
  }
}
