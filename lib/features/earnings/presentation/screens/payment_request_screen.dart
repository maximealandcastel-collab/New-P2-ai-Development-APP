import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/earnings/presentation/controllers/payment_request_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class PaymentRequestScreen extends StatelessWidget {
  const PaymentRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the controller
    final controller = PaymentRequestController.to;

    return SliverScaffold(
      appBar: const CustomSliverAppBar(title: 'Payment request'),
      bottomNavigationBar: CustomButton(
        onPressed: () {
          if (controller.formKey.currentState?.validate() ?? false) {
            showDialog(
              context: context,
              builder: (context) {
                return Obx(
                  () => CustomDialog(
                    title: 'Confirm Payment',
                    description: 'Are you sure you want to submit this payment request?',
                    titleColor: AppColors.primary,
                    rightButtonLabel: 'Confirm',
                    rightButtonBgColor: AppColors.primary,
                    isLoading: controller.requestState.isLoading,
                    onTapLeftButton: () => Get.back(),
                    onTapRightButton: () {
                      controller.submitWithdrawal();
                    },
                  ),
                );
              },
            );
          }
        },
        label: 'Save',
        backgroundColor: AppColors.primary,
        radius: 30.r,
      ),
      bodyList: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 40.h),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 3. Payment Method
                CustomText(
                  text: 'Payment method',
                  fontWeight: AppFontWeight.label,
                  fontSize: 14.sp,
                  color: AppColors.textPrimary,
                  bottom: 8.h,
                  top: 16.h,
                  textAlign: TextAlign.start,
                ),
                Obx(() {
                  final isStripeSelected =
                      controller.selectedMethod.value == 'stripe';
                  final isPaypalSelected =
                      controller.selectedMethod.value == 'paypal';

                  return Column(
                    children: [
                      // Stripe Selectable Card
                      _buildMethodCard(
                        label: 'Stripe',
                        isSelected: isStripeSelected,
                        onTap: () => controller.selectMethod('stripe'),
                        icon: Container(
                          width: 32.r,
                          height: 32.r,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF635BFF),
                            // Stripe blue/purple brand color
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: CustomText(
                            text: 'S',
                            color: Colors.white,
                            fontWeight: AppFontWeight.display,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),

                      // PayPal Selectable Card
                      _buildMethodCard(
                        label: 'Paypal',
                        isSelected: isPaypalSelected,
                        onTap: () => controller.selectMethod('paypal'),
                        icon: Container(
                          width: 32.r,
                          height: 32.r,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF003087),
                            // PayPal dark blue brand color
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: CustomText(
                            text: 'P',
                            color: Colors.white,
                            fontWeight: AppFontWeight.display,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ],
                  );
                }),

                // 4. Conditional Field based on selected method
                Obx(() {
                  final method = controller.selectedMethod.value;
                  final isStripe = method == 'stripe';

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      key: ValueKey(method),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          labelColor: AppColors.textPrimary,
                          labelText: isStripe
                              ? 'Stripe Account ID'
                              : 'Payment Email',
                          controller: controller.identifierController,
                          hintText: isStripe
                              ? 'eg: acct_xxxxx'
                              : 'eg: john@gmail.com',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return isStripe
                                  ? 'Please enter Stripe Account ID'
                                  : 'Please enter Payment Email';
                            }
                            if (!isStripe && !GetUtils.isEmail(value.trim())) {
                              return 'Please enter a valid payment email';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  );
                }),

                // 5. Amount
                CustomTextField(
                  labelColor: AppColors.textPrimary,
                  labelText: 'Amount',
                  controller: controller.amountController,
                  hintText: 'Eg: \$500',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter amount';
                    }
                    final amount = double.tryParse(value.trim());
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount greater than 0';
                    }
                    return null;
                  },
                ),

                // 6. Note / Any additional information
                CustomTextField(
                  labelColor: AppColors.textPrimary,
                  labelText: 'Note / Any additional information',
                  controller: controller.noteController,
                  hintText: 'Write here...',
                ),

                SizedBox(height: 30.h),
              ],
            ),
          ),
        ).asSliver,
      ],
    );
  }

  Widget _buildMethodCard({
    required String label,
    required Widget icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: CustomContainer(
        radiusAll: 12.r,
        paddingAll: 16.r,
        marginBottom: 10.h,
        color: isSelected ? Colors.white : Colors.transparent,
        bordersColor: isSelected ? AppColors.primary : AppColors.textSecondary,
        borderWidth: isSelected ? 1.5.w : 0,
        child: Row(
          children: [
            icon,
            SizedBox(width: 12.w),
            CustomText(
              text: label,
              fontWeight: AppFontWeight.label,
              fontSize: 16.sp,
            ),
            const Spacer(),
            _buildRadio(isSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildRadio(bool isSelected) {
    return Container(
      width: 20.r,
      height: 20.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          width: 2.r,
        ),
      ),
      alignment: Alignment.center,
      child: isSelected
          ? Container(
              width: 10.r,
              height: 10.r,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}
