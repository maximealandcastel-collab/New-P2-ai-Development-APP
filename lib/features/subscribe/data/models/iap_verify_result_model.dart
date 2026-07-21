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
