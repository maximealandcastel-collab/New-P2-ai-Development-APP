
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
    certifications = json['certifications'] != null
        ? List<String>.from(json['certifications'])
        : null;
    specialty = json['specialty'];
    trainingStyleTags = json['trainingStyleTags'] != null
        ? List<String>.from(json['trainingStyleTags'])
        : null;
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
  String? profilePicture;
  String? coverPhoto;
  String? coverPicture;

  UserId({
    this.sId,
    this.firstName,
    this.lastName,
    this.email,
    this.profilePicture,
    this.coverPhoto,
    this.coverPicture,
  });

  String get fullName => '$firstName $lastName';

  UserId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['email'];
    profilePicture = json['profilePicture'];
    coverPhoto = json['coverPhoto'];
    coverPicture = json['coverPicture'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['email'] = email;
    data['profilePicture'] = profilePicture;
    data['coverPhoto'] = coverPhoto;
    data['coverPicture'] = coverPicture;
    return data;
  }
}

class SubscriptionPrice {
  bool? free;
  int? paid;
  int? premium;

  SubscriptionPrice({this.free, this.paid, this.premium});

  SubscriptionPrice.fromJson(Map<String, dynamic> json) {
    free = json['free'];
    paid = json['paid'];
    premium = json['premium'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['free'] = free;
    data['paid'] = paid;
    data['premium'] = premium;
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
