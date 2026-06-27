import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/home/widgets/feed_app_bar.dart';
import 'package:pler_to_pler_app/features/home/widgets/session_card_widget.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class TrainerHomeScreen extends StatelessWidget {
  const TrainerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const FeedAppBarSliver(),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 130.h),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildClientOverviewSection(),
              SizedBox(height: 8.h),
              _buildTodaySessionsSection(),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildClientOverviewSection() {
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
            fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildTodaySessionsSection() {
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
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
                text: 'Today’s Sessions (4)',
              ),
              CustomText(
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
                text: 'View all',
              ),
            ],
          ),
          ListView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 2,
            itemBuilder: (context, index) {
              return SessionsCardWidget();
            },
          ),
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
            fontWeight: FontWeight.w700,
            text: point,
          ),
        ],
      ),
    );
  }
}
