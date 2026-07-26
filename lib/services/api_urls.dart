class ApiUrls {
  /// ============= base urls ===========>>>
  static const String baseUrl = "https://mihadhome8000.merinasib.shop/api/v1";
  static const String imageBaseUrl = "https://mihadhome8000.merinasib.shop/api/v1/";
  static const String socketUrl = "https://mihadhome8000.merinasib.shop";

  /// ============= all urls ===========>>>

  /// ============= paywall / promo / checkout ===========>>>
  static const String promoValidate = '/promo/validate';
  static const String promoRedeem = '/promo/redeem';
  static const String checkoutDefault = '/payments/checkout/default';


  static const String register = '/auth/create-account';
  static const String verifyOtp = '/auth/verify-otp';
  static const String login = '/auth/login';
  static const String resetPassword = '/auth/reset-password';
  static const String forgetPassword = '/auth/forget-password';
  static const String freelanceRules = '/freelance';
  static const String trackMe = '/users/track-me';
  static const String userMe = '/users/me';
  static const String businessNumber = '/klzh/verify-klzh';
  static const String compliance = '/hygiene-compliance/';
  static const String become = '/cook/become-a-cook';
  static const String contracts = '/contracts/';
  static  String mealTest (int page,int limit) => '/meal?limit=$limit&page=$page';
  static  String mapCook (String? name, int page,int limit) {
    if (name != null && name.isNotEmpty) {
      return '/cook/locations?searchTerm=$name&limit=$limit&page=$page';
    } else {
      return '/cook/locations?limit=$limit&page=$page';
    }
  }
  static  String cart (int page,int limit) => '/cart?limit=$limit&page=$page';
  static  String offers (int page,int limit) => '/offer/offers?limit=$limit&page=$page';
  static  String seeAllMeals (int page,int limit) => '/meal/popular-meals?limit=$limit&page=$page';
  static  String order(String status,int page,int limit) => '/order/current-orders?status=$status&limit=$limit&page=$page';
  static const String courses = '/courses/';
  static const String digitalForm = '/klzh/register-klzh/';
  static  String orderHistory (int page,int limit) => '/order/recent-orders?limit=$limit&page=$page';
  static const String category = '/category/';
  static  String submitQuizUrl(String quizID) => '/courses/submit-quiz/$quizID/';
  static  String orderDetails(String orderID) => '/order/$orderID';
  static  String addCart(String mealID) => '/cart/order-meal/$mealID';
  static  String removeCart(String mealID) => '/cart/exclude-order/$mealID';
  static  String deleteCart(String mealID) => '/cart/$mealID';
  static  String mealsDetails(String mealsID) => '/meal/$mealsID';
  static  String cookDetails(String cookID) => '/cook/$cookID';
  static  String inbox(String conID) => '/message/$conID';
  static  String messageSend(String conID) => '/message/send/$conID';
  static  String sipping(String orderID) => '/order/address/$orderID';
  static  String orderStatus(String orderID) => '/order/status/$orderID';
  static  String offerConfirm(String offerID) => '/offer/confirm-offer/$offerID';
  static  String orderTips(String orderID) => '/order/tip/$orderID';
  static const String addMeal = '/meal/add-meal';
  static const String addCategory = '/category/add-category';
  static const String payment = '/payment/create-payment';
  static const String earnings = '/earnings/my-earnings';
  static const String cookVerify = '/cook-verify/verify-cook-id';
  static const String checkout = '/order/create';
  static const String conversation = '/conversation/';
  static const String updateProfile = '/users/edit-profile';
  static const String changePassword = '/auth/change-password';
  static String myFavourites( String type, int page, int limit ) => '/favorites/my-favorites?type=$type&page=$page&limit=$limit';
  static String home( String type, int page, int limit ) => 'https://jsonplaceholder.typicode.com/posts';

}
