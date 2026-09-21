import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:pler_to_pler_app/features/user/rate_my_peel/presentation/rate_my_peel_screen.dart';

/// Native Flutter composition: copy, CTA, artwork, and interaction remain
/// independent. The artwork is only a cropped visual accent.
class RateMyPeelBanner extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  final bool compact;

  const RateMyPeelBanner({
    super.key,
    this.margin,
    this.compact = false,
  });

  static const String _artworkPath = 'assets/images/rate_my_peel_banner.jpg';
  static const _orange = Color(0xFFFF6508);

  void _openRateMyPeel(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RateMyPeelScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(compact ? 14.r : 16.r);
    return Semantics(
      button: true,
      label: 'Rate My Peel',
      hint: 'Open visual body analysis',
      child: Container(
        margin: margin ?? EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: const Color(0xFF0B0B0C),
          borderRadius: radius,
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.055),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openRateMyPeel(context),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bannerHeight = compact ? 104.h : 132.h;
                  return SizedBox(
                    height: bannerHeight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width:
                                constraints.maxWidth * (compact ? 0.47 : 0.50),
                            height: bannerHeight,
                            child: ClipRect(
                              child: OverflowBox(
                                alignment: Alignment.centerRight,
                                minWidth: constraints.maxWidth,
                                maxWidth: constraints.maxWidth,
                                minHeight: bannerHeight,
                                maxHeight: bannerHeight,
                                child: Image.asset(
                                  _artworkPath,
                                  width: constraints.maxWidth,
                                  height: bannerHeight,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.centerRight,
                                  filterQuality: FilterQuality.high,
                                  excludeFromSemantics: true,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(0xFF0B0B0C),
                                Color(0xFF0B0B0C),
                                Color(0xE80B0B0C),
                                Color(0x000B0B0C),
                              ],
                              stops: [0, 0.43, 0.62, 0.84],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            compact ? 12.w : 15.w,
                            compact ? 11.h : 14.h,
                            compact ? 10.w : 13.w,
                            compact ? 10.h : 13.h,
                          ),
                          child: Row(
                            children: [
                              _CameraMark(compact: compact),
                              SizedBox(width: compact ? 10.w : 12.w),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text.rich(
                                        TextSpan(
                                          children: [
                                            const TextSpan(text: 'RATE MY '),
                                            TextSpan(
                                              text: 'PEEL',
                                              style: const TextStyle(
                                                color: _orange,
                                              ),
                                            ),
                                          ],
                                        ),
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: compact ? 15.sp : 18.sp,
                                          height: 1,
                                          fontWeight: AppFontWeight.label,
                                          letterSpacing: -0.25,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                    Text(
                                      'Visual body analysis.\nReal progress.',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: const Color(0xFFE3E3E5),
                                        fontSize: compact ? 9.5.sp : 11.sp,
                                        height: 1.25,
                                        fontWeight: AppFontWeight.body,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              OutlinedButton(
                                onPressed: () => _openRateMyPeel(context),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: _orange,
                                    width: 1.2,
                                  ),
                                  minimumSize:
                                      Size(0, compact ? 35.h : 39.h),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: compact ? 11.w : 14.w,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999.r),
                                  ),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Scan Now',
                                      style: TextStyle(
                                        fontSize: compact ? 10.sp : 11.sp,
                                        fontWeight: AppFontWeight.label,
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: _orange,
                                      size: compact ? 15.r : 17.r,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CameraMark extends StatelessWidget {
  const _CameraMark({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 46.r : 56.r;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(compact ? 13.r : 16.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF7A16), Color(0xFFF04A00)],
        ),
      ),
      child: Icon(
        Icons.photo_camera_outlined,
        color: Colors.white,
        size: compact ? 27.r : 32.r,
      ),
    );
  }
}
