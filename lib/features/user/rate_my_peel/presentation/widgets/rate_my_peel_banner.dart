import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/features/user/rate_my_peel/presentation/rate_my_peel_screen.dart';

class RateMyPeelBanner extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  final bool compact;

  const RateMyPeelBanner({
    super.key,
    this.margin,
    this.compact = false,
  });

  static const String _assetPath = 'assets/images/rate_my_peel_banner.jpg';
  static const String _compactAssetPath =
      'assets/images/rate_my_peel_trainer_banner.jpg';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Rate My Peel',
      hint: 'Visual body analysis. Real progress.',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RateMyPeelScreen()),
        ),
        child: Container(
          margin: margin ?? EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: const Color(0xFF090909),
            borderRadius: BorderRadius.circular(compact ? 14.r : 16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(compact ? 14.r : 16.r),
            child: AspectRatio(
              aspectRatio: compact ? 1536 / 539 : 1.22,
              child: Image.asset(
                compact ? _compactAssetPath : _assetPath,
                fit: compact ? BoxFit.contain : BoxFit.cover,
                alignment: Alignment.center,
                filterQuality: FilterQuality.high,
                gaplessPlayback: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
