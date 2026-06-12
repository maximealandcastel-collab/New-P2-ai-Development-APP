import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:confetti/confetti.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';

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
                  label: 'Go to home',
                  onPressed: () {
                    Get.toNamed(AppRoute.userButtonNavBar);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
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