import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/dialog_show_helper.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/find_trainer_model.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/controllers/subscribe_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class FindTrainerCard extends StatelessWidget {
  final FindTrainerModel? trainer;

  const FindTrainerCard({super.key, this.trainer});

  @override
  Widget build(BuildContext context) {
    final controller = SubscribeController.to;

    // Prefer the trainer's dedicated headshot; fall back to user avatar
    final photoUrl =
        (trainer?.profileImage?.isNotEmpty == true)
            ? trainer!.profileImage!
            : (trainer?.userId?.profilePicture ?? '');

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoute.trainerProfileScreen,
        arguments: trainer?.sId ?? '',
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          children: [
            // ── Full-bleed photo ──────────────────────────────────────────
            Positioned.fill(
              child: photoUrl.isNotEmpty
                  ? Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),

            // ── Gradient overlay ─────────────────────────────────────────
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.05),
                      Colors.black.withOpacity(0.70),
                      Colors.black.withOpacity(0.92),
                    ],
                    stops: const [0.0, 0.38, 0.72, 1.0],
                  ),
                ),
              ),
            ),

            // ── Text + action ─────────────────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name
                    Text(
                      trainer?.name ?? trainer?.userId?.fullName ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 3.h),

                    // Specialty
                    Text(
                      StringFormat.formatSpecialty(trainer?.specialty ?? ''),
                      style: TextStyle(
                        color: const Color(0xFFE8A030),
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Top 2 certifications
                    if ((trainer?.certifications ?? []).isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      ...(trainer!.certifications!.take(2).map(
                        (c) => Text(
                          c,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 9.sp,
                            height: 1.4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                    ],

                    SizedBox(height: 10.h),

                    // Request pill button
                    GestureDetector(
                      onTap: () => _showRequestSheet(context, controller),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.35),
                          ),
                        ),
                        child: Text(
                          'Request',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: const Color(0xFF1E1E1E),
        child: Center(
          child: Icon(
            Icons.person,
            color: Colors.white30,
            size: 40.sp,
          ),
        ),
      );

  void _showRequestSheet(
    BuildContext context,
    SubscribeController controller,
  ) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      elevation: 2,
      context: context,
      builder: (context) {
        return Obx(
          () => DialogShowHelper.showBottomSheet(
            context,
            title: 'Trainer request',
            content: CustomTextField(
              controller: controller.noteTEController,
              contentPaddingVertical: 10.h,
              labelText: 'Note :',
              hintText: 'Write a short message ',
              maxLines: 5,
              minLines: 5,
            ),
            buttonLabel: 'Request trainer',
            isLoading: controller.requestLoadingState.isLoading,
            onTapConfirm: () =>
                controller.requestTrainer(trainer?.sId ?? ''),
          ),
        );
      },
    );
  }
}
