import 'package:intl/intl.dart';
import 'package:pler_to_pler_app/core/helpers/time_format.dart';

class ClientInvoiceModel {
  String? id;
  ClientUser? userId;
  String? trainerId;
  String? requestId;
  int? amount;
  String? currency;
  String? description;
  String? periodStart;
  String? periodEnd;
  String? status;
  String? pdfUrl;
  bool? isRenewal;
  String? expiresAt;
  String? createdAt;
  String? updatedAt;
  String? sentAt;
  String? paidAt;

  ClientInvoiceModel({
    this.id,
    this.userId,
    this.trainerId,
    this.requestId,
    this.amount,
    this.currency,
    this.description,
    this.periodStart,
    this.periodEnd,
    this.status,
    this.pdfUrl,
    this.isRenewal,
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
    this.sentAt,
    this.paidAt,
  });

  ClientInvoiceModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    userId = json['userId'] != null
        ? ClientUser.fromJson(json['userId'])
        : null;
    trainerId = json['trainerId'];
    requestId = json['requestId'];
    amount = json['amount'];
    currency = json['currency'];
    description = json['description'];
    periodStart = json['periodStart'];
    periodEnd = json['periodEnd'];
    status = json['status'];
    pdfUrl = json['pdfUrl'];
    isRenewal = json['isRenewal'];
    expiresAt = json['expiresAt'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    sentAt = json['sentAt'];
    paidAt = json['paidAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    if (userId != null) {
      data['userId'] = userId!.toJson();
    }
    data['trainerId'] = trainerId;
    data['requestId'] = requestId;
    data['amount'] = amount;
    data['currency'] = currency;
    data['description'] = description;
    data['periodStart'] = periodStart;
    data['periodEnd'] = periodEnd;
    data['status'] = status;
    data['pdfUrl'] = pdfUrl;
    data['isRenewal'] = isRenewal;
    data['expiresAt'] = expiresAt;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['sentAt'] = sentAt;
    data['paidAt'] = paidAt;
    return data;
  }

  String get clientName => userId?.fullName ?? 'Unknown client';

  String get subscriptionPeriod {
    if (periodStart == null || periodEnd == null) return 'N/A';
    final start = DateTime.parse(periodStart!).toLocal();
    final end = DateTime.parse(periodEnd!).toLocal();
    final formatter = DateFormat('d MMMM yyyy');
    return '${formatter.format(start)} - ${formatter.format(end)}';
  }

  String get formattedAmount {
    if (amount == null) return 'N/A';
    final value = amount! / 100;
    final symbol = currency?.toLowerCase() == 'usd' ? '\$' : (currency ?? '');
    return '$symbol${value.toStringAsFixed(2)}';
  }

  String get statusLabel {
    switch (status?.toLowerCase()) {
      case 'paid':
        return 'Paid';
      case 'sent':
        return 'Invoice sent';
      default:
        return status ?? 'N/A';
    }
  }

  bool get isPaid => status?.toLowerCase() == 'paid';

  String formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'N/A';
    return TimeFormatHelper.formatDate(DateTime.parse(isoDate).toLocal());
  }

  String formatDateTime(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'N/A';
    return TimeFormatHelper.formatDateTime(DateTime.parse(isoDate).toLocal());
  }
}

class ClientUser {
  String? id;
  String? firstName;
  String? lastName;
  String? email;
  String? profilePicture;

  ClientUser({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.profilePicture,
  });

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  ClientUser.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['email'];
    profilePicture = json['profilePicture'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['email'] = email;
    data['profilePicture'] = profilePicture;
    return data;
  }
}
