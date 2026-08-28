import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/find_trainer_model.dart';

class FindTrainerCard extends StatelessWidget {
  final FindTrainerModel? trainer;
  const FindTrainerCard({super.key, this.trainer});

  @override
  Widget build(BuildContext context) {
    final photoUrl =
        (trainer?.profileImage?.isNotEmpty == true)
            ? trainer!.profileImage!
            : (trainer?.userId?.profilePicture ?? '');

    final specLabel = _specialtyLabel(trainer?.specialty ?? '');
    final certs     = trainer?.certifications ?? [];
    final name      = trainer?.name ?? trainer?.userId?.fullName ?? 'Trainer';

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoute.trainerProfileScreen, arguments: trainer?.sId ?? ''),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Full-bleed face photo ────────────────────────────────
            if (photoUrl.isNotEmpty)
              Image.network(
                photoUrl,
                fit: BoxFit.cover,
                // Top-center alignment so face is always visible
                alignment: Alignment.topCenter,
                errorBuilder: (_, __, ___) => _placeholder(name),
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : _shimmer(),
              )
            else
              _placeholder(name),

            // ── Gradient overlay (dark at bottom, clear at top) ──────
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.45, 0.75, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.55),
                      Colors.black.withOpacity(0.90),
                    ],
                  ),
                ),
              ),
            ),

            // ── Text + button ─────────────────────────────────────────
            Positioned(
              left: 10.w,
              right: 10.w,
              bottom: 10.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: AppFontWeight.title,
                      letterSpacing: -0.2,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Specialty pill
                  Text(
                    specLabel,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10.sp,
                      fontWeight: AppFontWeight.stat,
                    ),
                  ),
                  // Certifications (up to 2)
                  if (certs.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    ...certs.take(2).map((c) => Text(
                      c.length > 22 ? '${c.substring(0, 22)}…' : c,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 9.sp,
                        fontWeight: AppFontWeight.emphasis,
                      ),
                    )),
                  ],
                  SizedBox(height: 8.h),
                  // Book button
                  SizedBox(
                    width: double.infinity,
                    height: 30.h,
                    child: ElevatedButton(
                      onPressed: () =>
                          Get.toNamed(AppRoute.trainerProfileScreen, arguments: trainer?.sId ?? ''),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        'Book Trainer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: AppFontWeight.stat,
                          letterSpacing: 0.2,
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

  String _specialtyLabel(String s) {
    const map = {
      'muscle_gain':       'Muscle Gain',
      'weight_loss':       'Weight Loss',
      'maintain_physique': 'Abs & Physique',
      'boxing':            'Combat Sports',
      'nutrition':         'Cardio & Nutrition',
    };
    final words = s.replaceAll('_', ' ').split(' ');
    final cap = words.map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1)).join(' ');
    return map[s] ?? cap;
  }

  Widget _placeholder(String name) => Container(
    color: const Color(0xFF1A1A2E),
    child: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        CircleAvatar(
          radius: 28.r,
          backgroundColor: Colors.white10,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'T',
            style: TextStyle(fontSize: 24.sp, color: Colors.white60, fontWeight: AppFontWeight.display),
          ),
        ),
      ]),
    ),
  );

  Widget _shimmer() => Container(color: const Color(0xFF2A2A3E));
}
