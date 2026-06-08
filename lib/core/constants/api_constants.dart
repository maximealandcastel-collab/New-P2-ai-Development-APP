class ApiConstants {
  static const String baseUrl = 'https://501wk9nr-8098.asse.devtunnels.ms';

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
  static const String userProfile = '/api/v1/users/me';
  static const String userProfileUpdate = '/api/v1/users/edit-profile';
  static const String usersProfile = '/api/v1/users';
  static String addMember(String userId,String motherId) => '/api/v1/member/add-child/$userId/$motherId';
  static String updateRole(String userId) => '/api/v1/super-admin/role/update/$userId';
  static String blockUser(String userId) => '/api/v1/super-admin/block-unblock/$userId';




  /// ─── Announcement Marker ───────────────────────────
  static String announcements(int page, int limit) => '/api/v1/announcement/all?page=$page&limit=$limit';
  static String announcementCreate = '/api/v1/announcement/create';
  static String announcementStatus(String announcementId) => '/api/v1/announcement/$announcementId';
  static String announcementDelete(String announcementId) => '/api/v1/announcement/$announcementId/delete';




  /// ─── poll Marker ───────────────────────────
  static String polls(int page, int limit) => '/api/v1/poll/?page=$page&limit=$limit';
  static String pollAns(String pollId) => '/api/v1/poll/$pollId/answer';
  static String pollDetails(String pollId) => '/api/v1/poll/$pollId/answers';
  static String pollResults(String pollId) => '/api/v1/poll/$pollId/results';
  static String pollDelete(String pollId) => '/api/v1/poll/$pollId/delete';
  static const String pollCreate = '/api/v1/poll/create';




  /// request ──────────────────────────────────────────────
  static const String requests = '/api/v1/request';
  static const String requestCreate = '/api/v1/request/create';
  static  String requestStatus(String requestId) => '/api/v1/super-admin/requests/update/$requestId';




  /// banner ──────────────────────────────────────────────
  static const String banner = '/api/v1/banner';
  static const String bannerCreate = '/api/v1/banner/upload';
  static  String bannerDelete(String bannerId) => '/api/v1/banner/$bannerId/delete';




  /// tree ──────────────────────────────────────────────
  static const String tree = '/api/v1/tree/full';
  static  String treeUserDetails(String userID) => '/api/v1/tree/$userID';
  static String deleteUser(String userId) => '/api/v1/member/remove-child/$userId';
  static  String motherTreeSelect(String userId) => '/api/v1/member/choose-mother/$userId';





  /// Dashboard ──────────────────────────────────────────────

  static const String dashboard = '/api/v1/super-admin/stats';
}
