class ApiConstants {
  static const String baseUrl = 'http://10.10.11.81:4001';

  /// ─── Auth Marker ───────────────────────────
  static const String requiresAuthHeader = 'X-Requires-Auth';
  static const Map<String, dynamic> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// AUTH ──────────────────────────────────────────────
  static const String login = '/api/v1/auth/login';
  static const String register = '/api/v1/auth/register';
  static const String forgot = '/api/v1/auth/forget-password';
  static const String otpVerify = '/api/v1/auth/verify-otp';
  static const String resendOtp = '/api/v1/auth/resend-otp';
  static const String resetPassword = '/api/v1/auth/reset-password';
  static const String changePassword = '/api/v1/auth/change-password';




  /// USER ──────────────────────────────────────────────
  static const String userProfile = '/api/v1/auth/me';
  static const String userProfileUpdate = '/api/v1/users/edit-profile';
  static const String userOnboarding = '/api/v1/auth/me/onboarding';
  static const String trainerProfile = '/api/v1/trainer';


  ///
  static const String searchHistoryKey = '/searchHistoryKey';
}
