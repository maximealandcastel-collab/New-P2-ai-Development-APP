class ApiConstants {
  /// Override at run time, e.g.:
  /// `flutter run --dart-define=API_BASE_URL=http://127.0.0.1:4001`
  static const String baseUrl = 'https://faisal8080.merinasib.shop';

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
  static const String trainerRequest = '/api/v1/trainer-request';
  static String trainerKnowledgePack(String trainerId) => '/api/v1/trainer/$trainerId/knowledge-pack';
  static String trainerDetails(String trainerId) => '/api/v1/trainer/$trainerId';
  static String trainers(int page,int limit) => '/api/v1/trainer?page=$page&limit=$limit';

  /// CATEGORY ──────────────────────────────────────────────
  static const String categoryMy = '/api/v1/category/my';
  static const String categoryCreate = '/api/v1/category/create';
  static String categoryById(String categoryId) => '/api/v1/category/$categoryId';


  ///
  static const String searchHistoryKey = '/searchHistoryKey';
}
