
class TrainerDetailsModel {
  String? sId;
  UserId? userId;
  String? name;
  String? bio;
  List<String>? certifications;
  String? specialty;
  List<String>? trainingStyleTags;
  String? systemPrompt;
  SubscriptionPrice? subscriptionPrice;
  int? subscriberCount;
  bool? isActive;
  bool? isVerified;
  String? createdAt;
  String? updatedAt;
  int? iV;
  AnamAI? anamAI;
  bool? isDefault;

  TrainerDetailsModel(
      {this.sId,
        this.userId,
        this.name,
        this.bio,
        this.certifications,
        this.specialty,
        this.trainingStyleTags,
        this.systemPrompt,
        this.subscriptionPrice,
        this.subscriberCount,
        this.isActive,
        this.isVerified,
        this.createdAt,
        this.updatedAt,
        this.iV,
        this.anamAI,
        this.isDefault});

  TrainerDetailsModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId =
    json['userId'] != null ? UserId.fromJson(json['userId']) : null;
    name = json['name'];
    bio = json['bio'];
    certifications = json['certifications'].cast<String>();
    specialty = json['specialty'];
    trainingStyleTags = json['trainingStyleTags'].cast<String>();
    systemPrompt = json['systemPrompt'];
    subscriptionPrice = json['subscriptionPrice'] != null
        ? SubscriptionPrice.fromJson(json['subscriptionPrice'])
        : null;
    subscriberCount = json['subscriberCount'];
    isActive = json['isActive'];
    isVerified = json['isVerified'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    anamAI =
    json['anamAI'] != null ? AnamAI.fromJson(json['anamAI']) : null;
    isDefault = json['isDefault'];
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
    data['systemPrompt'] = systemPrompt;
    if (subscriptionPrice != null) {
      data['subscriptionPrice'] = subscriptionPrice!.toJson();
    }
    data['subscriberCount'] = subscriberCount;
    data['isActive'] = isActive;
    data['isVerified'] = isVerified;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    if (anamAI != null) {
      data['anamAI'] = anamAI!.toJson();
    }
    data['isDefault'] = isDefault;
    return data;
  }
}

class UserId {
  String? sId;
  String? firstName;
  String? lastName;
  String? email;

  UserId({this.sId, this.firstName, this.lastName, this.email});

  UserId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['email'] = email;
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

class AnamAI {
  String? personaId;
  bool? isEnabled;

  AnamAI({this.personaId, this.isEnabled});

  AnamAI.fromJson(Map<String, dynamic> json) {
    personaId = json['personaId'];
    isEnabled = json['isEnabled'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['personaId'] = personaId;
    data['isEnabled'] = isEnabled;
    return data;
  }
}
