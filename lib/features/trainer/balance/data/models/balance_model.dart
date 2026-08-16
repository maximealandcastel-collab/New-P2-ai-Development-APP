// Models for the Balance (earnings + withdrawal) feature

class TrainerEarningsModel {
  final int availableBalanceCents;
  final int pendingWithdrawalCents;
  final int totalEarnedCents;
  final int totalWithdrawnCents;
  final int commissionPercent;
  final int totalPayments;

  const TrainerEarningsModel({
    required this.availableBalanceCents,
    required this.pendingWithdrawalCents,
    required this.totalEarnedCents,
    required this.totalWithdrawnCents,
    required this.commissionPercent,
    required this.totalPayments,
  });

  factory TrainerEarningsModel.fromJson(Map<String, dynamic> json) =>
      TrainerEarningsModel(
        availableBalanceCents: (json['availableBalanceCents'] as num?)?.toInt() ?? 0,
        pendingWithdrawalCents: (json['pendingWithdrawalCents'] as num?)?.toInt() ?? 0,
        totalEarnedCents: (json['totalEarnedCents'] as num?)?.toInt() ?? 0,
        totalWithdrawnCents: (json['totalWithdrawnCents'] as num?)?.toInt() ?? 0,
        commissionPercent: (json['commissionPercent'] as num?)?.toInt() ?? 20,
        totalPayments: (json['totalPayments'] as num?)?.toInt() ?? 0,
      );

  double get availableDollars => availableBalanceCents / 100;
  double get pendingDollars   => pendingWithdrawalCents / 100;
  double get totalEarnedDollars => totalEarnedCents / 100;

  String get availableFormatted => '\$${availableDollars.toStringAsFixed(0)}';
  String get pendingFormatted   => '\$${pendingDollars.toStringAsFixed(0)}';
}

class TrainerSubscriberPaymentModel {
  final String? subscriberName;
  final String? subscriberImage;
  final String? subscriberEmail;
  final int amountCents;
  final String status;
  final DateTime createdAt;
  final String? subscriptionPeriod;

  const TrainerSubscriberPaymentModel({
    required this.subscriberName,
    required this.subscriberImage,
    required this.subscriberEmail,
    required this.amountCents,
    required this.status,
    required this.createdAt,
    required this.subscriptionPeriod,
  });

  factory TrainerSubscriberPaymentModel.fromJson(Map<String, dynamic> json) {
    final user = json['userId'] as Map<String, dynamic>?;
    return TrainerSubscriberPaymentModel(
      subscriberName: user != null
          ? '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim()
          : 'Subscriber',
      subscriberImage: user?['profilePicture'] as String?,
      subscriberEmail: user?['email'] as String?,
      amountCents: ((json['trainerAmountCents'] as num?) ?? 0).toInt(),
      status: json['status'] as String? ?? 'verified',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      subscriptionPeriod: (json['invoiceId'] as Map<String, dynamic>?)?['description'] as String?,
    );
  }

  double get amountDollars => amountCents / 100;
  String get amountFormatted => '\$${amountDollars.toStringAsFixed(0)}';
}
