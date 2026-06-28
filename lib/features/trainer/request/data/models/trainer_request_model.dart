import 'package:intl/intl.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/helpers/time_format.dart';

class TrainerRequestModel {
  String? id;
  RequestUser? userId;
  String? trainerId;
  String? note;
  String? status;
  String? invoiceStatus;
  String? createdAt;
  String? updatedAt;
  String? acceptedAt;

  TrainerRequestModel({
    this.id,
    this.userId,
    this.trainerId,
    this.note,
    this.status,
    this.invoiceStatus,
    this.createdAt,
    this.updatedAt,
    this.acceptedAt,
  });

  TrainerRequestModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    userId = json['userId'] != null
        ? RequestUser.fromJson(json['userId'])
        : null;
    trainerId = json['trainerId'];
    note = json['note'];
    status = json['status'];
    invoiceStatus = json['invoiceStatus'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    acceptedAt = json['acceptedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    if (userId != null) {
      data['userId'] = userId!.toJson();
    }
    data['trainerId'] = trainerId;
    data['note'] = note;
    data['status'] = status;
    data['invoiceStatus'] = invoiceStatus;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['acceptedAt'] = acceptedAt;
    return data;
  }

  String get clientName => userId?.fullName ?? 'Unknown client';

  String get statusLabel {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'Pending client';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      default:
        return StringFormat.formatLabel(status ?? 'N/A');
    }
  }

  String get invoiceStatusLabel {
    switch (invoiceStatus?.toLowerCase()) {
      case 'sent':
        return 'Invoice sent';
      case 'paid':
        return 'Paid';
      default:
        return StringFormat.formatLabel(invoiceStatus ?? 'N/A');
    }
  }

  bool get isPending => status?.toLowerCase() == 'pending';

  bool get isAccepted => status?.toLowerCase() == 'accepted';

  bool get isRejected => status?.toLowerCase() == 'rejected';

  bool get isInvoiceSent => invoiceStatus?.toLowerCase() == 'sent';

  bool get canSendInvoice => isAccepted && !isInvoiceSent;

  String get formattedRequestDate {
    if (createdAt == null || createdAt!.isEmpty) return '';
    final date = DateTime.parse(createdAt!).toLocal();
    return 'Request at ${DateFormat('dd-MM-yyyy').format(date)}';
  }

  String formatDateTime(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'N/A';
    return TimeFormatHelper.formatDateTime(DateTime.parse(isoDate).toLocal());
  }
}

class RequestUser {
  String? id;
  String? firstName;
  String? lastName;
  String? email;
  String? gender;
  String? role;
  bool? isVerified;
  List<String>? injuries;
  String? subscriptionTier;
  bool? onboardingCompleted;
  String? createdAt;
  String? updatedAt;
  RequestAnamAI? anamAI;
  String? availableEquipment;
  String? dateOfBirth;
  String? fitnessLevel;
  int? height;
  String? primaryGoal;
  int? trainingDaysPerWeek;
  num? weight;
  String? subscribedTrainer;
  String? subscriptionStartDate;
  String? profilePicture;
  String? coverPhoto;
  String? preferredName;
  String? bio;
  String? motivationStyle;

  RequestUser({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.gender,
    this.role,
    this.isVerified,
    this.injuries,
    this.subscriptionTier,
    this.onboardingCompleted,
    this.createdAt,
    this.updatedAt,
    this.anamAI,
    this.availableEquipment,
    this.dateOfBirth,
    this.fitnessLevel,
    this.height,
    this.primaryGoal,
    this.trainingDaysPerWeek,
    this.weight,
    this.subscribedTrainer,
    this.subscriptionStartDate,
    this.profilePicture,
    this.coverPhoto,
    this.preferredName,
    this.bio,
    this.motivationStyle,
  });

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  RequestUser.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['email'];
    gender = json['gender'];
    role = json['role'];
    isVerified = json['isVerified'];
    injuries = json['injuries'] is List
        ? (json['injuries'] as List).map((e) => e.toString()).toList()
        : [];
    subscriptionTier = json['subscriptionTier'];
    onboardingCompleted = json['onboardingCompleted'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    anamAI = json['anamAI'] is Map
        ? RequestAnamAI.fromJson(json['anamAI'])
        : null;
    availableEquipment = json['availableEquipment'];
    dateOfBirth = json['dateOfBirth'];
    fitnessLevel = json['fitnessLevel'];
    height = json['height'];
    primaryGoal = json['primaryGoal'];
    trainingDaysPerWeek = json['trainingDaysPerWeek'];
    weight = json['weight'] != null ? num.tryParse(json['weight'].toString()) : null;
    subscribedTrainer = json['subscribedTrainer']?.toString();
    subscriptionStartDate = json['subscriptionStartDate'];
    profilePicture = json['profilePicture'];
    coverPhoto = json['coverPhoto'];
    preferredName = json['preferredName'];
    bio = json['bio'];
    motivationStyle = json['motivationStyle'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['email'] = email;
    data['gender'] = gender;
    data['role'] = role;
    data['isVerified'] = isVerified;
    data['injuries'] = injuries;
    data['subscriptionTier'] = subscriptionTier;
    data['onboardingCompleted'] = onboardingCompleted;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    if (anamAI != null) {
      data['anamAI'] = anamAI!.toJson();
    }
    data['availableEquipment'] = availableEquipment;
    data['dateOfBirth'] = dateOfBirth;
    data['fitnessLevel'] = fitnessLevel;
    data['height'] = height;
    data['primaryGoal'] = primaryGoal;
    data['trainingDaysPerWeek'] = trainingDaysPerWeek;
    data['weight'] = weight;
    data['subscribedTrainer'] = subscribedTrainer;
    data['subscriptionStartDate'] = subscriptionStartDate;
    data['profilePicture'] = profilePicture;
    data['coverPhoto'] = coverPhoto;
    data['preferredName'] = preferredName;
    data['bio'] = bio;
    data['motivationStyle'] = motivationStyle;
    return data;
  }
}

class RequestAnamAI {
  int? monthlyMinutesLimit;
  int? minutesUsedThisMonth;
  int? totalMinutesAllTime;
  String? currentPeriodStart;

  RequestAnamAI({
    this.monthlyMinutesLimit,
    this.minutesUsedThisMonth,
    this.totalMinutesAllTime,
    this.currentPeriodStart,
  });

  RequestAnamAI.fromJson(Map<String, dynamic> json) {
    monthlyMinutesLimit = json['monthlyMinutesLimit'];
    minutesUsedThisMonth = json['minutesUsedThisMonth'];
    totalMinutesAllTime = json['totalMinutesAllTime'];
    currentPeriodStart = json['currentPeriodStart'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['monthlyMinutesLimit'] = monthlyMinutesLimit;
    data['minutesUsedThisMonth'] = minutesUsedThisMonth;
    data['totalMinutesAllTime'] = totalMinutesAllTime;
    data['currentPeriodStart'] = currentPeriodStart;
    return data;
  }
}
