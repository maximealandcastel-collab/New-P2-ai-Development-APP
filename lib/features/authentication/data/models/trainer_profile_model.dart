class TrainerProfileModel {
  final String? name;
  final String? bio;
  final List<String>? certifications;
  final String? specialty;
  final List<String>? trainingStyleTags;
  final SubscriptionPrice? subscriptionPrice;

  const TrainerProfileModel({
    this.name,
    this.bio,
    this.certifications,
    this.specialty,
    this.trainingStyleTags,
    this.subscriptionPrice,
  });

  factory TrainerProfileModel.fromJson(Map<String, dynamic> json) {
    return TrainerProfileModel(
      name: json['name'] as String?,
      bio: json['bio'] as String?,
      certifications: (json['certifications'] as List?)?.cast<String>(),
      specialty: json['specialty'] as String?,
      trainingStyleTags: (json['trainingStyleTags'] as List?)?.cast<String>(),
      subscriptionPrice: json['subscriptionPrice'] != null
          ? SubscriptionPrice.fromJson(
          json['subscriptionPrice'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (bio != null) 'bio': bio,
    if (certifications != null) 'certifications': certifications,
    if (specialty != null) 'specialty': specialty,
    if (trainingStyleTags != null) 'trainingStyleTags': trainingStyleTags,
    if (subscriptionPrice != null)
      'subscriptionPrice': subscriptionPrice!.toJson(),
  };
}

class SubscriptionPrice {
  final int? premium;

  const SubscriptionPrice({this.premium});

  factory SubscriptionPrice.fromJson(Map<String, dynamic> json) {
    return SubscriptionPrice(premium: json['premium'] as int?);
  }

  Map<String, dynamic> toJson() => {
    if (premium != null) 'premium': premium,
  };
}