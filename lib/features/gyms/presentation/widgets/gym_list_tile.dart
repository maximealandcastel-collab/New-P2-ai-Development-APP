import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:pler_to_pler_app/core/services/tenant_brand_service.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_gym_model.dart';
import 'package:pler_to_pler_app/features/gyms/data/services/enterprise_service.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/widgets/gym_brand_logo.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/widgets/gym_brand_mesh.dart';

class GymListTile extends StatelessWidget {
  const GymListTile({super.key, required this.gym});

  final EnterpriseGymModel gym;

  bool get _isCurrentGym {
    final currentTenantId = EnterpriseService.instance.active.value?.tenant.id ??
        CacheService().get<String>('tenantId') ??
        TenantBrandService.to.activeBrand?.tenantId;
    if (currentTenantId != null && currentTenantId.isNotEmpty) {
      return gym.tenantId == currentTenantId || gym.id == currentTenantId;
    }
    return gym.isOwnGym;
  }

  @override
  Widget build(BuildContext context) {
    final isCurrent = _isCurrentGym;
    final status = isCurrent
        ? 'Current gym'
        : gym.isActivated
            ? 'P2P partner'
            : 'Targeted integration';

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: gym.brandColor.withOpacity(.10)),
        boxShadow: [GymBrandMesh.franchiseShadow(
          gym.brandColor, gym.accentColor)],
      ),
      child: Row(
        children: [
          GymBrandLogo(gym: gym, size: 46.r, borderRadius: 11.r),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gym.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF171820),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  gym.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5.sp,
                    color: const Color(0xFF747680),
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    if (gym.rating > 0) ...[
                      Icon(Icons.star_rounded,
                          size: 11.sp, color: const Color(0xFFFFB000)),
                      SizedBox(width: 2.w),
                      Text(
                        gym.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 9.5.sp,
                          color: const Color(0xFF5E606A),
                        ),
                      ),
                    ],
                    if (gym.rating > 0 && gym.memberCount.isNotEmpty)
                      Text('  ·  ',
                          style: TextStyle(
                              fontSize: 8.sp, color: Colors.black26)),
                    if (gym.memberCount.isNotEmpty)
                      Flexible(
                        child: Text(
                          gym.memberCount,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: const Color(0xFF8B8D96),
                          ),
                        ),
                      ),
                    if (gym.distanceMi != null) ...[
                      Text('  ·  ',
                          style: TextStyle(
                              fontSize: 8.sp, color: Colors.black26)),
                      Icon(Icons.location_on_outlined,
                          size: 10.sp, color: const Color(0xFF8B8D96)),
                      Text(
                        gym.distanceLabel,
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: const Color(0xFF8B8D96),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 7.w),
          Container(
            constraints: BoxConstraints(maxWidth: 82.w),
            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Color.lerp(Colors.white, gym.brandColor,
                  (isCurrent || gym.isActivated) ? .12 : .07),
              borderRadius: BorderRadius.circular(9.r),
              border: Border.all(color: gym.brandColor.withOpacity(.10)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCurrent || gym.isActivated
                      ? Icons.check_circle_outline_rounded
                      : Icons.lock_outline_rounded,
                  size: 10.sp,
                  color: isCurrent || gym.isActivated
                      ? GymBrandMesh.darkBrand(gym.brandColor)
                      : const Color(0xFF858791),
                ),
                SizedBox(width: 3.w),
                Flexible(
                  child: Text(
                    status,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 7.8.sp,
                      height: 1.16,
                      fontWeight: FontWeight.w500,
                      color: isCurrent || gym.isActivated
                          ? GymBrandMesh.darkBrand(gym.brandColor)
                          : const Color(0xFF777983),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 4.w),
          Icon(Icons.chevron_right_rounded,
              size: 18.sp, color: const Color(0xFF9698A0)),
        ],
      ),
    );
  }
}
