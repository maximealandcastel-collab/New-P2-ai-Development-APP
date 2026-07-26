class ApiUrls {
  /// ============= base urls ===========>>>
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: "https://mihadhome8000.merinasib.shop/api/v1",
  );
  static const String imageBaseUrl = "$baseUrl/";
  static const String socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: "https://mihadhome8000.merinasib.shop",
  );

  /// ============= all urls ===========>>>

  /// ============= paywall / promo / checkout ===========>>>
  static const String promoValidate = '/promo/validate';
  static const String promoRedeem = '/promo/redeem';
  static const String checkoutDefault = '/payments/checkout/default';

  /// ============= workout goals / AI plan ===========>>>
  static const String workoutCreate = '/workout';
  static String workoutGenerate(String workoutId) => '/workout/$workoutId/generate';
  static const String workoutToday = '/workout/today';

  /// ============= device / watch sync ===========>>>
  static const String devicePair = '/devices/pair';
  static String deviceMetrics(String deviceId) => '/devices/$deviceId/metrics';


  static const String register = '/auth/create-account';
  static const String verifyOtp = '/auth/verify-otp';
  static const String login = '/auth/login';
  static const String resetPassword = '/auth/reset-password';
  static const String forgetPassword = '/auth/forget-password';
  static const String trackMe = '/users/track-me';
  static const String userMe = '/users/me';
  static const String contracts = '/contracts/';
  static  String order(String status,int page,int limit) => '/order/current-orders?status=$status&limit=$limit&page=$page';
  static const String courses = '/courses/';
  static  String orderHistory (int page,int limit) => '/order/recent-orders?limit=$limit&page=$page';
  static const String category = '/category/';
  static  String submitQuizUrl(String quizID) => '/courses/submit-quiz/$quizID/';
  static  String orderDetails(String orderID) => '/order/$orderID';
  static  String inbox(String conID) => '/message/$conID';
  static  String messageSend(String conID) => '/message/send/$conID';
  static  String sipping(String orderID) => '/order/address/$orderID';
  static  String orderStatus(String orderID) => '/order/status/$orderID';
  static  String orderTips(String orderID) => '/order/tip/$orderID';
  static const String addCategory = '/category/add-category';
  static const String payment = '/payment/create-payment';
  static const String earnings = '/earnings/my-earnings';
  static const String checkout = '/order/create';
  static const String conversation = '/conversation/';
  static const String updateProfile = '/users/edit-profile';
  static const String changePassword = '/auth/change-password';
  static String myFavourites( String type, int page, int limit ) => '/favorites/my-favorites?type=$type&page=$page&limit=$limit';
  static String home( String type, int page, int limit ) => 'https://jsonplaceholder.typicode.com/posts';

}
