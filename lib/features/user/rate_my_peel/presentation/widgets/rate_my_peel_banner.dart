import 'package:pler_to_pler_app/core/themes/brand_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/constants/image_path.dart';
import 'package:pler_to_pler_app/features/user/rate_my_peel/presentation/rate_my_peel_screen.dart';
import 'package:pler_to_pler_app/core/services/tenant_brand_service.dart';

class RateMyPeelBanner extends StatelessWidget {
  final EdgeInsetsGeometry? margin;

  const RateMyPeelBanner({super.key, this.margin});

  @override
  Widget build(BuildContext context) {
    final tenant = TenantBrandService.to;
    final whiteLabeled = tenant.isWhiteLabeled;
    return Semantics(
      button: true,
      label: whiteLabeled
          ? 'Fitness Check-In. Coming soon.'
          : 'Rate My Peel. Coming soon.',
      hint: 'Opens the fitness check-in feature overview',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RateMyPeelScreen()),
        ),
        child: Container(
          margin: margin ?? EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: SizedBox(
              height: 132.h,
              child: whiteLabeled
                  ? _WhiteLabelCheckInBanner(
                      name: tenant.displayName,
                      color: tenant.primaryColor,
                    )
                  : Image.asset(
                      ImagePath.rateMyPeelBanner,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (context, error, stackTrace) =>
                          const _RateMyPeelAssetFallback(),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WhiteLabelCheckInBanner extends StatelessWidget {
  final String name;
  final Color color;

  const _WhiteLabelCheckInBanner({
    required this.name,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF101010),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Icon(Icons.camera_alt_outlined, color: color, size: 28.sp),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FITNESS CHECK-IN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$name · COMING SOON',
                  style: TextStyle(
                    color: color,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
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

class _RateMyPeelAssetFallback extends StatelessWidget {
  const _RateMyPeelAssetFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF101010),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            color: BrandColors.of(context).primary,
            size: 22,
          ),
          const SizedBox(width: 10),
          const Text(
            'Rate My Peel  ·  COMING SOON',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
