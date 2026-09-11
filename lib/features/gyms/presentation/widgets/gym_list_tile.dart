import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:pler_to_pler_app/core/services/tenant_brand_service.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_gym_model.dart';
import 'package:pler_to_pler_app/features/gyms/data/services/enterprise_service.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/screens/gym_login_preview_screen.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/widgets/gym_brand_logo.dart';

class GymListTile extends StatelessWidget {
  final EnterpriseGymModel gym;
  const GymListTile({super.key, required this.gym});

  bool _isCurrentGym(EnterpriseGymModel gym) {
    final cachedTenantId = CacheService().get<String>('tenantId');
    final activeTenantId = EnterpriseService.instance.active.value?.tenant.id;
    final activeBrandTenantId = TenantBrandService.to.activeBrand?.tenantId;
    final currentTenantId =
        activeTenantId ?? cachedTenantId ?? activeBrandTenantId;

    if (currentTenantId != null && currentTenantId.isNotEmpty) {
      return gym.tenantId == currentTenantId || gym.id == currentTenantId;
    }
    return gym.isOwnGym;
  }

  @override
  Widget build(BuildContext context) {
    final isCurrent = _isCurrentGym(gym);

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Row(
          children: [
            GymBrandLogo(
              gym: gym,
              size: 52.r,
              borderRadius: 13.r,
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
                      if (gym.isOwnGym || isCurrent)
                        Container(
                          margin: EdgeInsets.only(left: 6.w),
                          padding: EdgeInsets.symmetric(
                              horizontal: 7.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text('Your Gym',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.w500)),
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
                      if (gym.rating > 0) ...[
                        Icon(Icons.star_rounded,
                            size: 11.sp,
                            color: const Color(0xFFFFAB00)),
                        SizedBox(width: 2.w),
                        Text(gym.rating.toStringAsFixed(1),
                            style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.black54,
                                fontWeight: FontWeight.w400)),
                      ] else
                        Flexible(
                          child: Text(
                            'New partner',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: gym.accentColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          '· ${gym.memberCount}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 10.sp, color: Colors.black38),
                        ),
                      ),
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
                              fontWeight: FontWeight.w400)),
                    ],
                  ),
                  SizedBox(height: 6.h),
                ],
                isCurrent
                    ? Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                              color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded,
                                size: 13.sp,
                                color: const Color(0xFF10B981)),
                            SizedBox(width: 4.w),
                            Text(
                              'Current Gym',
                              style: TextStyle(
                                color: const Color(0xFF374151),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : gym.isActivated
                        ? GestureDetector(
                            onTap: () => GymLoginPreviewScreen.open(
                              context,
                              gym: gym,
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                'Login / Signup',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
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
                                    gym.statusLabel,
                                    style: TextStyle(
                                      color: Colors.black38,
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w500,
                                      height: 1.25,
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
