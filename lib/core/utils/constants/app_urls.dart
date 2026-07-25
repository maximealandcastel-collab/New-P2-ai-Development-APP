class AppUrls {
  AppUrls._();

  // static const String _baseUrl = 'https://employee-beryl.vercel.app/api/v1';
  // static const String login = '$_baseUrl/auth/login';

  /// TODO: point this at the production backend URL before release.
  static const String baseUrl = 'http://localhost:5000/api/v1';

  // Promo codes
  static const String promoValidate = '$baseUrl/promo/validate';
  static const String promoRedeem = '$baseUrl/promo/redeem';

  // Payments
  static const String checkoutDefault = '$baseUrl/payments/checkout/default';
}
