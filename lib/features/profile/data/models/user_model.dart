class UserModel {
  String? sId;
  String? firstName;
  String? lastName;
  String? email;
  String? gender;
  String? role;
  bool? isVerified;
  bool? isDeleted;
  List<String>? injuries;
  String? subscriptionTier;
  bool? onboardingCompleted;

  List<Memory>? memory;
  List<dynamic>? workoutHistory;

  String? createdAt;
  String? updatedAt;
  int? iV;

  AnamAI? anamAI;

  String? availableEquipment;
  String? dateOfBirth;
  String? fitnessLevel;
  int? height;
  String? primaryGoal;
  int? trainingDaysPerWeek;
  int? weight;

  String? subscriptionStartDate;
  String? profilePicture;
  String? coverPhoto;

  SubscribedTrainer? subscribedTrainer;

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
    this.availableEquipment,
    this.dateOfBirth,
    this.fitnessLevel,
    this.height,
    this.primaryGoal,
    this.trainingDaysPerWeek,
    this.weight,
    this.subscriptionStartDate,
    this.profilePicture,
    this.coverPhoto,
    this.subscribedTrainer,
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
        ? List<String>.from(json['injuries'])
        : [];

    subscriptionTier = json['subscriptionTier'];
    onboardingCompleted = json['onboardingCompleted'];

    memory = json['memory'] != null
        ? (json['memory'] as List)
        .map((e) => Memory.fromJson(e))
        .toList()
        : [];

    workoutHistory = json['workoutHistory'] != null
        ? List<dynamic>.from(json['workoutHistory'])
        : [];

    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];

    anamAI =
    json['anamAI'] != null ? AnamAI.fromJson(json['anamAI']) : null;

    availableEquipment = json['availableEquipment'];
    dateOfBirth = json['dateOfBirth'];
    fitnessLevel = json['fitnessLevel'];
    height = json['height'];
    primaryGoal = json['primaryGoal'];
    trainingDaysPerWeek = json['trainingDaysPerWeek'];
    weight = json['weight'];

    subscriptionStartDate = json['subscriptionStartDate'];
    profilePicture = json['profilePicture'];
    coverPhoto = json['coverPhoto'];

    subscribedTrainer = json['subscribedTrainer'] != null
        ? SubscribedTrainer.fromJson(json['subscribedTrainer'])
        : null;
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
      'memory': memory?.map((e) => e.toJson()).toList(),
      'workoutHistory': workoutHistory,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': iV,
      'anamAI': anamAI?.toJson(),
      'availableEquipment': availableEquipment,
      'dateOfBirth': dateOfBirth,
      'fitnessLevel': fitnessLevel,
      'height': height,
      'primaryGoal': primaryGoal,
      'trainingDaysPerWeek': trainingDaysPerWeek,
      'weight': weight,
      'subscriptionStartDate': subscriptionStartDate,
      'profilePicture': profilePicture,
      'coverPhoto': coverPhoto,
      'subscribedTrainer': subscribedTrainer?.toJson(),
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
    return {
      'currentPeriodStart': currentPeriodStart,
      'minutesUsedThisMonth': minutesUsedThisMonth,
      'monthlyMinutesLimit': monthlyMinutesLimit,
      'totalMinutesAllTime': totalMinutesAllTime,
    };
  }
}

class Memory {
  String? trainerId;
  ProfileMemory? profileMemory;
  RollingMemory? rollingMemory;
  String? lastUpdatedAt;
  String? sId;

  Memory({
    this.trainerId,
    this.profileMemory,
    this.rollingMemory,
    this.lastUpdatedAt,
    this.sId,
  });

  Memory.fromJson(Map<String, dynamic> json) {
    trainerId = json['trainerId'];
    profileMemory = json['profileMemory'] != null
        ? ProfileMemory.fromJson(json['profileMemory'])
        : null;

    rollingMemory = json['rollingMemory'] != null
        ? RollingMemory.fromJson(json['rollingMemory'])
        : null;

    lastUpdatedAt = json['lastUpdatedAt'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    return {
      'trainerId': trainerId,
      'profileMemory': profileMemory?.toJson(),
      'rollingMemory': rollingMemory?.toJson(),
      'lastUpdatedAt': lastUpdatedAt,
      '_id': sId,
    };
  }
}

class ProfileMemory {
  String? goal;
  String? experienceLevel;
  String? equipment;
  String? updatedAt;
  String? motivationStyle;

  ProfileMemory({
    this.goal,
    this.experienceLevel,
    this.equipment,
    this.updatedAt,
    this.motivationStyle,
  });

  ProfileMemory.fromJson(Map<String, dynamic> json) {
    goal = json['goal'];
    experienceLevel = json['experienceLevel'];
    equipment = json['equipment'];
    updatedAt = json['updatedAt'];
    motivationStyle = json['motivationStyle'];
  }

  Map<String, dynamic> toJson() {
    return {
      'goal': goal,
      'experienceLevel': experienceLevel,
      'equipment': equipment,
      'updatedAt': updatedAt,
      'motivationStyle': motivationStyle,
    };
  }
}

class RollingMemory {
  List<dynamic>? last3Sessions;
  List<dynamic>? flags;
  String? updatedAt;

  RollingMemory({
    this.last3Sessions,
    this.flags,
    this.updatedAt,
  });

  RollingMemory.fromJson(Map<String, dynamic> json) {
    last3Sessions = json['last3Sessions'] != null
        ? List<dynamic>.from(json['last3Sessions'])
        : [];

    flags = json['flags'] != null
        ? List<dynamic>.from(json['flags'])
        : [];

    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    return {
      'last3Sessions': last3Sessions,
      'flags': flags,
      'updatedAt': updatedAt,
    };
  }
}

class SubscribedTrainer {
  String? sId;
  String? name;
  List<String>? certifications;
  String? specialty;
  List<String>? trainingStyleTags;

  SubscribedTrainer({
    this.sId,
    this.name,
    this.certifications,
    this.specialty,
    this.trainingStyleTags,
  });

  SubscribedTrainer.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];

    certifications = json['certifications'] != null
        ? List<String>.from(json['certifications'])
        : [];

    specialty = json['specialty'];

    trainingStyleTags = json['trainingStyleTags'] != null
        ? List<String>.from(json['trainingStyleTags'])
        : [];
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'name': name,
      'certifications': certifications,
      'specialty': specialty,
      'trainingStyleTags': trainingStyleTags,
    };
  }
}