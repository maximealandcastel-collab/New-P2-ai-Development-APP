import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/phone_otp_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class PhoneOtpWaitingScreen extends StatelessWidget {
  const PhoneOtpWaitingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = PhoneOtpController.to;

    return CustomScaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Icon ─────────────────────────────────────────
            Container(
              width: 96.w,
              height: 96.w,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.sms_outlined,
                size: 48.sp,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 32.h),

            // ── Headline ──────────────────────────────────────
            CustomText(
              text: 'Check Your Texts',
              fontSize: 24.sp,
              fontWeight: AppFontWeight.section,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),

            // ── Subtext with phone ────────────────────────────
            Obx(() => CustomText(
              text:
                  'We sent a text to\n${ctrl.phone.isEmpty ? 'your number' : ctrl.phone}',
              fontSize: 15.sp,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            )),
            SizedBox(height: 24.h),

            // ── Instruction card ──────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
                ),
              ),
              child: Column(
                children: [
                  _Step(
                    number: '1',
                    text: 'Open your Messages app',
                  ),
                  SizedBox(height: 12.h),
                  _Step(
                    number: '2',
                    text: 'Reply to the text from P2P FitTech AI',
                  ),
                  SizedBox(height: 12.h),
                  _Step(
                    number: '3',
                    text: 'Type  CONFIRM  and send it',
                    highlight: 'CONFIRM',
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // ── Waiting indicator / verified badge ────────────
            Obx(() {
              if (ctrl.isVerified) {
                return Column(
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.green, size: 48.sp),
                    SizedBox(height: 8.h),
                    CustomText(
                      text: 'Verified! Taking you in…',
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  SizedBox(
                    width: 28.w,
                    height: 28.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  CustomText(
                    text: 'Waiting for your reply…',
                    color: AppColors.textSecondary,
                    fontSize: 13.sp,
                  ),
                ],
              );
            }),

            SizedBox(height: 40.h),

            // ── Resend button ─────────────────────────────────
            Obx(() => TextButton(
              onPressed: ctrl.isSending ? null : ctrl.resend,
              child: CustomText(
                text: ctrl.isSending ? 'Sending…' : 'Resend text',
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            )),
          ],
        ),
      ),
    );
  }
}

// ── Small helper widget ───────────────────────────────────────────────────────
class _Step extends StatelessWidget {
  final String number;
  final String text;
  final String? highlight;

  const _Step({
    required this.number,
    required this.text,
    this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26.w,
          height: 26.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: AppFontWeight.section,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: highlight == null
              ? CustomText(text: text, fontSize: 14.sp)
              : RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                    ),
                    children: _buildSpans(context, text, highlight!),
                  ),
                ),
        ),
      ],
    );
  }

  List<TextSpan> _buildSpans(BuildContext context, String text, String highlight) {
    final parts = text.split(highlight);
    if (parts.length < 2) return [TextSpan(text: text)];
    return [
      TextSpan(text: parts[0]),
      TextSpan(
        text: highlight,
        style: TextStyle(
          fontWeight: AppFontWeight.title,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.5,
        ),
      ),
      TextSpan(text: parts[1]),
    ];
  }
}
