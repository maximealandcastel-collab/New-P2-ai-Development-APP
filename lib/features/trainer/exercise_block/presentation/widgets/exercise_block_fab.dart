import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/themes/p2p_design_tokens.dart';
import 'package:pler_to_pler_app/core/services/tenant_brand_service.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ExerciseBlockFab extends StatelessWidget {
  const ExerciseBlockFab({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final useAccent = !TenantBrandService.to.isWhiteLabeled;
    return CustomContainer(
      onTap: onPressed,
      color: useAccent ? null : Theme.of(context).colorScheme.primary,
      linearColors: useAccent ? P2PAccentPill.colors : null,
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      radiusAll: 100.r,
      paddingHorizontal: 20.w,
      paddingVertical: 14.h,
      bordersColor: useAccent ? P2PAccentPill.borderColor : null,
      borderWidth: useAccent ? 0.8 : 1,
      boxShadow: useAccent ? P2PAccentPill.glow : [
        BoxShadow(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20.sp),
          SizedBox(width: 8.w),
          CustomText(
            text: label,
            fontSize: 14.sp,
            fontWeight: AppFontWeight.label,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
