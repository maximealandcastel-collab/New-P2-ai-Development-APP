import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/services/tenant_brand_service.dart';
import 'package:pler_to_pler_app/features/gyms/data/services/enterprise_service.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/widgets/tenant_image.dart';

/// Shared placement for all gym builds; see docs/enterprise/HOME_BRANDING.md.
class HomeGymBrand extends StatelessWidget {
  const HomeGymBrand({super.key, this.trailing});

  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: EnterpriseService.instance.active,
      builder: (context, _, _) {
        final brand = TenantBrandService.to.activeBrand;
        if (brand == null) {
          if (trailing == null) return const SizedBox.shrink();
          return Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
            child: Align(alignment: Alignment.centerLeft, child: trailing),
          );
        }
        return Padding(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
          child: Row(
            children: [
              Semantics(
                image: true,
                label: '${brand.displayName} logo',
                child: Container(
                  width: (trailing == null ? 64 : 44).r,
                  height: (trailing == null ? 64 : 44).r,
                  padding: EdgeInsets.all(7.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: brand.primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: TenantImage(brand.logoAssetPath, fit: BoxFit.contain),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  brand.displayName,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: (trailing == null ? 18 : 14).sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: 10.w),
                Flexible(
                  flex: 2,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: trailing,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
