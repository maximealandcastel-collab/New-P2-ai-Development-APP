import 'package:intl/intl.dart';

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
  num? weight;
  String? bio;

  String? subscriptionStartDate;
  String? subscriptionEndDate;
  String? profilePicture;
  String? coverPhoto;
  String? preferredName;
  String? motivationStyle;

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
    this.bio,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.profilePicture,
    this.coverPhoto,
    this.preferredName,
    this.motivationStyle,
    this.subscribedTrainer,
  });

  String get fullName => "$firstName $lastName";

  String get subscriptionPeriod {
    if (subscriptionStartDate == null || subscriptionEndDate == null) {
      return 'N/A';
    }
    final start = DateTime.parse(subscriptionStartDate!).toLocal();
    final end = DateTime.parse(subscriptionEndDate!).toLocal();
    final formatter = DateFormat('d MMMM yyyy');
    return '${formatter.format(start)} - ${formatter.format(end)}';
  }

  UserModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['email'];
    gender = json['gender'];
    role = json['role'];
    isVerified = json['isVerified'];
    isDeleted = json['isDeleted'];

    injuries = json['injuries'] is List
        ? (json['injuries'] as List).map((e) => e.toString()).toList()
        : [];

    subscriptionTier = json['subscriptionTier'];
    onboardingCompleted = json['onboardingCompleted'];

    memory = json['memory'] is List
        ? (json['memory'] as List)
            .whereType<Map>()
            .map((e) => Memory.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : [];

    workoutHistory = json['workoutHistory'] is List
        ? List<dynamic>.from(json['workoutHistory'] as List)
        : [];

    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];

    anamAI = json['anamAI'] is Map
        ? AnamAI.fromJson(Map<String, dynamic>.from(json['anamAI'] as Map))
        : null;

    availableEquipment = json['availableEquipment'];
    dateOfBirth = json['dateOfBirth'];
    fitnessLevel = json['fitnessLevel'];
    height = json['height'];
    primaryGoal = json['primaryGoal'];
    trainingDaysPerWeek = json['trainingDaysPerWeek'];
    weight = json['weight'] != null ? num.tryParse(json['weight'].toString()) : null;
    bio = json['bio'];

    subscriptionStartDate = json['subscriptionStartDate'];
    subscriptionEndDate = json['subscriptionEndDate'];
    profilePicture = json['profilePicture'];
    coverPhoto = json['coverPhoto'];
    preferredName = json['preferredName'];
    motivationStyle = json['motivationStyle'];

    subscribedTrainer = json['subscribedTrainer'] is Map
        ? SubscribedTrainer.fromJson(
            Map<String, dynamic>.from(json['subscribedTrainer'] as Map),
          )
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
      'bio': bio,
      'subscriptionStartDate': subscriptionStartDate,
      'subscriptionEndDate': subscriptionEndDate,
      'profilePicture': profilePicture,
      'coverPhoto': coverPhoto,
      'preferredName': preferredName,
      'motivationStyle': motivationStyle,
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
    trainerId = json['trainerId']?.toString();
    profileMemory = json['profileMemory'] is Map
        ? ProfileMemory.fromJson(
            Map<String, dynamic>.from(json['profileMemory'] as Map),
          )
        : null;

    rollingMemory = json['rollingMemory'] is Map
        ? RollingMemory.fromJson(
            Map<String, dynamic>.from(json['rollingMemory'] as Map),
          )
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
  String? preferredName;
  String? goal;
  String? experienceLevel;
  int? scheduleDaysPerWeek;
  String? equipment;
  String? limitations;
  String? preferences;
  String? updatedAt;
  String? motivationStyle;

  ProfileMemory({
    this.preferredName,
    this.goal,
    this.experienceLevel,
    this.scheduleDaysPerWeek,
    this.equipment,
    this.limitations,
    this.preferences,
    this.updatedAt,
    this.motivationStyle,
  });

  ProfileMemory.fromJson(Map<String, dynamic> json) {
    preferredName = json['preferredName'];
    goal = json['goal'];
    experienceLevel = json['experienceLevel'];
    scheduleDaysPerWeek = json['scheduleDaysPerWeek'];
    equipment = json['equipment'];
    limitations = json['limitations'];
    preferences = json['preferences'];
    updatedAt = json['updatedAt'];
    motivationStyle = json['motivationStyle'];
  }

  Map<String, dynamic> toJson() {
    return {
      'preferredName': preferredName,
      'goal': goal,
      'experienceLevel': experienceLevel,
      'scheduleDaysPerWeek': scheduleDaysPerWeek,
      'equipment': equipment,
      'limitations': limitations,
      'preferences': preferences,
      'updatedAt': updatedAt,
      'motivationStyle': motivationStyle,
    };
  }
}

class RollingMemory {
  List<dynamic>? last3Sessions;
  String? adherenceNotes;
  String? recoveryNotes;
  List<dynamic>? flags;
  String? updatedAt;

  RollingMemory({
    this.last3Sessions,
    this.adherenceNotes,
    this.recoveryNotes,
    this.flags,
    this.updatedAt,
  });

  RollingMemory.fromJson(Map<String, dynamic> json) {
    last3Sessions = json['last3Sessions'] != null
        ? List<dynamic>.from(json['last3Sessions'])
        : [];

    adherenceNotes = json['adherenceNotes'];
    recoveryNotes = json['recoveryNotes'];

    flags = json['flags'] != null
        ? List<dynamic>.from(json['flags'])
        : [];

    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    return {
      'last3Sessions': last3Sessions,
      'adherenceNotes': adherenceNotes,
      'recoveryNotes': recoveryNotes,
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