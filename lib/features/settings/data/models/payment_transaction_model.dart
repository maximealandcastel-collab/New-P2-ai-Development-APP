import 'package:intl/intl.dart';

class PaymentTransactionModel {
  final String? id;
  final TransactionUser? userId;
  final String? trainerId;
  final TransactionInvoice? invoiceId;
  final String? subscriptionId;
  final String? transactionId;
  final int? amount;
  final String? currency;
  final String? gateway;
  final String? status;
  final int? commissionPercent;
  final int? platformAmountCents;
  final int? trainerAmountCents;
  final String? verifiedAt;
  final String? createdAt;
  final String? updatedAt;

  PaymentTransactionModel({
    this.id,
    this.userId,
    this.trainerId,
    this.invoiceId,
    this.subscriptionId,
    this.transactionId,
    this.amount,
    this.currency,
    this.gateway,
    this.status,
    this.commissionPercent,
    this.platformAmountCents,
    this.trainerAmountCents,
    this.verifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentTransactionModel.fromJson(Map<String, dynamic> json) {
    return PaymentTransactionModel(
      id: json['_id']?.toString(),
      userId: json['userId'] != null
          ? TransactionUser.fromJson(Map<String, dynamic>.from(json['userId'] as Map))
          : null,
      trainerId: json['trainerId']?.toString(),
      invoiceId: json['invoiceId'] != null
          ? TransactionInvoice.fromJson(Map<String, dynamic>.from(json['invoiceId'] as Map))
          : null,
      subscriptionId: json['subscriptionId']?.toString(),
      transactionId: json['transactionId']?.toString(),
      amount: json['amount'] as int?,
      currency: json['currency']?.toString(),
      gateway: json['gateway']?.toString(),
      status: json['status']?.toString(),
      commissionPercent: json['commissionPercent'] as int?,
      platformAmountCents: json['platformAmountCents'] as int?,
      trainerAmountCents: json['trainerAmountCents'] as int?,
      verifiedAt: json['verifiedAt']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId?.toJson(),
      'trainerId': trainerId,
      'invoiceId': invoiceId?.toJson(),
      'subscriptionId': subscriptionId,
      'transactionId': transactionId,
      'amount': amount,
      'currency': currency,
      'gateway': gateway,
      'status': status,
      'commissionPercent': commissionPercent,
      'platformAmountCents': platformAmountCents,
      'trainerAmountCents': trainerAmountCents,
      'verifiedAt': verifiedAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  String get clientName {
    if (userId == null) return 'Unknown Client';
    final first = userId?.firstName ?? '';
    final last = userId?.lastName ?? '';
    return '$first $last'.trim();
  }

  String get formattedAmount {
    if (amount == null) return '\$0.00';
    final value = amount! / 100;
    final symbol = currency?.toLowerCase() == 'usd' ? '\$' : (currency ?? '');
    return '$symbol${value.toStringAsFixed(2)}';
  }

  String get formattedTime {
    if (createdAt == null || createdAt!.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(createdAt!).toLocal();
      // Calculate human-friendly relative time or standard formatting
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) {
        return '${diff.inMinutes} mins ago';
      } else if (diff.inHours < 24) {
        return '${diff.inHours} hours ago';
      } else {
        return DateFormat('d MMM yyyy - h:mm a').format(date);
      }
    } catch (_) {
      return 'N/A';
    }
  }
}

class TransactionUser {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? email;

  TransactionUser({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
  });

  factory TransactionUser.fromJson(Map<String, dynamic> json) {
    return TransactionUser(
      id: json['_id']?.toString(),
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      email: json['email']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    };
  }
}

class TransactionInvoice {
  final String? id;
  final int? amount;
  final String? description;
  final String? periodStart;
  final String? periodEnd;

  TransactionInvoice({
    this.id,
    this.amount,
    this.description,
    this.periodStart,
    this.periodEnd,
  });

  factory TransactionInvoice.fromJson(Map<String, dynamic> json) {
    return TransactionInvoice(
      id: json['_id']?.toString(),
      amount: json['amount'] as int?,
      description: json['description']?.toString(),
      periodStart: json['periodStart']?.toString(),
      periodEnd: json['periodEnd']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'amount': amount,
      'description': description,
      'periodStart': periodStart,
      'periodEnd': periodEnd,
    };
  }
}
