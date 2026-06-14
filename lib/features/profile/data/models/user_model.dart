class UserModel {
  String? sId;
  String? firstName;
  String? lastName;
  String? email;
  String? gender;
  String? role;
  bool? isVerified;
  bool? isDeleted;
  List<dynamic>? injuries;
  String? subscriptionTier;
  bool? onboardingCompleted;
  List<dynamic>? memory;
  List<dynamic>? workoutHistory;
  String? createdAt;
  String? updatedAt;
  int? iV;
  AnamAI? anamAI;

  UserModel({
    this.sId,
    this.firstName,
    this.lastName,
    this.email,
    this.gender,
    this.role,
    this.isVerified,
    this.isDeleted,
    this.injuries,
    this.subscriptionTier,
    this.onboardingCompleted,
    this.memory,
    this.workoutHistory,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.anamAI,
  });

  String get fullName => "$firstName $lastName";

  UserModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['email'];
    gender = json['gender'];
    role = json['role'];
    isVerified = json['isVerified'];
    isDeleted = json['isDeleted'];

    injuries = json['injuries'] != null
        ? List<dynamic>.from(json['injuries'])
        : [];

    subscriptionTier = json['subscriptionTier'];
    onboardingCompleted = json['onboardingCompleted'];

    memory = json['memory'] != null ? List<dynamic>.from(json['memory']) : [];

    workoutHistory = json['workoutHistory'] != null
        ? List<dynamic>.from(json['workoutHistory'])
        : [];

    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];

    anamAI = json['anamAI'] != null ? AnamAI.fromJson(json['anamAI']) : null;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'gender': gender,
      'role': role,
      'isVerified': isVerified,
      'isDeleted': isDeleted,
      'injuries': injuries,
      'subscriptionTier': subscriptionTier,
      'onboardingCompleted': onboardingCompleted,
      'memory': memory,
      'workoutHistory': workoutHistory,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': iV,
      'anamAI': anamAI?.toJson(),
    };
  }
}

class AnamAI {
  String? currentPeriodStart;
  int? minutesUsedThisMonth;
  int? monthlyMinutesLimit;
  int? totalMinutesAllTime;

  AnamAI({
    this.currentPeriodStart,
    this.minutesUsedThisMonth,
    this.monthlyMinutesLimit,
    this.totalMinutesAllTime,
  });

  AnamAI.fromJson(Map<String, dynamic> json) {
    currentPeriodStart = json['currentPeriodStart'];
    minutesUsedThisMonth = json['minutesUsedThisMonth'];
    monthlyMinutesLimit = json['monthlyMinutesLimit'];
    totalMinutesAllTime = json['totalMinutesAllTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['currentPeriodStart'] = currentPeriodStart;
    data['minutesUsedThisMonth'] = minutesUsedThisMonth;
    data['monthlyMinutesLimit'] = monthlyMinutesLimit;
    data['totalMinutesAllTime'] = totalMinutesAllTime;
    return data;
  }
}
