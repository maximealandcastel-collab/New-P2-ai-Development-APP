import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class PaymentRequestScreen extends StatefulWidget {
  const PaymentRequestScreen({super.key});

  @override
  State<PaymentRequestScreen> createState() => _PaymentRequestScreenState();
}

class _PaymentRequestScreenState extends State<PaymentRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _holderController = TextEditingController();
  final _routingController = TextEditingController();
  final _accountController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _holderController.dispose();
    _routingController.dispose();
    _accountController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _saveDraft() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Clover onboarding is pending approval. No bank details were sent.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverScaffold(
      appBar: const CustomSliverAppBar(title: 'Payout Information'),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
          child: CustomButton(
            onPressed: _saveDraft,
            label: 'Save & Secure',
            backgroundColor: Theme.of(context).colorScheme.primary,
            radius: 30.r,
          ),
        ),
      ),
      bodyList: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 28.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: 'Enter your bank details to receive payouts through Clover.',
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                  bottom: 16.h,
                ),
                _buildSecurityCard(),
                SizedBox(height: 24.h),
                _buildField(
                  label: 'Account Holder Name (Full Name)',
                  hint: 'Eg: John Doe',
                  controller: _holderController,
                  icon: Icons.person_outline_rounded,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter the account holder name'
                      : null,
                ),
                SizedBox(height: 18.h),
                _buildField(
                  label: 'Routing Number',
                  hint: 'Eg: 123456789',
                  controller: _routingController,
                  icon: Icons.account_balance_outlined,
                  keyboardType: TextInputType.number,
                  helper: '9-digit routing number for your bank.',
                  validator: (value) {
                    final routing = value?.trim() ?? '';
                    if (routing.isEmpty) return 'Enter the routing number';
                    if (!RegExp(r'^\d{9}$').hasMatch(routing)) return 'Routing number must be 9 digits';
                    return null;
                  },
                ),
                SizedBox(height: 18.h),
                _buildField(
                  label: 'Account Number',
                  hint: 'Eg: 000123456789',
                  controller: _accountController,
                  icon: Icons.credit_card_outlined,
                  keyboardType: TextInputType.number,
                  helper: 'Your bank account number.',
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter the account number'
                      : null,
                ),
                SizedBox(height: 18.h),
                _buildField(
                  label: 'Confirm Account Number',
                  hint: 'Re-enter account number',
                  controller: _confirmController,
                  icon: Icons.verified_user_outlined,
                  keyboardType: TextInputType.number,
                  helper: 'Please re-enter to confirm.',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Confirm the account number';
                    if (value.trim() != _accountController.text.trim()) return 'Account numbers do not match';
                    return null;
                  },
                ),
                SizedBox(height: 22.h),
                _buildCloverBrandCard(),
                SizedBox(height: 14.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified_user_outlined, size: 14.r, color: AppColors.textSecondary),
                    SizedBox(width: 6.w),
                    CustomText(
                      text: 'Your information is safe and encrypted',
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ).asSliver,
      ],
    );
  }

  Widget _buildSecurityCard() {
    return CustomContainer(
      paddingAll: 14.r,
      radiusAll: 14.r,
      color: const Color(0xFFF5FAF3),
      bordersColor: const Color(0xFFD3E2CF),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              color: const Color(0xFF249447),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.lock_rounded, color: Colors.white, size: 23.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: 'Secure Payouts with Clover', fontWeight: AppFontWeight.section, fontSize: 15.sp),
                SizedBox(height: 4.h),
                CustomText(text: 'Your information is encrypted and secure.', fontSize: 12.sp, color: AppColors.textSecondary),
                CustomText(text: 'Payouts will be sent once your sub-merchant account is approved.', fontSize: 12.sp, color: AppColors.textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required String? Function(dynamic) validator,
    TextInputType? keyboardType,
    String? helper,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(text: label, fontWeight: AppFontWeight.label, fontSize: 14.sp, bottom: 8.h),
        CustomTextField(
          controller: controller,
          hintText: hint,
          prefixIcon: Icon(icon, size: 21.r, color: AppColors.textSecondary),
          keyboardType: keyboardType,
          validator: validator,
        ),
        if (helper != null) ...[
          SizedBox(height: 5.h),
          CustomText(text: helper, fontSize: 11.sp, color: AppColors.textSecondary),
        ],
      ],
    );
  }

  Widget _buildCloverBrandCard() {
    return CustomContainer(
      paddingAll: 14.r,
      radiusAll: 14.r,
      color: const Color(0xFFF9F9F9),
      bordersColor: const Color(0xFFE3E3E3),
      child: Row(
        children: [
          Column(
            children: [
              Icon(Icons.grid_view_rounded, color: const Color(0xFF249447), size: 30.r),
              CustomText(text: 'clover', fontSize: 13.sp, fontWeight: AppFontWeight.section, color: const Color(0xFF4A4A4A)),
            ],
          ),
          SizedBox(width: 14.w),
          Container(width: 1.w, height: 46.h, color: const Color(0xFFE0E0E0)),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: 'Payouts powered by Clover', fontSize: 13.sp, fontWeight: AppFontWeight.section),
                SizedBox(height: 3.h),
                CustomText(text: 'Fast, secure, and reliable payouts once your account is approved.', fontSize: 11.sp, color: AppColors.textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
