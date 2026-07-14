class PlanModel {
  final String title;
  final String billingText;
  final double price;
  final bool isBestValue;
  final String? saveText;
  final String? formattedPrice; // from store, fully formatted localized string

  PlanModel({
    required this.title,
    required this.billingText,
    required this.price,
    this.isBestValue = false,
    this.saveText,
    this.formattedPrice,
  });

  /// Returns a copy with the live store formatted price.
  PlanModel copyWithStorePrice(String storePriceFormatted) {
    return PlanModel(
      title: title,
      billingText: billingText,
      price: price,
      isBestValue: isBestValue,
      saveText: saveText,
      formattedPrice: storePriceFormatted,
    );
  }

  /// Formatted price string, e.g. "$50.00"
  String get displayPrice =>
      formattedPrice ?? '\$${price.toStringAsFixed(2)}';

  static final List<PlanModel> plans = [
    PlanModel(
      title: 'Annual Plan',
      billingText: 'Billed once a year',
      price: 50.00,
      isBestValue: true,
      saveText: 'Save 50%',
    ),
    PlanModel(
      title: 'Monthly Plan',
      billingText: 'Billed every month',
      price: 19.99,
    ),
  ];
}