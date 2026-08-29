import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:pler_to_pler_app/features/home/presentation/controllers/trainer_home_controller.dart';
import 'package:pler_to_pler_app/features/home/widgets/trainer_client_plans_section.dart';
import 'package:pler_to_pler_app/features/home/widgets/empty_data.dart';
import 'package:pler_to_pler_app/features/home/widgets/feed_app_bar.dart';
import 'package:pler_to_pler_app/features/trainer/clients/presentation/controllers/clients_controller.dart';
import 'package:pler_to_pler_app/features/trainer/clients/presentation/screens/widgets/client_card_widget.dart';
import 'package:pler_to_pler_app/features/trainer/clients/presentation/screens/widgets/client_shimmer.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class TrainerHomeScreen extends StatelessWidget {
  const TrainerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = TrainerHomeController.to;
    final clientsController = ClientsController.to;

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.backgroundLight,
      onRefresh: () async {
        await Future.wait([
          homeController.refresh(),
          clientsController.refresh(),
        ]);
      },
     edgeOffset: MediaQuery.heightOf(context) * 0.16,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          const FeedAppBarSliver(),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 130.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildClientOverviewSection(homeController),
                SizedBox(height: 8.h),
                const TrainerClientPlansSection(),
                SizedBox(height: 8.h),
                _buildTodaySessionsSection(clientsController),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientOverviewSection(TrainerHomeController controller) {
    return Obx(() {
      final stats = controller.dashboardStats?.data;
      final activeClients = stats?.activeUsersCount?.toString() ?? '0';
      final newRolling7Days = stats?.newUsersThisWeek?.rolling7Days?.toString() ?? '0';
      final newCalendarWeek = stats?.newUsersThisWeek?.calendarWeek?.toString() ?? '0';
      final totalWorkoutBlocks = stats?.workoutBlocksStats?.total?.toString() ?? '0';
      return CustomContainer(
        radiusAll: 16.r,
        paddingAll: 14.r,
        width: double.infinity,
        color: Colors.white,
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              fontWeight: AppFontWeight.label,
              fontSize: 16.sp,
              bottom: 12.h,
              text: 'Client Overview',
            ),
            GridView.count(
              padding: EdgeInsets.zero,
              crossAxisCount: 2,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 151.w / 112.h,
              children: [
                _buildClientOverviewCard(
                  icon: Assets.icons.clients.path,
                  label: 'Active Clients',
                  point: activeClients,
                ),
                _buildClientOverviewCard(
                  icon: Assets.icons.star.path,
                  label: 'New (7 Days)',
                  point: newRolling7Days,
                ),
                _buildClientOverviewCard(
                  icon: Assets.icons.attention.path,
                  label: 'This Calendar Week',
                  point: newCalendarWeek,
                ),
                _buildClientOverviewCard(
                  icon: Assets.icons.exercise.path,
                  label: 'Workout Blocks',
                  point: totalWorkoutBlocks,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTodaySessionsSection(ClientsController clientsController) {
    return CustomContainer(
      radiusAll: 16.r,
      paddingAll: 16.r,
      width: double.infinity,
      color: Colors.white,
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                fontWeight: AppFontWeight.label,
                fontSize: 16.sp,
                text: 'Paid Clients',
              ),
              GestureDetector(
                onTap: () {
                  BottomNavBarController.to.onChange(1);
                },
                behavior: HitTestBehavior.opaque,
                child: CustomText(
                  fontWeight: AppFontWeight.label,
                  fontSize: 14.sp,
                  color: AppColors.primary,
                  text: 'View all',
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Obx(() {
            switch (clientsController.loadingState) {
              case LoadingState.initial:
              case LoadingState.loading:
                return const ClientShimmer(itemCount: 2);
              case LoadingState.offline:
              case LoadingState.error:
              return EmptyData(
                  isRecommendation: false,
                  subtitle: 'Not enough data to view');
              case LoadingState.loaded:
                final paidClients = clientsController.clients;
                if(paidClients.isEmpty){
                                   return EmptyData(
                                     isRecommendation: false,
                                       subtitle: 'Not enough data to view');

                }
                final displayedClients = paidClients.take(2).toList();
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: displayedClients.length,
                  itemBuilder: (context, index) {
                    final invoice = displayedClients[index];
                    return ClientCardWidget(
                      invoice: invoice,
                      onTap: () => clientsController.onClientTap(invoice),
                      onChatTap: () => clientsController.onChatTap(invoice),
                    );
                  },
                );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildClientOverviewCard({
    required String icon,
    required String label,
    required String point,
  }) {
    return CustomContainer(
      radiusAll: 12.r,
      paddingAll: 10.r,
      alignment: Alignment.centerLeft,
      color: Colors.black.withValues(alpha: 0.08),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset(icon, height: 24.r, width: 24.r),
          CustomText(
            text: label,
            fontSize: 12.sp,
            color: AppColors.textSecondary,
          ),
          CustomText(
            textAlign: TextAlign.start,
            fontSize: 28.sp,
            fontWeight: AppFontWeight.stat,
            text: point,
          ),
        ],
      ),
    );
  }
}
