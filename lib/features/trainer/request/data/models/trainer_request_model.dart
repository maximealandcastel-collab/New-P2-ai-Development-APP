import 'package:intl/intl.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/helpers/time_format.dart';

class TrainerRequestModel {
  String? id;
  RequestUser? userId;
  String? trainerId;
  String? note;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? acceptedAt;

  TrainerRequestModel({
    this.id,
    this.userId,
    this.trainerId,
    this.note,
    this.status,
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

  bool get isPending => status?.toLowerCase() == 'pending';

  bool get isAccepted => status?.toLowerCase() == 'accepted';

  bool get isRejected => status?.toLowerCase() == 'rejected';

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
  String? fitnessLevel;
  String? primaryGoal;
  String? profilePicture;

  RequestUser({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.fitnessLevel,
    this.primaryGoal,
    this.profilePicture,
  });

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  RequestUser.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['email'];
    fitnessLevel = json['fitnessLevel'];
    primaryGoal = json['primaryGoal'];
    profilePicture = json['profilePicture'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['email'] = email;
    data['fitnessLevel'] = fitnessLevel;
    data['primaryGoal'] = primaryGoal;
    data['profilePicture'] = profilePicture;
    return data;
  }
}
