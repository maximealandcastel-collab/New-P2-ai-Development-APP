import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:confetti/confetti.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import 'package:pler_to_pler_app/features/nav_bar/presentation/screens/nav_bar.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

import '../../../../../custom_assets/assets.gen.dart';

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));

    // Start the confetti animation when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: CustomScaffold(
        body: Stack(
          children: [
            Column(
              children: [
                const Spacer(),
                Assets.images.success.image(height: 80.h, width: 80.w),
                SizedBox(height: 20.h),
                CustomText(
                  text: 'You are all set !',
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 10.h),
                CustomText(
                  left: 16.w,
                  right: 16.w,
                  text:
                  'Your can add or edit all details from your profile . Now find your trainer , Medical professional more from our app',
                  fontSize: 16.sp,
                  color: AppColors.textSecondary,
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                CustomButton(
                  label: 'Take me to home page',
                  onPressed: () {
                    Get.offAll(() => NavBar());
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),

            // Confetti widget - positioned at top center
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 100,

              ),
            ),
          ],
        ),
      ),
    );
  }
}