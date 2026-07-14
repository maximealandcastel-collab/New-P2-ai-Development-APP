class DefaultCheckoutModel {
  final String? paymentUrl;
  final String? invoiceId;
  final int? amount;
  final String? tier;

  DefaultCheckoutModel({
    this.paymentUrl,
    this.invoiceId,
    this.amount,
    this.tier,
  });

  factory DefaultCheckoutModel.fromJson(Map<String, dynamic> json) {
    return DefaultCheckoutModel(
      paymentUrl: json['paymentUrl'] as String?,
      invoiceId: json['invoiceId'] as String?,
      amount: json['amount'] as int?,
      tier: json['tier'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'paymentUrl': paymentUrl,
        'invoiceId': invoiceId,
        'amount': amount,
        'tier': tier,
      };
}
