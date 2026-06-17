class FindTrainerModel {
  String? sId;
  String? name;
  String? bio;
  List<String>? certifications;
  String? specialty;
  List<String>? trainingStyleTags;
  SubscriptionPrice? subscriptionPrice;
  int? subscriberCount;

  FindTrainerModel({
    this.sId,
    this.name,
    this.bio,
    this.certifications,
    this.specialty,
    this.trainingStyleTags,
    this.subscriptionPrice,
    this.subscriberCount,
  });

  FindTrainerModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    bio = json['bio'];
    certifications = json['certifications'].cast<String>();
    specialty = json['specialty'];
    trainingStyleTags = json['trainingStyleTags'].cast<String>();
    subscriptionPrice = json['subscriptionPrice'] != null
        ? SubscriptionPrice.fromJson(json['subscriptionPrice'])
        : null;
    subscriberCount = json['subscriberCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['bio'] = bio;
    data['certifications'] = certifications;
    data['specialty'] = specialty;
    data['trainingStyleTags'] = trainingStyleTags;
    if (subscriptionPrice != null) {
      data['subscriptionPrice'] = subscriptionPrice!.toJson();
    }
    data['subscriberCount'] = subscriberCount;
    return data;
  }
}

class SubscriptionPrice {
  int? premium;
  bool? free;

  SubscriptionPrice({this.premium, this.free});

  SubscriptionPrice.fromJson(Map<String, dynamic> json) {
    premium = json['premium'];
    free = json['free'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['premium'] = premium;
    data['free'] = free;
    return data;
  }
}
