import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/privacy/presentation/controllers/privacy_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class PrivacyPolicyAllScreen extends StatefulWidget {
  const PrivacyPolicyAllScreen({super.key});

  @override
  State<PrivacyPolicyAllScreen> createState() => _PrivacyPolicyAllScreenState();
}

class _PrivacyPolicyAllScreenState extends State<PrivacyPolicyAllScreen> {
  late final String title;
  late final String key;
  late final bool _isConsentMode;
  final controller = PrivacyController.to;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    title = args?['title'] ?? 'Terms and Conditions';
    key = args?['key'] ?? 'terms';
    _isConsentMode = args?['consent'] == true;
    controller.setActiveKey(key);
  }

  Future<void> _onAccept() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('privacyAccepted', true);
    Get.offAllNamed(AppRoute.onboardingMainScreen);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: _isConsentMode
          ? null
          : CustomAppBar(title: title),
      body: Column(
        children: [
          if (_isConsentMode) ...[
            SizedBox(height: MediaQuery.of(context).padding.top + 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                'Please read and accept our Privacy Policy and Terms before continuing.',
                style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
              ),
            ),
            SizedBox(height: 12.h),
          ],
          Expanded(
            child: Obx(() {
              switch (controller.loadingState) {
                case LoadingState.initial:
                case LoadingState.loading:
                  return const Center(child: CustomLoader());
                case LoadingState.offline:
                case LoadingState.error:
                  return EmptyDataWidget(
                    message: 'Failed to load. Please try again.',
                    onRefresh: () async => await controller.refresh(),
                  );
                case LoadingState.loaded:
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16.r, 8.r, 16.r,
                        _isConsentMode ? 100.h : 16.r),
                    child: _PrivacyContent(description: controller.description),
                  );
              }
            }),
          ),
          if (_isConsentMode)
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'I Accept & Continue',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PrivacyContent extends StatelessWidget {
  const _PrivacyContent({required this.description});
  final String description;

  @override
  Widget build(BuildContext context) {
    if (description.isEmpty) {
      return Text(
        'No content available.',
        style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
      );
    }
    return Text(
      description,
      style: TextStyle(
        fontSize: 14.sp,
        color: Colors.grey.shade800,
        height: 1.6,
      ),
    );
  }
}
