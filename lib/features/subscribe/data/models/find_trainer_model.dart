class FindTrainerModel {
  String? sId;
  UserId? userId;
  String? name;
  String? bio;
  List<String>? certifications;
  String? specialty;
  List<String>? trainingStyleTags;
  SubscriptionPrice? subscriptionPrice;
  int? subscriberCount;
  String? profileImage;

  FindTrainerModel({
    this.sId,
    this.userId,
    this.name,
    this.bio,
    this.certifications,
    this.specialty,
    this.trainingStyleTags,
    this.subscriptionPrice,
    this.subscriberCount,
    this.profileImage,
  });

  FindTrainerModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'] != null
        ? UserId.fromJson(json['userId'])
        : null;
    name = json['name'];
    bio = json['bio'];
    certifications = json['certifications']?.cast<String>();
    specialty = json['specialty'];
    trainingStyleTags = json['trainingStyleTags']?.cast<String>();
    subscriptionPrice = json['subscriptionPrice'] != null
        ? SubscriptionPrice.fromJson(json['subscriptionPrice'])
        : null;
    subscriberCount = json['subscriberCount'];
    profileImage = json['profileImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    if (userId != null) {
      data['userId'] = userId!.toJson();
    }
    data['name'] = name;
    data['bio'] = bio;
    data['certifications'] = certifications;
    data['specialty'] = specialty;
    data['trainingStyleTags'] = trainingStyleTags;
    if (subscriptionPrice != null) {
      data['subscriptionPrice'] = subscriptionPrice!.toJson();
    }
    data['subscriberCount'] = subscriberCount;
    data['profileImage'] = profileImage;
    return data;
  }
}

class UserId {
  String? sId;
  String? firstName;
  String? lastName;
  String? profilePicture;
  String? coverPicture;

  UserId({
    this.sId,
    this.firstName,
    this.lastName,
    this.profilePicture,
    this.coverPicture,
  });

  String get fullName => '$firstName $lastName';

  UserId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    profilePicture = json['profilePicture'];
    coverPicture = json['coverPicture'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['profilePicture'] = profilePicture;
    data['coverPicture'] = coverPicture;
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
