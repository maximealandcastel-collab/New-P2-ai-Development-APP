import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/paywall/controllers/paywall_controller.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/find_trainer_model.dart';

class FindTrainerCard extends StatelessWidget {
  final FindTrainerModel? trainer;

  const FindTrainerCard({super.key, this.trainer});

  @override
  Widget build(BuildContext context) {
    final photoUrl =
        (trainer?.profileImage?.isNotEmpty == true)
            ? trainer!.profileImage!
            : (trainer?.userId?.profilePicture ?? '');

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoute.trainerProfileScreen,
        arguments: trainer?.sId ?? '',
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          children: [
            // Full-bleed photo
            Positioned.fill(
              child: photoUrl.isNotEmpty
                  ? Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),

            // Gradient overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.05),
                      Colors.black.withOpacity(0.70),
                      Colors.black.withOpacity(0.92),
                    ],
                    stops: const [0.0, 0.38, 0.72, 1.0],
                  ),
                ),
              ),
            ),

            // Text + Book button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      trainer?.name ?? trainer?.userId?.fullName ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      StringFormat.formatSpecialty(trainer?.specialty ?? ''),
                      style: TextStyle(
                        color: const Color(0xFFE8A030),
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if ((trainer?.certifications ?? []).isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      ...(trainer!.certifications!.take(2).map(
                        (c) => Text(
                          c,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 9.sp,
                            height: 1.4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                    ],
                    SizedBox(height: 10.h),

                    // Book Trainer pill
                    GestureDetector(
                      onTap: () => _showBookSheet(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          'Book Trainer',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: const Color(0xFF1E1E1E),
        child: Center(
          child: Icon(Icons.person, color: Colors.white30, size: 40.sp),
        ),
      );

  void _showBookSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _BookTrainerSheet(
        trainerName: trainer?.name ?? trainer?.userId?.fullName ?? 'Trainer',
        photoUrl: (trainer?.profileImage?.isNotEmpty == true)
            ? trainer!.profileImage!
            : (trainer?.userId?.profilePicture ?? ''),
      ),
    );
  }
}

class _BookTrainerSheet extends StatelessWidget {
  final String trainerName;
  final String photoUrl;

  const _BookTrainerSheet({required this.trainerName, required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PaywallController>();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 36.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 20.h),

          // Trainer avatar + name
          photoUrl.isNotEmpty
              ? CircleAvatar(
                  radius: 36.r,
                  backgroundImage: NetworkImage(photoUrl),
                )
              : CircleAvatar(
                  radius: 36.r,
                  backgroundColor: AppColors.primary.withOpacity(0.15),
                  child: Icon(Icons.person, size: 36.sp, color: AppColors.primary),
                ),
          SizedBox(height: 12.h),
          Text(
            trainerName,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4.h),
          Text(
            'Personal Trainer',
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
          ),
          SizedBox(height: 24.h),

          // Price card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                  ctrl.monthlyPriceStr.value,
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                )),
                Text(
                  '/ month',
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
                ),
                SizedBox(height: 16.h),
                ...[
                  'AI-guided workout plans',
                  'Direct trainer messaging',
                  'Progress tracking & analytics',
                  'Cancel anytime',
                ].map((b) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: AppColors.primary, size: 16.r),
                      SizedBox(width: 8.w),
                      Text(b,
                          style: TextStyle(
                              fontSize: 13.sp, fontWeight: FontWeight.w500)),
                    ],
                  ),
                )),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Book button
          Obx(() => SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: ctrl.purchaseLoading.value
                  ? null
                  : () {
                      ctrl.selectPlan('monthly');
                      ctrl.upgradeNow();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: ctrl.purchaseLoading.value
                  ? SizedBox(
                      width: 22.w,
                      height: 22.h,
                      child: const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      'Book Trainer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          )),
          SizedBox(height: 8.h),
          Text(
            'Billed monthly · Cancel anytime',
            style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
