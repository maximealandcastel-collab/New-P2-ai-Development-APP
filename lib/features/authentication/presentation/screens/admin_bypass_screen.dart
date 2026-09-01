import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/constants/app_constants.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/services/admin_mode_service.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/helpers/prefs_helper.dart';
import 'package:pler_to_pler_app/features/admin/presentation/controllers/admin_dashboard_controller.dart';

/// Key used to read/store the admin-specific JWT token.
/// Must match the constant declared in AdminDashboardController.
const String _kAdminTokenKey = 'adminToken';

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

  /// Calls the backend /auth/admin-bypass endpoint with the user's current JWT.
  /// On success the backend upgrades the account to admin role and returns a
  /// dedicated admin JWT that subsequent API calls use via Bearer auth.
  Future<bool> _callBackendBypass(String code) async {
    final userToken =
        Get.find<CacheService>().get<String>(AppConstants.accessToken);
    if ((userToken?.isEmpty ?? true)) {
      if (mounted) {
        setState(() =>
            _error = 'You must be logged in to activate admin mode.');
      }
      return false;
    }

    try {
      final dio = Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 12),
      ));

      final response = await dio.post(
        '/api/v1/auth/admin-bypass',
        data: {'code': code},
        options: Options(headers: {
          'Authorization': 'Bearer $userToken',
          'Content-Type': 'application/json',
        }),
      );
      if (!mounted) return false;

      final rawData = response.data;
      final data = rawData is Map
          ? Map<String, dynamic>.from(rawData)
          : <String, dynamic>{};
      if (data['success'] == true) {
        final rawPayload = data['data'];
        final payload = rawPayload is Map
            ? Map<String, dynamic>.from(rawPayload)
            : <String, dynamic>{};
        final adminToken = payload['token']?.toString();
        if (adminToken != null && adminToken.isNotEmpty) {
          await PrefsHelper.setString(_kAdminTokenKey, adminToken);
        }
        return mounted;
      }
      setState(() =>
          _error = data['message']?.toString() ?? 'Activation failed.');
      return false;
    } on DioException catch (error) {
      if (!mounted) return false;
      final rawError = error.response?.data;
      final errorData = rawError is Map
          ? Map<String, dynamic>.from(rawError)
          : <String, dynamic>{};
      setState(() => _error = errorData['message']?.toString() ??
          'Could not reach the server. Try again.');
      return false;
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Unexpected error. Please try again.');
      }
      return false;
    }
  }

  Future<void> _activate() async {
    if (_loading) return;
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Please enter the admin code');
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
    });

    // ── Admin mode — validate with the backend ──
    final ok = await _callBackendBypass(code);
    if (!mounted) return;
    setState(() => _loading = false);

    if (!ok) return; // error already set in _callBackendBypass

    if (!Get.isRegistered<AdminModeService>()) {
      Get.put(AdminModeService(), permanent: true);
    }
    // Must be awaited: activate() schedules the toggle-pill overlay via
    // addPostFrameCallback after an async SharedPreferences read. Calling
    // this without awaiting let Get.offAll() below race ahead and tear down
    // the current screen before the pill could be scheduled/inserted --
    // the account was correctly promoted to admin but the pill never showed.
    await AdminModeService.to.activate();
    if (!mounted) return;
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
    Get.offAllNamed(AppRoute.bottonNavBar);
  }

  void _skip() {
    Get.offAllNamed(AppRoute.bottonNavBar);
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
                          fontSize: 28.sp,
                          fontWeight: AppFontWeight.section,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Enter your access code',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey.shade600),
                    onPressed: _skip,
                  ),
                ],
              ),

              SizedBox(height: 48.h),

              // Code input
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: _error.isNotEmpty
                        ? Colors.red.shade800
                        : Colors.grey.shade800,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _codeController,
                  obscureText: true,
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _activate(),
                  decoration: InputDecoration(
                    hintText: 'Access code',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 14.h),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.lock_outline,
                        color: Colors.grey.shade600, size: 20.sp),
                  ),
                ),
              ),

              if (_error.isNotEmpty) ...[
                SizedBox(height: 10.h),
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
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
                  ),
                  child: _loading
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
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
                            fontWeight: AppFontWeight.section,
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
