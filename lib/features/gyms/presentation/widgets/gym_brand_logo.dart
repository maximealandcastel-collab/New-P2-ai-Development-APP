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
        child: gym.isOwnGym
            ? Image.asset(
                'assets/images/app_icon.png',
                fit: BoxFit.contain,
              )
            : Image.network(
                gym.logoUrl,
                fit: BoxFit.contain,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) => _fallback(),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _fallback();
                },
              ),
      ),
    );
  }

  Widget _fallback() {
    return ColoredBox(
      color: gym.brandColor.withOpacity(0.10),
      child: Icon(
        Icons.fitness_center_rounded,
        color: gym.brandColor.withOpacity(0.65),
        size: size * 0.44,
      ),
    );
  }
}