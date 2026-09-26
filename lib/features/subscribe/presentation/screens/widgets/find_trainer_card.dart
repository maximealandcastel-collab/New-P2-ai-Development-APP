import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
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

    void openProfile() => Get.toNamed(
          AppRoute.trainerProfileScreen,
          arguments: trainer?.sId ?? '',
        );

    return GestureDetector(
      onTap: openProfile,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
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
                    stops: const [0.0, 0.52, 0.76, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.42),
                      Colors.black.withOpacity(0.84),
                    ],
                  ),
                ),
              ),
            ),

            // ── Text + button ─────────────────────────────────────────
            Positioned(
              left: 9.w,
              right: 9.w,
              bottom: 9.h,
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
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Specialty pill
                  Text(
                    specLabel,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // Credentials remain supporting metadata.
                  if (certs.isNotEmpty) ...[
                    SizedBox(height: 3.h),
                    Text(
                      certs.take(2).join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 8.5.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                  SizedBox(height: 7.h),
                  // Book button
                  SizedBox(
                    width: double.infinity,
                    height: 29.h,
                    child: FilledButton(
                      onPressed: openProfile,
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Book Trainer',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 5.w),
                          Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 13.sp),
                        ],
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
