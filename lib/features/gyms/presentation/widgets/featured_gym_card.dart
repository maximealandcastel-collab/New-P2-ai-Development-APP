import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:pler_to_pler_app/core/services/tenant_brand_service.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_gym_model.dart';
import 'package:pler_to_pler_app/features/gyms/data/services/enterprise_service.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/widgets/gym_brand_logo.dart';

class FeaturedGymCard extends StatelessWidget {
  const FeaturedGymCard({
    super.key,
    required this.gym,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  final EnterpriseGymModel gym;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

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
    final primary = Theme.of(context).colorScheme.primary;
    final isCurrent = _isCurrentGym;

    return Container(
      width: 158.w,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: const Color(0xFFEDEEF1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              _FeaturedPhoto(gym: gym),
              Positioned(
                top: 8.h,
                right: 8.w,
                child: _PartnershipBadge(
                  label: isCurrent
                      ? 'Your gym'
                      : gym.isActivated
                          ? 'Partner'
                          : 'Targeted',
                  active: isCurrent || gym.isActivated,
                ),
              ),
              Positioned(
                left: 10.w,
                bottom: -16.r,
                child: GymBrandLogo(
                  gym: gym,
                  size: 36.r,
                  borderRadius: 9.r,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(10.w, 20.h, 10.w, 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        gym.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF171820),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      key: const ValueKey('featured-gym-open-icon'),
                      size: 14.sp,
                      color: primary,
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  gym.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: const Color(0xFF7A7C87),
                  ),
                ),
                SizedBox(height: 5.h),
                Row(
                  children: [
                    if (gym.rating > 0) ...[
                      Icon(Icons.star_rounded,
                          size: 11.sp, color: const Color(0xFFFFB000)),
                      SizedBox(width: 2.w),
                      Text(
                        gym.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF555762),
                        ),
                      ),
                    ],
                    if (gym.rating > 0 && gym.memberCount.isNotEmpty)
                      Text('  ·  ',
                          style: TextStyle(
                              fontSize: 8.sp, color: Colors.black26)),
                    if (gym.memberCount.isNotEmpty)
                      Expanded(
                        child: Text(
                          gym.memberCount,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 8.5.sp,
                            color: const Color(0xFF8A8C95),
                          ),
                        ),
                      ),
                  ],
                ),
                if (gym.distanceMi != null) ...[
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 10.sp, color: primary),
                      SizedBox(width: 2.w),
                      Text(
                        gym.distanceLabel,
                        style: TextStyle(
                          fontSize: 8.5.sp,
                          color: const Color(0xFF7A7C87),
                        ),
                      ),
                      const Spacer(),
                      _FavoriteButton(
                        selected: isFavorite,
                        onTap: onFavoriteToggle,
                      ),
                    ],
                  ),
                ] else
                  Align(
                    alignment: Alignment.centerRight,
                    child: _FavoriteButton(
                      selected: isFavorite,
                      onTap: onFavoriteToggle,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedPhoto extends StatelessWidget {
  const _FeaturedPhoto({required this.gym});

  final EnterpriseGymModel gym;

  @override
  Widget build(BuildContext context) {
    if (gym.stockPhotoAssetPath.isEmpty) {
      return Container(
        height: 96.h,
        width: double.infinity,
        color: gym.brandColor.withValues(alpha: 0.10),
        alignment: Alignment.center,
        child: Icon(
          Icons.fitness_center_rounded,
          size: 23.sp,
          color: gym.brandColor.withValues(alpha: 0.55),
        ),
      );
    }
    return GymStockImage(
      gym: gym,
      height: 96.h,
      width: double.infinity,
      showLogo: false,
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.selected, this.onTap});

  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Semantics(
      button: true,
      selected: selected,
      label: selected ? 'Remove gym from favorites' : 'Add gym to favorites',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(3.r),
          child: Icon(
            selected ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 16.sp,
            color: selected ? primary : const Color(0xFF757985),
          ),
        ),
      ),
    );
  }
}

class _PartnershipBadge extends StatelessWidget {
  const _PartnershipBadge({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFEAF8EF) : const Color(0xFFF2F4F3),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8.5.sp,
          fontWeight: FontWeight.w500,
          color: active ? const Color(0xFF287A46) : const Color(0xFF666A72),
        ),
      ),
    );
  }
}
