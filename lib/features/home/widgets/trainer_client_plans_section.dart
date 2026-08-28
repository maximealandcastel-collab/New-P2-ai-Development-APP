import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/home/data/models/trainer_client_plan_model.dart';
import 'package:pler_to_pler_app/features/home/presentation/controllers/trainer_home_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

/// Shown on the trainer home screen — lists each subscribed client's
/// current workout plan and today's session focus.
class TrainerClientPlansSection extends StatelessWidget {
  const TrainerClientPlansSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TrainerHomeController.to;

    return Obx(() {
      final plans = controller.clientPlans;
      if (plans.isEmpty) return const SizedBox.shrink();

      return CustomContainer(
        radiusAll: 16.r,
        paddingAll: 14.r,
        width: double.infinity,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomText(
                    fontWeight: AppFontWeight.label,
                    fontSize: 16.sp,
                    bottom: 12.h,
                    text: 'Client Workout Plans',
                  ),
                ),
                CustomText(
                  text: '${plans.length} active',
                  fontSize: 12.sp,
                  color: AppColors.primary,
                  fontWeight: AppFontWeight.label,
                  bottom: 12.h,
                ),
              ],
            ),
            ...plans.map((plan) => _ClientPlanCard(plan: plan)),
          ],
        ),
      );
    });
  }
}

class _ClientPlanCard extends StatelessWidget {
  const _ClientPlanCard({required this.plan});
  final TrainerClientPlanModel plan;

  @override
  Widget build(BuildContext context) {
    final today = plan.todayDay;

    return CustomContainer(
      radiusAll: 12.r,
      paddingAll: 12.r,
      marginBottom: 10.h,
      bordersColor: AppColors.colorE6E6E6,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          CustomContainer(
            radiusAll: 24.r,
            width: 44.w,
            height: 44.h,
            color: AppColors.primary.withOpacity(0.12),
            child: plan.client.profilePicture != null &&
                    (plan.client.profilePicture!).isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(24.r),
                    child: Image.network(
                      plan.client.profilePicture!,
                      width: 44.w,
                      height: 44.h,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _initials(plan.client.displayName),
                    ),
                  )
                : _initials(plan.client.displayName),
          ),
          SizedBox(width: 12.w),

          // Name + today's focus
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: plan.client.displayName,
                  fontSize: 14.sp,
                  fontWeight: AppFontWeight.section,
                  textAlign: TextAlign.start,
                ),
                if (today != null) ...[
                  SizedBox(height: 2.h),
                  CustomText(
                    text: today.focus,
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                    textAlign: TextAlign.start,
                  ),
                ],
              ],
            ),
          ),

          // Today's exercise count pill
          if (today != null && today.exerciseCount > 0)
            CustomContainer(
              radiusAll: 20.r,
              paddingHorizontal: 10.w,
              paddingVertical: 5.h,
              color: AppColors.primary.withOpacity(0.10),
              child: CustomText(
                text: '${today.exerciseCount} exercises',
                fontSize: 11.sp,
                color: AppColors.primary,
                fontWeight: AppFontWeight.section,
              ),
            ),
        ],
      ),
    );
  }

  Widget _initials(String name) {
    final parts = name.split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : name.isNotEmpty
            ? name[0].toUpperCase()
            : '?';
    return Center(
      child: CustomText(
        text: initials,
        fontSize: 16.sp,
        fontWeight: AppFontWeight.section,
        color: AppColors.primary,
      ),
    );
  }
}
