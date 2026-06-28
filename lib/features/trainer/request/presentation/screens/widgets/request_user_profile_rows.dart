import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/helpers/time_format.dart';
import 'package:pler_to_pler_app/features/trainer/request/data/models/trainer_request_model.dart';
import 'package:pler_to_pler_app/features/trainer/widgets/user_profile_fields.dart';

export 'package:pler_to_pler_app/core/helpers/string_format.dart'
    show ProfileInfoRowData;

class RequestUserProfileRows {
  RequestUserProfileRows._();

  static List<ProfileInfoRowData> profileInformation(RequestUser? user) =>
      profileInformationFromFields(UserProfileFields.fromRequestUser(user));

  static List<ProfileInfoRowData> profileInformationFromFields(
    UserProfileFields? user,
  ) {
    final rows = <ProfileInfoRowData>[];

    final preferredName = StringFormat.hasText(user?.preferredName)
        ? user!.preferredName!.trim()
        : user?.fullName.trim();
    if (StringFormat.hasText(preferredName)) {
      rows.add((label: 'Preferred Name', value: preferredName!));
    }

    if (StringFormat.hasText(user?.email)) {
      rows.add((label: 'Email Address', value: user!.email!.trim()));
    }

    if (StringFormat.hasText(user?.dateOfBirth)) {
      rows.add((
        label: 'Date of birth',
        value: TimeFormatHelper.formatDate(
          DateTime.parse(user!.dateOfBirth!),
        ),
      ));
    }

    if (StringFormat.hasText(user?.bio)) {
      rows.add((label: 'Bio', value: user!.bio!.trim()));
    }

    return rows;
  }

  static String? fitnessLevel(RequestUser? user) =>
      fitnessLevelFromFields(UserProfileFields.fromRequestUser(user));

  static String? fitnessLevelFromFields(UserProfileFields? user) {
    if (!StringFormat.hasText(user?.fitnessLevel)) return null;
    return MenuShowHelper.fitnessLevelDisplayValue(user!.fitnessLevel);
  }

  static List<ProfileInfoRowData> bodyMetrics(RequestUser? user) =>
      bodyMetricsFromFields(UserProfileFields.fromRequestUser(user));

  static List<ProfileInfoRowData> bodyMetricsFromFields(
    UserProfileFields? user,
  ) {
    final rows = <ProfileInfoRowData>[];

    if (user?.height != null) {
      final height = MenuShowHelper.heightDisplayValue(user!.height);
      if (StringFormat.hasText(height)) {
        rows.add((label: 'Height', value: height));
      }
    }

    if (user?.weight != null) {
      final weight = MenuShowHelper.weightDisplayValue(user!.weight);
      if (StringFormat.hasText(weight)) {
        rows.add((label: 'Weight', value: weight));
      }
    }

    return rows;
  }

  static List<String> trainingPreferenceChips(RequestUser? user) =>
      trainingPreferenceChipsFromFields(UserProfileFields.fromRequestUser(user));

  static List<String> trainingPreferenceChipsFromFields(
    UserProfileFields? user,
  ) {
    if (user == null) return [];

    final chips = <String>[];

    if (StringFormat.hasText(user.primaryGoal)) {
      final goal = MenuShowHelper.goalDisplayValue(user.primaryGoal);
      if (StringFormat.hasText(goal)) {
        chips.add('Goal: $goal');
      }
    }

    if (StringFormat.hasText(user.gender)) {
      chips.add('Gender: ${MenuShowHelper.genderDisplayValue(user.gender)}');
    }

    if (StringFormat.hasText(user.availableEquipment)) {
      final equipment =
          MenuShowHelper.equipmentDisplayValue(user.availableEquipment);
      if (StringFormat.hasText(equipment)) {
        chips.add('Equipment: $equipment');
      }
    }

    if (user.trainingDaysPerWeek != null) {
      chips.add('Frequency: ${user.trainingDaysPerWeek} Days / Week');
    }

    if (StringFormat.hasText(user.motivationStyle)) {
      final motivation =
          MenuShowHelper.motivationStyleDisplayValue(user.motivationStyle);
      if (StringFormat.hasText(motivation)) {
        chips.add('Motivation: $motivation');
      }
    }

    return chips;
  }

  static List<String> injuryChips(RequestUser? user) =>
      injuryChipsFromFields(UserProfileFields.fromRequestUser(user));

  static List<String> injuryChipsFromFields(UserProfileFields? user) {
    if (user?.injuries == null || user!.injuries!.isEmpty) return [];

    return user.injuries!
        .where((injury) => StringFormat.hasText(injury))
        .map((injury) => StringFormat.formatLabel(injury.trim()))
        .toList();
  }

  static List<ProfileInfoRowData> request(TrainerRequestModel request) {
    final rows = <ProfileInfoRowData>[
      (label: 'Status', value: request.statusLabel),
      (label: 'Request date', value: request.formatDateTime(request.createdAt)),
    ];

    if (request.isAccepted) {
      rows.add((
        label: 'Accepted at',
        value: request.formatDateTime(request.acceptedAt),
      ));
    }

    if (StringFormat.hasText(request.invoiceStatus)) {
      rows.add((
        label: 'Invoice status',
        value: request.invoiceStatusLabel,
      ));
    }

    return rows;
  }
}
