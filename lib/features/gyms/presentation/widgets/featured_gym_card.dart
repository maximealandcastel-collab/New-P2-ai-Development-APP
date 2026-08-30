import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_gym_model.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/screens/gym_login_preview_screen.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/widgets/gym_brand_logo.dart';

class FeaturedGymCard extends StatelessWidget {
  final EnterpriseGymModel gym;
  const FeaturedGymCard({super.key, required this.gym});

  static const _kOrange = Color(0xFFFD7B00);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top: logo + meta + badge ─────────────────────────────────
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GymBrandLogo(
                  gym: gym,
                  size: 48.r,
                  borderRadius: 12.r,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gym.name,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                            gym.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.black45,
                            ),
                          ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Icon(Icons.star_rounded,
                              size: 12.sp,
                              color: const Color(0xFFFFAB00)),
                          SizedBox(width: 2.w),
                          Text(gym.rating.toStringAsFixed(1),
                              style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500)),
                          SizedBox(width: 6.w),
                          Text('· ${gym.memberCount}',
                              style: TextStyle(
                                  fontSize: 10.sp, color: Colors.black38)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Badge
                    Padding(
                      padding: EdgeInsets.only(left: 12.w),
                      child: _badge(gym),
                    ),
              ],
            ),
          ),

          // ── Middle: facility image ───────────────────────────────────
          Stack(
            children: [
              ClipRRect(
                child: gym.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: gym.imageUrl,
                        height: 140.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _imageFallback(),
                      )
                    : _imageFallback(),
              ),
              // Distance chip over image
              if (gym.distanceMi != null)
                Positioned(
                  bottom: 8.h,
                  left: 10.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on_rounded,
                            color: Colors.white, size: 10.sp),
                        SizedBox(width: 3.w),
                        Text(gym.distanceLabel,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: AppFontWeight.body)),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // ── Bottom: Login / Signup button (locked if not yet activated) ─
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: gym.isActivated
                ? GestureDetector(
                    onTap: () =>
                        Get.to(() => GymLoginPreviewScreen(gym: gym)),
                    child: Container(
                      width: double.infinity,
                       height: 44.h,
                      decoration: BoxDecoration(
                        color: _kOrange,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Login / Signup',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                         fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F1F1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lock_outline_rounded,
                            size: 14.sp, color: Colors.black38),
                        SizedBox(width: 6.w),
                        Flexible(
                          child: Text(
                            gym.statusLabel,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black38,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _badge(EnterpriseGymModel gym) {
    if (gym.isOwnGym) {
      return Container(
        padding:
            EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFD7B00),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text('Your Gym',
            style: TextStyle(
                color: Colors.white,
                fontSize: 7.5.sp,
                fontWeight: FontWeight.w500)),
      );
    }
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text('Targeted',
          style: TextStyle(
              color: const Color(0xFF6B7280),
              fontSize: 7.5.sp,
              fontWeight: FontWeight.w500)),
    );
  }

  Widget _imageFallback() {
    return Container(
      height: 140.h,
      width: double.infinity,
      color: gym.brandColor.withOpacity(0.15),
      child: Icon(Icons.fitness_center_rounded,
          color: gym.brandColor.withOpacity(0.4), size: 40.sp),
    );
  }
}
