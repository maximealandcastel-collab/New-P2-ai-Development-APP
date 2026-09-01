class AchievementUnlock {
  final String achievementId;
  final String tier;
  final String name;
  final String headline;
  final String description;
  final int milestoneValue;
  final int xpAwarded;
  final int workoutCount;
  final int badgeCount;
  final int totalCoreBadges;
  final int? nextMilestone;

  const AchievementUnlock({
    required this.achievementId,
    required this.tier,
    required this.name,
    required this.headline,
    required this.description,
    required this.milestoneValue,
    required this.xpAwarded,
    required this.workoutCount,
    required this.badgeCount,
    required this.totalCoreBadges,
    this.nextMilestone,
  });

  factory AchievementUnlock.fromJson(Map<String, dynamic> json) {
    return AchievementUnlock(
      achievementId: json['achievementId']?.toString() ?? '',
      tier: json['tier']?.toString() ?? 'rookie',
      name: json['name']?.toString() ?? 'Rookie',
      headline: json['headline']?.toString() ?? "You're Official.",
      description: json['description']?.toString() ?? '',
      milestoneValue: (json['milestoneValue'] as num?)?.toInt() ?? 1,
      xpAwarded: (json['xpAwarded'] as num?)?.toInt() ?? 0,
      workoutCount: (json['workoutCount'] as num?)?.toInt() ?? 0,
      badgeCount: (json['badgeCount'] as num?)?.toInt() ?? 1,
      totalCoreBadges: (json['totalCoreBadges'] as num?)?.toInt() ?? 3,
      nextMilestone: (json['nextMilestone'] as num?)?.toInt(),
    );
  }

  String get shareCopy =>
      'I just unlocked $name in P2P FitTech AI — $headline '
      'Workout #$milestoneValue complete. Keep showing up.';
}

class AchievementDefinition {
  final String achievementId;
  final String tier;
  final String name;
  final String headline;
  final String description;
  final int milestoneValue;
  final int xpAwarded;

  const AchievementDefinition({
    required this.achievementId,
    required this.tier,
    required this.name,
    required this.headline,
    required this.description,
    required this.milestoneValue,
    required this.xpAwarded,
  });

  factory AchievementDefinition.fromJson(Map<String, dynamic> json) {
    return AchievementDefinition(
      achievementId: json['achievementId']?.toString() ?? '',
      tier: json['tier']?.toString() ?? 'rookie',
      name: json['name']?.toString() ?? 'Rookie',
      headline: json['headline']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      milestoneValue: (json['milestoneValue'] as num?)?.toInt() ?? 0,
      xpAwarded: (json['xpAwarded'] as num?)?.toInt() ?? 0,
    );
  }
}

class AchievementOverview {
  final List<AchievementUnlock> unlocks;
  final List<AchievementDefinition> definitions;
  final int workoutCount;
  final int badgeCount;
  final int currentStreak;
  final int? nextMilestone;

  const AchievementOverview({
    required this.unlocks,
    required this.definitions,
    required this.workoutCount,
    required this.badgeCount,
    required this.currentStreak,
    required this.nextMilestone,
  });

  factory AchievementOverview.fromJson(Map<String, dynamic> json) {
    final rawUnlocks = json['unlocks'];
    final rawDefinitions = json['definitions'];
    return AchievementOverview(
      unlocks: rawUnlocks is List
          ? rawUnlocks
              .whereType<Map>()
              .map((item) => AchievementUnlock.fromJson(
                    Map<String, dynamic>.from(item),
                  ))
              .toList()
          : const [],
      definitions: rawDefinitions is List
          ? rawDefinitions
              .whereType<Map>()
              .map((item) => AchievementDefinition.fromJson(
                    Map<String, dynamic>.from(item),
                  ))
              .where((definition) => definition.achievementId.isNotEmpty)
              .toList()
          : const [],
      workoutCount: (json['workoutCount'] as num?)?.toInt() ?? 0,
      badgeCount: (json['badgeCount'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      nextMilestone: (json['nextMilestone'] as num?)?.toInt(),
    );
  }
}