import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/features/user/rate_my_peel/presentation/rate_my_peel_screen.dart';

class RateMyPeelBanner extends StatelessWidget {
  final EdgeInsetsGeometry? margin;

  const RateMyPeelBanner({super.key, this.margin});

  static const String _assetPath = 'assets/images/rate_my_peel_banner.jpg';

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
            child: AspectRatio(
              aspectRatio: 1.22,
              child: Image.asset(
                _assetPath,
                fit: BoxFit.cover,
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
