import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_gym_model.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/screens/gym_login_preview_screen.dart';

class EnterpriseGymCard extends StatelessWidget {
  final EnterpriseGymModel gym;
  const EnterpriseGymCard({super.key, required this.gym});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Logo area with active badge ──────────────────────────────
          Padding(
            padding: EdgeInsets.all(14.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App icon
                Container(
                  width: 54.r,
                  height: 54.r,
                  decoration: BoxDecoration(
                    color: gym.brandColor,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: gym.brandColor.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    gym.initials,
                    style: TextStyle(
                      color: gym.textColor == Colors.white
                          ? Colors.white
                          : gym.accentColor,
                      fontSize: gym.initials.length > 2 ? 13.sp : 17.sp,
                      fontWeight: AppFontWeight.display,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),

                // Second mini icon strip
                SizedBox(width: 6.w),
                Container(
                  width: 28.r,
                  height: 28.r,
                  decoration: BoxDecoration(
                    color: gym.accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    gym.initials.length > 1
                        ? gym.initials[gym.initials.length - 1]
                        : gym.initials,
                    style: TextStyle(
                      color: gym.brandColor,
                      fontSize: 10.sp,
                      fontWeight: AppFontWeight.display,
                    ),
                  ),
                ),

                const Spacer(),

                // Active badge
                if (gym.isActive)
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5.r,
                          height: 5.r,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00C853),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text('active',
                            style: TextStyle(
                                color: const Color(0xFF2E7D32),
                                fontSize: 10.sp,
                                fontWeight: AppFontWeight.label)),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // ── Gym info ─────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gym.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: AppFontWeight.title,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  '${gym.category} · ${gym.memberCount}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.black45,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          // ── Preview button ───────────────────────────────────────────
          Padding(
            padding:
                EdgeInsets.only(left: 14.w, right: 14.w, bottom: 14.h),
            child: GestureDetector(
              onTap: () => Get.to(() => GymLoginPreviewScreen(gym: gym)),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: gym.brandColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Preview Login + Demo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: AppFontWeight.label,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 14.sp),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
