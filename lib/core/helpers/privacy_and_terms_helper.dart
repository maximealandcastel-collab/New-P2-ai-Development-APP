import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/privacy/presentation/screens/privacy_policy_all_screen.dart';

class PrivacyAndTermsHelper extends StatelessWidget {
  PrivacyAndTermsHelper({super.key});

  final TermsAgreementController _controller = Get.find<TermsAgreementController>();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Obx(
          () => Checkbox(
            value: _controller.isChecked.value,
            onChanged: _controller.toggleCheckbox,
            activeColor: AppColors.textPrimary,
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.textPrimary,
              ),
              children: [
                const TextSpan(text: 'I agree with '),
                TextSpan(
                  text: 'terms of services ',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Get.to(
                        () => const PrivacyPolicyAllScreen(),
                        arguments: {
                          'title': 'Terms of Service',
                          'key': 'terms',
                        },
                      );
                    },
                ),
                const TextSpan(text: 'and '),
                TextSpan(
                  text: 'privacy policy.',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Get.to(
                        () => const PrivacyPolicyAllScreen(),
                        arguments: {
                          'title': 'Privacy Policy',
                          'key': 'privacy',
                        },
                      );
                    },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class TermsAgreementController extends GetxController {
  var isChecked = false.obs;

  void toggleCheckbox(bool? value) {
    isChecked.value = value ?? false;
  }
}
