/// trainer_client_plan_model.dart
/// Represents a single client's workout plan as seen by the trainer.

class TrainerClientInfo {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? profilePicture;

  String get displayName {
    final full = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    return full.isNotEmpty ? full : (email ?? 'Client');
  }

  const TrainerClientInfo({
    this.firstName,
    this.lastName,
    this.email,
    this.profilePicture,
  });

  factory TrainerClientInfo.fromJson(Map<String, dynamic> j) {
    return TrainerClientInfo(
      firstName:      j['firstName']?.toString(),
      lastName:       j['lastName']?.toString(),
      email:          j['email']?.toString(),
      profilePicture: j['profilePicture']?.toString(),
    );
  }
}

/// Today's day (Mon=0, Sun=6) extracted from weeks[0].
class TrainerClientPlanDay {
  final String dayLabel;
  final String focus;
  final int exerciseCount;

  const TrainerClientPlanDay({
    required this.dayLabel,
    required this.focus,
    required this.exerciseCount,
  });

  factory TrainerClientPlanDay.fromJson(Map<String, dynamic> j) {
    final exercises = j['exercises'];
    return TrainerClientPlanDay(
      dayLabel:      j['dayLabel']?.toString() ?? '',
      focus:         j['focus']?.toString() ?? '',
      exerciseCount: exercises is List ? exercises.length : 0,
    );
  }
}

class TrainerClientPlanModel {
  final String? planId;
  final TrainerClientInfo client;
  final String title;
  final String? goal;
  final bool isActive;
  final TrainerClientPlanDay? todayDay;

  const TrainerClientPlanModel({
    this.planId,
    required this.client,
    required this.title,
    this.goal,
    required this.isActive,
    this.todayDay,
  });

  factory TrainerClientPlanModel.fromJson(Map<String, dynamic> j) {
    // Parse client
    final clientRaw = j['clientId'];
    final client = clientRaw is Map
        ? TrainerClientInfo.fromJson(Map<String, dynamic>.from(clientRaw))
        : const TrainerClientInfo();

    // Parse today's day from weeks[0]
    TrainerClientPlanDay? todayDay;
    final rawWeeks = j['weeks'];
    if (rawWeeks is List && rawWeeks.isNotEmpty) {
      final week0 = rawWeeks[0];
      if (week0 is List && week0.isNotEmpty) {
        final idx = DateTime.now().weekday - 1; // Mon=0, Sun=6
        final dayIdx = idx.clamp(0, week0.length - 1);
        final dayRaw = week0[dayIdx];
        if (dayRaw is Map) {
          todayDay = TrainerClientPlanDay.fromJson(Map<String, dynamic>.from(dayRaw));
        }
      }
    }

    return TrainerClientPlanModel(
      planId:   j['_id']?.toString(),
      client:   client,
      title:    j['title']?.toString() ?? 'Training Plan',
      goal:     j['goal']?.toString(),
      isActive: j['isActive'] == true,
      todayDay: todayDay,
    );
  }

  static List<TrainerClientPlanModel> listFromApiResponse(Map<String, dynamic> resp) {
    final data  = resp['data'];
    if (data == null) return [];
    final plans = data is Map ? data['plans'] : null;
    if (plans is! List) return [];
    return plans
        .map((p) => TrainerClientPlanModel.fromJson(Map<String, dynamic>.from(p as Map)))
        .toList();
  }
}
