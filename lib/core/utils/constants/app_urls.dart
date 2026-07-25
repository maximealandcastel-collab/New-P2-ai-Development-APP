class AppUrls {
  AppUrls._();

  /// Backend base URL. Override per build with:
  ///   flutter run --dart-define=API_BASE_URL=https://api.yourdomain.com/api/v1
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000/api/v1',
  );

  // Promo codes
  static const String promoValidate = '$baseUrl/promo/validate';
  static const String promoRedeem = '$baseUrl/promo/redeem';

  // Payments
  static const String checkoutDefault = '$baseUrl/payments/checkout/default';
}
