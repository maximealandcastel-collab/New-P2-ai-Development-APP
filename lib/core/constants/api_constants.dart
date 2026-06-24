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
  static const String accountDelete = '/api/v1/auth/account-delete';
  static const String uploadProfilePicture = '/api/v1/auth/upload-profile-picture';
  static const String uploadCoverPhoto = '/api/v1/auth/upload-cover-photo';




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

  /// CONTENT ──────────────────────────────────────────────
  static const String myContent = '/api/v1/content/my-content';
  static const String content = '/api/v1/content/content';
  static String contentById(String contentId) => '/api/v1/content/content/$contentId';

  /// PRIVACY ──────────────────────────────────────────────
  static const String privacyPolicy = '/api/v1/privacy';
  static const String termsAndCondition = '/api/v1/terms';
  static const String aboutUs = '/api/v1/about';

  /// DEVICE ──────────────────────────────────────────────
  static const String userDevices = '/api/v1/devices';
  static const String pairDevice = '/api/v1/devices/pair';
  static String deviceStatus(String deviceId) => '/api/v1/devices/$deviceId/status';
  static String unpairDevice(String deviceId) => '/api/v1/devices/$deviceId';
  static String deviceMetrics(String deviceId) => '/api/v1/devices/$deviceId/metrics';

  ///
  static const String searchHistoryKey = '/searchHistoryKey';
}
