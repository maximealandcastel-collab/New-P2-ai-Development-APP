import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/features/trainer/clients/data/models/client_invoice_model.dart';
import 'package:pler_to_pler_app/features/trainer/request/data/models/trainer_request_model.dart';

class UserProfileFields {
  const UserProfileFields({
    required this.fullName,
    this.preferredName,
    this.email,
    this.dateOfBirth,
    this.bio,
    this.fitnessLevel,
    this.height,
    this.weight,
    this.primaryGoal,
    this.gender,
    this.availableEquipment,
    this.trainingDaysPerWeek,
    this.motivationStyle,
    this.injuries,
  });

  final String fullName;
  final String? preferredName;
  final String? email;
  final String? dateOfBirth;
  final String? bio;
  final String? fitnessLevel;
  final int? height;
  final num? weight;
  final String? primaryGoal;
  final String? gender;
  final String? availableEquipment;
  final int? trainingDaysPerWeek;
  final String? motivationStyle;
  final List<String>? injuries;

  factory UserProfileFields.fromRequestUser(RequestUser? user) {
    if (user == null) {
      return const UserProfileFields(fullName: '');
    }

    return UserProfileFields(
      fullName: user.fullName,
      preferredName: user.preferredName,
      email: user.email,
      dateOfBirth: user.dateOfBirth,
      bio: user.bio,
      fitnessLevel: user.fitnessLevel,
      height: user.height,
      weight: user.weight,
      primaryGoal: user.primaryGoal,
      gender: user.gender,
      availableEquipment: user.availableEquipment,
      trainingDaysPerWeek: user.trainingDaysPerWeek,
      motivationStyle: user.motivationStyle,
      injuries: user.injuries,
    );
  }

  factory UserProfileFields.fromClientUser(ClientUser? user) {
    if (user == null) {
      return const UserProfileFields(fullName: '');
    }

    return UserProfileFields(
      fullName: user.fullName,
      preferredName: user.preferredName,
      email: user.email,
      dateOfBirth: user.dateOfBirth,
      bio: user.bio,
      fitnessLevel: user.fitnessLevel,
      height: user.height,
      weight: user.weight,
      primaryGoal: user.primaryGoal,
      gender: user.gender,
      availableEquipment: user.availableEquipment,
      trainingDaysPerWeek: user.trainingDaysPerWeek,
      motivationStyle: user.motivationStyle,
      injuries: user.injuries,
    );
  }

  bool get isEmpty =>
      !StringFormat.hasText(fullName) &&
      !StringFormat.hasText(preferredName) &&
      !StringFormat.hasText(email);
}
