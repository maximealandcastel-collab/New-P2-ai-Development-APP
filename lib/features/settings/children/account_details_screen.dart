import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/custom_assets/assets.gen.dart';
import 'package:pler_to_pler_app/services/api_urls.dart';
import 'package:pler_to_pler_app/services/network/api_client.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';


class AccountDetailsScreen extends StatefulWidget {
  const AccountDetailsScreen({super.key});

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  final TextEditingController _emailController = TextEditingController(text: 'Ethancarter77@gmail.com');
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool _isSaving = false;

  Future<void> _savePassword() async {
    final oldPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    if (oldPassword.isEmpty || newPassword.isEmpty) {
      Get.snackbar(
        'Missing password',
        'Enter your current and new password.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (newPassword.length < 8) {
      Get.snackbar(
        'Password too short',
        'Use at least 8 characters.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      final response = await ApiClient.postData(
        ApiUrls.changePassword,
        {'oldPassword': oldPassword, 'newPassword': newPassword},
      );
      if (response.statusCode != 200) {
        final message = response.body is Map
            ? response.body['message']?.toString()
            : response.statusText;
        throw Exception(message);
      }
      _currentPasswordController.clear();
      _newPasswordController.clear();
      Get.snackbar(
        'Password updated',
        'Your password was changed successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Password not changed',
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(title: 'Account details'),

      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: 'Account information',
              fontWeight: FontWeight.w600,
              fontSize: 18.sp,
              bottom: 8.h,
              top: 24.h,
            ),

            CustomTextField(
              prefixIcon: Assets.icons.emailIcon.image(height: 20.r, width: 20.r),
              labelText: 'Email',
              controller: _emailController,
            ),

            CustomContainer(
              radiusAll: 12.r,
              color: Colors.white,
              paddingAll: 16.r,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(text: 'Date of birth',fontWeight: FontWeight.w600),
                  CustomContainer(
                    color: Colors.black.withOpacity(0.08),
                    paddingAll: 8.r,
                    radiusAll: 8.r,
                    child: CustomText(text: '15 Feb 1996'),
                  ),
                ],
              ),
            ),



            /// +++++++++++++++++++++++++ Password +++++++++++++++++++++++
            CustomText(
              text: 'Password',
              fontWeight: FontWeight.w600,
              fontSize: 18.sp,
              bottom: 8.h,
              top: 24.h,
            ),

            CustomTextField(
              prefixIcon: Assets.icons.passwordIcon.image(
                height: 20.r,
                width: 20.r,
              ),
              labelText: 'Current password',
              hintText: 'Enter your current password',
              controller: _currentPasswordController,
              isPassword: true,
            ),

            CustomTextField(
              prefixIcon: Assets.icons.passwordIcon.image(
                height: 20.r,
                width: 20.r,
              ),
              labelText: 'New password',
              hintText: 'Enter your new password',
              controller: _newPasswordController,
              isPassword: true,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(child: Padding(
        padding:  EdgeInsets.all(16.r),
        child: CustomButton(
          onPressed: _savePassword,
          label: 'Save',
          isLoading: _isSaving,
          isDisabled: _isSaving,
        ),
      )),
    );
  }
}
