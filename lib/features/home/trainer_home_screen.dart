import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'widgets/home_gym_brand.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:pler_to_pler_app/features/home/presentation/controllers/trainer_home_controller.dart';
import 'package:pler_to_pler_app/features/home/widgets/trainer_client_plans_section.dart';
import 'package:pler_to_pler_app/features/home/widgets/empty_data.dart';
import 'package:pler_to_pler_app/features/home/widgets/feed_app_bar.dart';
import 'package:pler_to_pler_app/features/home/widgets/trainer_dashboard_widgets.dart';
import 'package:pler_to_pler_app/features/trainer/clients/presentation/controllers/clients_controller.dart';
import 'package:pler_to_pler_app/features/trainer/clients/data/models/client_invoice_model.dart';
import 'package:pler_to_pler_app/features/trainer/createExercisePlan/presentation/screen/create_exercise_plan_screen.dart';
import 'package:pler_to_pler_app/features/trainer/mealPlan/presentation/screens/create_meal_plan_screen.dart';
import 'package:pler_to_pler_app/features/user/rate_my_peel/presentation/widgets/rate_my_peel_banner.dart';
import 'package:pler_to_pler_app/features/trainer/clients/presentation/screens/widgets/client_card_widget.dart';
import 'package:pler_to_pler_app/features/trainer/clients/presentation/screens/widgets/client_shimmer.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class TrainerHomeScreen extends StatefulWidget {
  const TrainerHomeScreen({super.key});

  @override
  State<TrainerHomeScreen> createState() => _TrainerHomeScreenState();
}

class _TrainerHomeScreenState extends State<TrainerHomeScreen> {
  // Session-scoped on purpose: hiding the notice never persists across sign-in.
  bool _showTrainerNotice = true;

  @override
  Widget build(BuildContext context) {
    final homeController = TrainerHomeController.to;
    final clientsController = ClientsController.to;

    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
          const SliverToBoxAdapter(child: HomeGymBrand()),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 132.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildClientOverviewSection(context, homeController, clientsController),
                SizedBox(height: 14.h),
                const RateMyPeelBanner(
                  margin: EdgeInsets.zero,
                  compact: true,
                ),
                if (_showTrainerNotice) ...[
                  SizedBox(height: 10.h),
                  TrainerAlertCard(
                    onHide: () => setState(() => _showTrainerNotice = false),
                  ),
                ],
                SizedBox(height: 14.h),
                const TrainerClientPlansSection(),
                SizedBox(height: 8.h),
                _buildTodaySessionsSection(context, clientsController),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientOverviewSection(BuildContext context, TrainerHomeController controller, ClientsController clientsController) {
    return Obx(() {
      final stats = controller.dashboardStats?.data;
      final activeClients = stats?.activeUsersCount?.toString() ?? '0';
      final newRolling7Days = stats?.newUsersThisWeek?.rolling7Days?.toString() ?? '0';
      final newCalendarWeek = stats?.newUsersThisWeek?.calendarWeek?.toString() ?? '0';
      final mealsAssigned = stats?.mealsAssigned?.toString() ?? '0';
      final totalWorkoutBlocks = stats?.workoutBlocksStats?.total?.toString() ?? '0';
      return CustomContainer(
        radiusAll: 15.r,
        paddingAll: 12.r,
        width: double.infinity,
        color: Colors.white,
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              fontWeight: AppFontWeight.emphasis,
              fontSize: 15.sp,
              bottom: 10.h,
              text: 'Client Overview',
            ),
            Column(
              children: [
                SizedBox(
                  height: 98.h,
                  child: Row(
                    children: [
                      Expanded(
                        child: OverviewStatCard(
                          assetIcon: Assets.icons.clients.path,
                          label: 'Active Clients',
                          value: activeClients,
                          onTap: () => BottomNavBarController.to.onChange(1),
                        ),
                      ),
                      SizedBox(width: 9.w),
                      Expanded(
                        child: OverviewStatCard(
                          assetIcon: Assets.icons.star.path,
                          label: 'New Clients (7 Days)',
                          value: newRolling7Days,
                          onTap: () => BottomNavBarController.to.onChange(1),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 9.h),
                SizedBox(
                  height: 106.h,
                  child: Row(
                    children: [
                      Expanded(
                        child: AssignmentCard(
                          assetIcon: Assets.icons.attention.path,
                          label: 'This Week',
                          value: newCalendarWeek,
                          onTap: () => BottomNavBarController.to.onChange(1),
                          onAdd: () => BottomNavBarController.to.onChange(1),
                        ),
                      ),
                      SizedBox(width: 9.w),
                      Expanded(
                        child: AssignmentCard(
                          icon: Icons.restaurant_menu_rounded,
                          label: 'Meals Assigned',
                          value: mealsAssigned,
                          onTap: () => _showClientPicker(
                            context,
                            clientsController,
                            _AssignmentType.meal,
                          ),
                          onAdd: () => _showClientPicker(
                            context,
                            clientsController,
                            _AssignmentType.meal,
                          ),
                        ),
                      ),
                      SizedBox(width: 9.w),
                      Expanded(
                        child: AssignmentCard(
                          assetIcon: Assets.icons.exercise.path,
                          label: 'Workouts Assigned',
                          value: totalWorkoutBlocks,
                          onTap: () => _showClientPicker(
                            context,
                            clientsController,
                            _AssignmentType.workout,
                          ),
                          onAdd: () => _showClientPicker(
                            context,
                            clientsController,
                            _AssignmentType.workout,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      );
    });
  }

  Widget _buildTodaySessionsSection(BuildContext context, ClientsController clientsController) {
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
                fontSize: 15.5.sp,
                text: 'Paid Clients',
              ),
              GestureDetector(
                onTap: () {
                  BottomNavBarController.to.onChange(1);
                },
                behavior: HitTestBehavior.opaque,
                child: CustomText(
                  fontWeight: AppFontWeight.label,
                  fontSize: 13.sp,
                  color: Theme.of(context).colorScheme.primary,
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

  void _showClientPicker(BuildContext context, ClientsController controller, _AssignmentType type) {
    final clients = controller.clients;
    if (clients.isEmpty) { Get.snackbar('No clients available', 'A paid client must be active before you can assign a plan.'); return; }
    Get.bottomSheet(
      SafeArea(child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .65),
        padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 22.h),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          CustomText(text: type == _AssignmentType.meal ? 'Assign a meal plan' : 'Assign a workout plan', fontSize: 18.sp, fontWeight: AppFontWeight.section),
          SizedBox(height: 4.h),
          CustomText(text: 'Choose one of your active clients.', fontSize: 12.sp, color: const Color(0xFF6B7280)),
          SizedBox(height: 12.h),
          Flexible(child: ListView.separated(shrinkWrap: true, itemCount: clients.length, separatorBuilder: (_, __) => const Divider(height: 1), itemBuilder: (_, index) {
            final client = clients[index]; final initial = client.clientName.isNotEmpty ? client.clientName[0].toUpperCase() : '?';
            return ListTile(contentPadding: EdgeInsets.zero, leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(.12), child: Text(initial, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold))), title: Text(client.clientName), subtitle: Text(client.userId?.email ?? 'Active client'), trailing: const Icon(Icons.chevron_right), onTap: () { Get.back(); if (type == _AssignmentType.meal) { Get.to(() => CreateMealPlanScreen(client: client)); } else { Get.to(() => CreateExercisePlanScreen(client: client)); } });
          })),
        ]),
      )),
      isScrollControlled: true,
    );
  }
}

enum _AssignmentType { meal, workout }
