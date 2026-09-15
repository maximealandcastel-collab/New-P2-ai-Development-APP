class IapVerifyResultModel {
  final bool isSubscribed;
  final String? subscriptionTier;
  final String? subscriptionStartDate;
  final String? subscriptionEndDate;
  final String? status;
  final String? platform;
  final String? productId;

  const IapVerifyResultModel({
    required this.isSubscribed,
    this.subscriptionTier,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.status,
    this.platform,
    this.productId,
  });

  /// A successful HTTP request alone is never an entitlement.
  bool isActiveAt(DateTime now) {
    final expires = DateTime.tryParse(subscriptionEndDate ?? '');
    return isSubscribed && expires != null && expires.isAfter(now) &&
        !const {'expired', 'revoked', 'refunded', 'inactive'}.contains(status?.toLowerCase());
  }

  static bool responseGrantsAccess(dynamic body, {DateTime? now}) {
    if (body is! Map || body['success'] != true || body['data'] is! Map) return false;
    return IapVerifyResultModel.fromJson(Map<String, dynamic>.from(body['data'] as Map))
        .isActiveAt(now ?? DateTime.now());
  }

  factory IapVerifyResultModel.fromJson(Map<String, dynamic> json) {
    return IapVerifyResultModel(
      isSubscribed: json['isSubscribed'] == true,
      subscriptionTier: json['subscriptionTier']?.toString(),
      subscriptionStartDate: json['subscriptionStartDate']?.toString(),
      subscriptionEndDate: json['subscriptionEndDate']?.toString(),
      status: json['status']?.toString(),
      platform: json['platform']?.toString(),
      productId: json['productId']?.toString(),
    );
  }
}
