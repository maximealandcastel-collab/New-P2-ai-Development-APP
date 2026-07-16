class EarningsModel {
  final bool? success;
  final EarningsData? data;

  EarningsModel({
    this.success,
    this.data,
  });

  factory EarningsModel.fromJson(Map<String, dynamic> json) {
    final payload = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    return EarningsModel(
      success: json['success'] as bool?,
      data: EarningsData.fromJson(payload),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
    };
  }
}

class EarningsData {
  final int? totalRevenueCents;
  final int? totalPlatformCents;
  final int? totalEarnedCents;
  final int? totalWithdrawnCents;
  final int? pendingWithdrawalCents;
  final int? availableBalanceCents;
  final int? commissionPercent;
  final int? trainerReceivesPercent;
  final int? totalPayments;
  final FormattedEarnings? formatted;

  EarningsData({
    this.totalRevenueCents,
    this.totalPlatformCents,
    this.totalEarnedCents,
    this.totalWithdrawnCents,
    this.pendingWithdrawalCents,
    this.availableBalanceCents,
    this.commissionPercent,
    this.trainerReceivesPercent,
    this.totalPayments,
    this.formatted,
  });

  factory EarningsData.fromJson(Map<String, dynamic> json) {
    return EarningsData(
      totalRevenueCents: json['totalRevenueCents'] as int?,
      totalPlatformCents: json['totalPlatformCents'] as int?,
      totalEarnedCents: json['totalEarnedCents'] as int?,
      totalWithdrawnCents: json['totalWithdrawnCents'] as int?,
      pendingWithdrawalCents: json['pendingWithdrawalCents'] as int?,
      availableBalanceCents: json['availableBalanceCents'] as int?,
      commissionPercent: json['commissionPercent'] as int?,
      trainerReceivesPercent: json['trainerReceivesPercent'] as int?,
      totalPayments: json['totalPayments'] as int?,
      formatted: json['formatted'] != null
          ? FormattedEarnings.fromJson(Map<String, dynamic>.from(json['formatted'] as Map))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRevenueCents': totalRevenueCents,
      'totalPlatformCents': totalPlatformCents,
      'totalEarnedCents': totalEarnedCents,
      'totalWithdrawnCents': totalWithdrawnCents,
      'pendingWithdrawalCents': pendingWithdrawalCents,
      'availableBalanceCents': availableBalanceCents,
      'commissionPercent': commissionPercent,
      'trainerReceivesPercent': trainerReceivesPercent,
      'totalPayments': totalPayments,
      'formatted': formatted?.toJson(),
    };
  }
}

class FormattedEarnings {
  final String? totalRevenue;
  final String? platformEarned;
  final String? trainerEarned;
  final String? totalWithdrawn;
  final String? pendingWithdrawal;
  final String? availableBalance;

  FormattedEarnings({
    this.totalRevenue,
    this.platformEarned,
    this.trainerEarned,
    this.totalWithdrawn,
    this.pendingWithdrawal,
    this.availableBalance,
  });

  factory FormattedEarnings.fromJson(Map<String, dynamic> json) {
    return FormattedEarnings(
      totalRevenue: json['totalRevenue']?.toString(),
      platformEarned: json['platformEarned']?.toString(),
      trainerEarned: json['trainerEarned']?.toString(),
      totalWithdrawn: json['totalWithdrawn']?.toString(),
      pendingWithdrawal: json['pendingWithdrawal']?.toString(),
      availableBalance: json['availableBalance']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRevenue': totalRevenue,
      'platformEarned': platformEarned,
      'trainerEarned': trainerEarned,
      'totalWithdrawn': totalWithdrawn,
      'pendingWithdrawal': pendingWithdrawal,
      'availableBalance': availableBalance,
    };
  }
}
