import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'tenant_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_gym_model.dart';

class GymBrandLogo extends StatelessWidget {
  final EnterpriseGymModel gym;
  final double size;
  final double borderRadius;

  const GymBrandLogo({
    super.key,
    required this.gym,
    required this.size,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: gym.brandColor.withOpacity(0.18),
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius * 0.72),
        child: TenantImage(
          gym.logoAssetPath.isNotEmpty ? gym.logoAssetPath : gym.logoUrl,
          fit: BoxFit.contain,
        ),
      ),
    );
  }


}

/// Displays a facility-provided photo when available, then a bundled catalog
/// photo. Never labels a generic catalog image as a specific location photo.
class GymStockImage extends StatelessWidget {
  final EnterpriseGymModel gym;
  final double height;
  final double width;
  final double borderRadius;
  final bool showLogo;

  const GymStockImage({
    super.key,
    required this.gym,
    required this.height,
    required this.width,
    this.borderRadius = 0,
    this.showLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: gym.facilityPhotoDescription,
      child: SizedBox(
        height: height,
        width: width,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _photo(gym.stockPhotoAssetPath, allowBundledFallback: true),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.04),
                      Colors.black.withOpacity(0.24),
                    ],
                  ),
                ),
              ),
              if (showLogo)
                Positioned(
                  right: 12.w,
                  bottom: 12.h,
                  child: GymBrandLogo(
                    gym: gym,
                    size: 54.r,
                    borderRadius: 14.r,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photo(String source, {required bool allowBundledFallback}) {
    final bundled = gym.bundledPhotoAssetPath;
    Widget fallback() => allowBundledFallback && bundled.isNotEmpty && source != bundled
        ? _photo(bundled, allowBundledFallback: false)
        : _fallback();

    if (source.startsWith('https://') || source.startsWith('http://')) {
      return Image.network(
        source,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, __, ___) => fallback(),
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : fallback(),
      );
    }
    if (source.startsWith('assets/')) {
      return Image.asset(
        source,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback(),
      );
    }
    return fallback();
  }

  Widget _fallback() {
    return ColoredBox(
      color: gym.brandColor.withOpacity(0.14),
      child: Center(
        child: Text(
          gym.initials,
          style: TextStyle(
            color: gym.brandColor,
            fontSize: 28.sp,
            fontWeight: AppFontWeight.section,
          ),
        ),
      ),
    );
  }
}
