import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/core/helpers/time_format.dart';
import 'package:pler_to_pler_app/features/profile/data/models/user_model.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/trainer_details_model.dart';

typedef ProfileInfoRowData = ({String label, String value});

class StringFormat {
  StringFormat._();

  static String formatSpecialty(String s) {
    final withSpace = s.replaceAll('_', ' ');
    return withSpace.isEmpty
        ? withSpace
        : withSpace[0].toUpperCase() + withSpace.substring(1);
  }

  static String valueOrNa(String? value) {
    if (value == null || value.trim().isEmpty) return 'N/A';
    return value;
  }

  static String specialtyOrNa(String? specialty) {
    if (specialty == null || specialty.trim().isEmpty) return 'N/A';
    return formatSpecialty(specialty);
  }

  static String listOrNa(List<String>? values) {
    if (values == null || values.isEmpty) return 'N/A';
    return values.join(', ');
  }

  static String formatPrice(SubscriptionPrice? price) {
    final premium = price?.premium;
    if (premium == null) return 'N/A';
    return '\$ $premium';
  }

  static bool hasText(String? value) => value != null && value.trim().isNotEmpty;

  static int? parseHeight(String value) {
    final cmMatch = RegExp(r'\((\d+)\s*cm\)').firstMatch(value.trim());
    if (cmMatch != null) {
      return int.tryParse(cmMatch.group(1)!);
    }
    return int.tryParse(value.trim());
  }

  static double? parseWeight(String value) {
    final match = RegExp(r'([\d.]+)').firstMatch(value.trim());
    return match != null ? double.tryParse(match.group(1)!) : null;
  }

  static bool hasAccountInfo(UserModel? user) {
    return hasText(user?.email) || hasText(user?.preferredName);
  }

  static List<ProfileInfoRowData> buildPersonalProfileRows(UserModel? user) {
    final rows = <ProfileInfoRowData>[];

    if (hasText(user?.firstName) || hasText(user?.lastName)) {
      rows.add((
        label: 'Full name',
        value: user!.fullName.trim(),
      ));
    }

    if (hasText(user?.preferredName)) {
      rows.add((
        label: 'Preferred name',
        value: user!.preferredName!.trim(),
      ));
    }

    if (hasText(user?.gender)) {
      rows.add((
        label: 'Gender',
        value: MenuShowHelper.genderDisplayValue(user!.gender),
      ));
    }

    if (hasText(user?.dateOfBirth)) {
      rows.add((
        label: 'Date of birth',
        value: TimeFormatHelper.formatDate(DateTime.parse(user!.dateOfBirth!)),
      ));
    }

    return rows;
  }

  static List<ProfileInfoRowData> buildFitnessProfileRows(UserModel? user) {
    final rows = <ProfileInfoRowData>[];

    if (hasText(user?.primaryGoal)) {
      final goal = MenuShowHelper.goalDisplayValue(user!.primaryGoal);
      if (hasText(goal)) {
        rows.add((label: 'Primary goal', value: goal!));
      }
    }

    if (user?.height != null) {
      final height = MenuShowHelper.heightDisplayValue(user!.height);
      if (hasText(height)) {
        rows.add((label: 'Height', value: height));
      }
    }

    if (user?.weight != null) {
      final weight = MenuShowHelper.weightDisplayValue(user!.weight);
      if (hasText(weight)) {
        rows.add((label: 'Weight', value: weight));
      }
    }

    if (hasText(user?.fitnessLevel)) {
      rows.add((
        label: 'Fitness level',
        value: MenuShowHelper.fitnessLevelDisplayValue(user!.fitnessLevel),
      ));
    }

    if (hasText(user?.availableEquipment)) {
      final equipment =
          MenuShowHelper.equipmentDisplayValue(user!.availableEquipment);
      if (hasText(equipment)) {
        rows.add((label: 'Available equipment', value: equipment!));
      }
    }

    if (user?.trainingDaysPerWeek != null) {
      rows.add((
        label: 'Training days per week',
        value: '${user!.trainingDaysPerWeek}',
      ));
    }

    if (user?.injuries != null && user!.injuries!.isNotEmpty) {
      rows.add((
        label: 'Injuries',
        value: user.injuries!.join(', '),
      ));
    }

    if (hasText(user?.motivationStyle)) {
      final style =
          MenuShowHelper.motivationStyleDisplayValue(user!.motivationStyle);
      if (hasText(style)) {
        rows.add((label: 'Motivation style', value: style!));
      }
    }

    return rows;
  }
}