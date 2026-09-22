import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_gym_model.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/widgets/gym_brand_logo.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/widgets/tenant_image.dart';

class GymDetailScreen extends StatelessWidget {
  const GymDetailScreen({
    super.key,
    required this.gym,
    required this.onOpenMaps,
    required this.onClaim,
    required this.onEnter,
  });

  final EnterpriseGymModel gym;
  final VoidCallback onOpenMaps;
  final VoidCallback onClaim;
  final VoidCallback onEnter;

  bool get _hasLocation => gym.address.isNotEmpty || gym.city.isNotEmpty;
  bool get _hasHero =>
      gym.imageAssetPath.isNotEmpty || gym.imageUrl.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final active = gym.isActivated;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F9),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
              title: Text(
                gym.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF171820),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_hasHero)
                    TenantImage(
                      gym.imageAssetPath.isNotEmpty
                          ? gym.imageAssetPath
                          : gym.imageUrl,
                      height: 205.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 30.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GymBrandLogo(
                              gym: gym,
                              size: 58.r,
                              borderRadius: 14.r,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    gym.name,
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF171820),
                                    ),
                                  ),
                                  SizedBox(height: 3.h),
                                  Text(
                                    gym.category,
                                    style: TextStyle(
                                      fontSize: 11.5.sp,
                                      color: const Color(0xFF747680),
                                    ),
                                  ),
                                  SizedBox(height: 7.h),
                                  _MetadataRow(gym: gym),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (_hasLocation) ...[
                          SizedBox(height: 18.h),
                          _InfoCard(
                            icon: Icons.location_on_outlined,
                            title: gym.address.isNotEmpty
                                ? gym.address
                                : gym.city,
                            actionLabel: 'Directions',
                            onTap: onOpenMaps,
                          ),
                        ],
                        if (gym.tagline.isNotEmpty) ...[
                          SizedBox(height: 22.h),
                          _SectionTitle('About'),
                          SizedBox(height: 7.h),
                          Text(
                            gym.tagline,
                            style: TextStyle(
                              fontSize: 12.sp,
                              height: 1.45,
                              color: const Color(0xFF646670),
                            ),
                          ),
                        ],
                        if (gym.filterTags.isNotEmpty) ...[
                          SizedBox(height: 22.h),
                          _SectionTitle('Amenities & training'),
                          SizedBox(height: 9.h),
                          Wrap(
                            spacing: 7.w,
                            runSpacing: 7.h,
                            children: gym.filterTags
                                .map(
                                  (tag) => Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20.r),
                                      border: Border.all(
                                        color: const Color(0xFFE6E7EA),
                                      ),
                                    ),
                                    child: Text(
                                      tag,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: const Color(0xFF5F616B),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                        if (gym.galleryAssetPaths.isNotEmpty) ...[
                          SizedBox(height: 22.h),
                          _SectionTitle('Photos'),
                          SizedBox(height: 10.h),
                          SizedBox(
                            height: 108.h,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: gym.galleryAssetPaths.length,
                              separatorBuilder: (_, __) => SizedBox(width: 8.w),
                              itemBuilder: (_, index) => ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: TenantImage(
                                  gym.galleryAssetPaths[index],
                                  width: 152.w,
                                  height: 108.h,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: 22.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(13.r),
                          decoration: BoxDecoration(
                            color: active
                                ? const Color(0xFFEAF8EF)
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(13.r),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                active
                                    ? Icons.verified_outlined
                                    : Icons.lock_outline_rounded,
                                size: 16.sp,
                                color: active
                                    ? const Color(0xFF287A46)
                                    : const Color(0xFF777983),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  active ? 'Active P2P partner' : gym.statusLabel,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    height: 1.35,
                                    color: active
                                        ? const Color(0xFF287A46)
                                        : const Color(0xFF696B75),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 14.h),
                        SizedBox(
                          width: double.infinity,
                          height: 46.h,
                          child: FilledButton(
                            onPressed: active ? onEnter : onClaim,
                            style: FilledButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.r),
                              ),
                            ),
                            child: Text(
                              active ? 'Continue with ${gym.name}' : 'Claim this gym',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF171820),
        ),
      );
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({required this.gym});
  final EnterpriseGymModel gym;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    if (gym.rating > 0) {
      items.addAll([
        Icon(Icons.star_rounded, size: 13.sp, color: const Color(0xFFFFB000)),
        SizedBox(width: 2.w),
        Text(gym.rating.toStringAsFixed(1)),
      ]);
    }
    if (gym.memberCount.isNotEmpty) {
      if (items.isNotEmpty) items.add(const Text('  ·  '));
      items.add(Flexible(
        child: Text(gym.memberCount,
            maxLines: 1, overflow: TextOverflow.ellipsis),
      ));
    }
    if (gym.distanceMi != null) {
      if (items.isNotEmpty) items.add(const Text('  ·  '));
      items.add(Text(gym.distanceLabel));
    }
    return DefaultTextStyle(
      style: TextStyle(fontSize: 10.sp, color: const Color(0xFF747680)),
      child: Row(children: items),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.actionLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFEDEEF1)),
            borderRadius: BorderRadius.circular(13.r),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18.sp, color: primary),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    color: const Color(0xFF5F616B),
                  ),
                ),
              ),
              Text(
                actionLabel,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w600,
                  color: primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
