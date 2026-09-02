import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import 'package:pler_to_pler_app/custom_assets/assets.gen.dart';
import 'package:pler_to_pler_app/features/home/widgets/session_card_widget.dart';
import 'package:pler_to_pler_app/features/user/rate_my_peel/presentation/widgets/rate_my_peel_banner.dart';
import 'package:pler_to_pler_app/features/nav_bar/controllers/nav_bar_controller.dart';
import 'package:pler_to_pler_app/widgets/app_bar.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openSchedule() {
    Get.find<NavBarController>().onChange(3);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            FeedAppBar(),
            SizedBox(height: 24.h),
            CustomContainer(
              radiusAll: 16.r,
              paddingAll: 16.r,
              width: double.infinity,
              color: Colors.white,
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    fontWeight: FontWeight.w500,
                    fontSize: 15.sp,
                    bottom: 12.h,
                    text: 'Client Overview',
                  ),

                  Wrap(
                    spacing: 16.w,
                    runSpacing: 16.h,
                    children: [
                      _buildClientOverviewCard(
                        icon: Assets.icons.clients.path,
                        label: 'Active Clients',
                        point: '22',
                      ),
                      _buildClientOverviewCard(
                        icon: Assets.icons.star.path,
                        label: 'New this week',
                        point: '3',
                      ),
                      _buildClientOverviewCard(
                        icon: Assets.icons.attention.path,
                        label: 'Need Attention',
                        point: '4',
                      ),
                      _buildClientOverviewCard(
                        icon: Assets.icons.missing.path,
                        label: 'Missed session',
                        point: '4',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 8.h),
            SizedBox(height: 8.h),
            const RateMyPeelBanner(),
            SizedBox(height: 8.h),
            CustomContainer(
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
                        fontWeight: FontWeight.w500,
                        fontSize: 15.sp,
                        text: 'Today’s Sessions (4)',
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _openSchedule,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 6.h,
                          ),
                          child: CustomText(
                            fontWeight: FontWeight.w500,
                            fontSize: 13.sp,
                            text: 'View all',
                          ),
                        ),
                      ),
                    ],
                  ),

                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: 2,
                    itemBuilder: (context, index) {
                       return SessionsCardWidget(onTap: _openSchedule);
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 8.h),

            // AiInsightWidget(),

            SizedBox(height: 100.h),
          ],
        ),
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
      paddingAll: 12.r,
      alignment: Alignment.centerLeft,
      color: Colors.black.withOpacity(0.08),
      height: 112.h,
      width: 151.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset(icon, height: 24.r, width: 24.r),
          CustomText(
            text: label,
            fontSize: 11.sp,
            color: AppColors.textSecondary,
          ),
          CustomText(
            textAlign: TextAlign.start,
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
            text: point,
          ),
        ],
      ),
    );
  }
}
