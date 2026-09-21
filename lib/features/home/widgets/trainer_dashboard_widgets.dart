import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pler_to_pler_app/core/themes/app_typography.dart';

/// Native, responsive building blocks for the Trainer/Admin home dashboard.
/// These widgets intentionally contain no data fetching or navigation logic.
class OverviewStatCard extends StatelessWidget {
  const OverviewStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.assetIcon,
    this.icon,
  }) : assert(assetIcon != null || icon != null);

  final String label;
  final String value;
  final VoidCallback onTap;
  final String? assetIcon;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return _DashboardSurface(
      onTap: onTap,
      semanticLabel: '$label, $value',
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 11.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DashboardIcon(assetIcon: assetIcon, icon: icon, size: 20.r),
          SizedBox(height: 12.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF737780),
              fontSize: 11.sp,
              height: 1.12,
              fontWeight: AppFontWeight.body,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              color: const Color(0xFF17181B),
              fontSize: 23.sp,
              height: 1,
              fontWeight: AppFontWeight.emphasis,
              letterSpacing: -0.45,
            ),
          ),
        ],
      ),
    );
  }
}

class AssignmentCard extends StatelessWidget {
  const AssignmentCard({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.onAdd,
    this.assetIcon,
    this.icon,
  }) : assert(assetIcon != null || icon != null);

  final String label;
  final String value;
  final VoidCallback onTap;
  final VoidCallback? onAdd;
  final String? assetIcon;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final orange = Theme.of(context).colorScheme.primary;
    return _DashboardSurface(
      onTap: onTap,
      semanticLabel: '$label, $value',
      padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _DashboardIcon(assetIcon: assetIcon, icon: icon, size: 19.r),
              if (onAdd != null)
                Semantics(
                  button: true,
                  label: 'Add $label',
                  child: Material(
                    color: orange,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onAdd,
                      child: SizedBox(
                        width: 25.r,
                        height: 25.r,
                        child: Icon(Icons.add_rounded,
                            size: 17.r, color: Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF737780),
              fontSize: 10.5.sp,
              height: 1.15,
              fontWeight: AppFontWeight.body,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: const Color(0xFF17181B),
              fontSize: 21.sp,
              height: 1,
              fontWeight: AppFontWeight.emphasis,
              letterSpacing: -0.35,
            ),
          ),
        ],
      ),
    );
  }
}

class TrainerAlertCard extends StatelessWidget {
  const TrainerAlertCard({super.key, required this.onHide});

  final VoidCallback onHide;

  static const _red = Color(0xFFD93420);
  static const _deepRed = Color(0xFF9F1B17);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label:
          'Attention trainers. Keep your physique in optimal shape and track your training.',
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(11.w, 11.h, 10.w, 9.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7F6),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _red.withOpacity(0.24)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34.r,
              height: 34.r,
              decoration: BoxDecoration(
                color: _red.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.priority_high_rounded,
                  size: 20.r, color: _red),
            ),
            SizedBox(width: 9.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'Attention Trainers',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.sp,
                            height: 1.1,
                            fontWeight: AppFontWeight.label,
                            color: _deepRed,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 7.w, vertical: 3.5.h),
                        decoration: BoxDecoration(
                          color: _red.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Text(
                          'STAY PREPARED',
                          style: TextStyle(
                            fontSize: 7.5.sp,
                            height: 1,
                            fontWeight: AppFontWeight.label,
                            letterSpacing: 0.2,
                            color: _deepRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    'Your physique should remain in optimal shape. Track your training, monitor body fat, and stay performance-ready. Body fat above 15% can reduce definition, conditioning, and overall presentation.',
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      height: 1.34,
                      fontWeight: AppFontWeight.body,
                      color: const Color(0xFF5D4B49),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: onHide,
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.fromLTRB(7.w, 5.h, 0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: _deepRed,
                      ),
                      icon: Icon(Icons.visibility_off_outlined, size: 12.r),
                      label: Text(
                        'Hide for now',
                        style: TextStyle(
                          fontSize: 9.5.sp,
                          fontWeight: AppFontWeight.label,
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
    );
  }
}

class _DashboardSurface extends StatelessWidget {
  const _DashboardSurface({
    required this.onTap,
    required this.semanticLabel,
    required this.padding,
    required this.child,
  });

  final VoidCallback onTap;
  final String semanticLabel;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: const Color(0xFFF8F8F9),
        borderRadius: BorderRadius.circular(13.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13.r),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13.r),
              border: Border.all(color: const Color(0xFFEDEEF0)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _DashboardIcon extends StatelessWidget {
  const _DashboardIcon({this.assetIcon, this.icon, required this.size});

  final String? assetIcon;
  final IconData? icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return Icon(icon, size: size, color: const Color(0xFF26272B));
    }
    return SvgPicture.asset(
      assetIcon!,
      height: size,
      width: size,
      colorFilter:
          const ColorFilter.mode(Color(0xFF26272B), BlendMode.srcIn),
    );
  }
}
