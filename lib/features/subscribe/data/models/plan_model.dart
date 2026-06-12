class PlanModel {
  final String title;
  final String billingText;
  final double price;
  final bool isBestValue;
  final String? saveText;

  PlanModel({
    required this.title,
    required this.billingText,
    required this.price,
    this.isBestValue = false,
    this.saveText,
  });

static  final List<PlanModel> plans = [
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