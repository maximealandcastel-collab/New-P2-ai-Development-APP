import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_gym_model.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/screens/gym_login_preview_screen.dart';

class GymListTile extends StatelessWidget {
  final EnterpriseGymModel gym;
  const GymListTile({super.key, required this.gym});

  static const _kOrange = Color(0xFFFD7B00);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Row(
          children: [
            // LEFT — logo
            Container(
              width: 52.r,
              height: 52.r,
              decoration: BoxDecoration(
                color: gym.brandColor,
                borderRadius: BorderRadius.circular(13.r),
                boxShadow: [
                  BoxShadow(
                    color: gym.brandColor.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
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
                  fontSize: gym.initials.length > 2 ? 12.sp : 16.sp,
                  fontWeight: AppFontWeight.display,
                ),
              ),
            ),

            SizedBox(width: 12.w),

            // CENTER — info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          gym.name,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (gym.isOwnGym)
                        Container(
                          margin: EdgeInsets.only(left: 6.w),
                          padding: EdgeInsets.symmetric(
                              horizontal: 7.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: _kOrange.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text('YOUR GYM',
                              style: TextStyle(
                                  color: _kOrange,
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                        gym.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.black45,
                        ),
                      ),
                  SizedBox(height: 5.h),
                  Row(
                    children: [
                      Icon(Icons.star_rounded,
                          size: 11.sp,
                          color: const Color(0xFFFFAB00)),
                      SizedBox(width: 2.w),
                      Text(gym.rating.toStringAsFixed(1),
                          style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.black54,
                              fontWeight: AppFontWeight.label)),
                      SizedBox(width: 6.w),
                      Text('· ${gym.memberCount}',
                          style: TextStyle(
                              fontSize: 10.sp, color: Colors.black38)),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: 10.w),

            // RIGHT — distance + button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (gym.distanceMi != null) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 11.sp, color: Colors.black38),
                      SizedBox(width: 2.w),
                      Text(gym.distanceLabel,
                          style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.black45,
                              fontWeight: AppFontWeight.body)),
                    ],
                  ),
                  SizedBox(height: 8.h),
                ],
                gym.isActivated
                    ? GestureDetector(
                        onTap: () =>
                            Get.to(() => GymLoginPreviewScreen(gym: gym)),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: _kOrange,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            'Login / Signup',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: AppFontWeight.label,
                            ),
                          ),
                        ),
                      )
                    : Container(
                            constraints: BoxConstraints(maxWidth: 116.w),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 7.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8E8E8),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_outline_rounded,
                                size: 10.sp, color: Colors.black38),
                            SizedBox(width: 4.w),
                            Flexible(
                              child: Text(
                                gym.statusLabel ?? 'Coming Soon',
                                style: TextStyle(
                                  color: Colors.black38,
                                  fontSize: 10.sp,
                                  fontWeight: AppFontWeight.emphasis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
