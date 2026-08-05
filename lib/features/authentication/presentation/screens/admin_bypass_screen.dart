import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/services/admin_mode_service.dart';
import 'package:pler_to_pler_app/core/services/affiliate_mode_service.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/admin/presentation/controllers/admin_dashboard_controller.dart';
import 'package:pler_to_pler_app/features/affiliate/presentation/controllers/affiliate_dashboard_controller.dart';
import 'package:pler_to_pler_app/features/nav_bar/presentation/screens/nav_bar.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class AdminBypassScreen extends StatefulWidget {
  final bool fromLogin;
  const AdminBypassScreen({super.key, this.fromLogin = false});

  @override
  State<AdminBypassScreen> createState() => _AdminBypassScreenState();
}

class _AdminBypassScreenState extends State<AdminBypassScreen> {
  final _codeController = TextEditingController();
  bool _loading = false;
  String _error = '';

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _activate() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Please enter the admin code');
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
    });

    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => _loading = false);

    if (code == '2931') {
      // Activate admin mode — registers service + controller if not already up
      if (!Get.isRegistered<AdminModeService>()) {
        Get.put(AdminModeService(), permanent: true);
      }
      AdminModeService.to.activate();
      if (!Get.isRegistered<AdminDashboardController>()) {
        Get.put(AdminDashboardController());
      }
      Get.snackbar(
        '🔓 Founders Access Granted',
        'Full Founders Access — lifetime admin privileges activated.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade800,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      Get.offAll(() => NavBar());
    } else if (code.toUpperCase() == '67') {
      // Activate affiliate / partner mode
      if (!Get.isRegistered<AffiliateModeService>()) {
        Get.put(AffiliateModeService(), permanent: true);
      }
      AffiliateModeService.to.activate(code);
      if (!Get.isRegistered<AffiliateDashboardController>()) {
        Get.put(AffiliateDashboardController(promoCode: code.toUpperCase()));
      }
      Get.snackbar(
        '💰 Partner Access Activated',
        'Welcome Samir! Your earnings dashboard is ready.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1A1A2E),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      Get.offAll(() => NavBar());
    } else {
      setState(() => _error = 'Invalid code. Please try again.');
    }
  }

  void _skip() {
    Get.offAll(() => NavBar());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Access',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Enter your admin code to unlock full access.',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 48.h),

              // Code input
              Text(
                'Admin Code',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.text,
                obscureText: true,
                style: TextStyle(color: Colors.white, fontSize: 18.sp),
                decoration: InputDecoration(
                  hintText: '••••',
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  filled: true,
                  fillColor: Colors.grey.shade900,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
                ),
                onSubmitted: (_) => _activate(),
              ),

              if (_error.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(
                  _error,
                  style: TextStyle(color: Colors.red.shade400, fontSize: 13.sp),
                ),
              ],

              SizedBox(height: 24.h),

              // Activate button
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _loading ? null : _activate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: _loading
                      ? SizedBox(
                          width: 22.w,
                          height: 22.h,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Activate',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 16.h),

              // Skip button
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: TextButton(
                  onPressed: _skip,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              Center(
                child: Text(
                  'Only for authorized administrators.',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
