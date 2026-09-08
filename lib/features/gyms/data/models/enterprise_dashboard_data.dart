class EnterpriseDashboardData {
  final String administratorName;
  final int signups;
  final int? members;
  final int activeSubscriptions;
  final int trainers;
  final List<dynamic> recentSignups;
  final List<dynamic> activeSubscriptionItems;
  final List<dynamic> recentTrainers;
  final List<dynamic> recentActivity;

  const EnterpriseDashboardData({
    required this.administratorName,
    required this.signups,
    required this.members,
    required this.activeSubscriptions,
    required this.trainers,
    required this.recentSignups,
    required this.activeSubscriptionItems,
    required this.recentTrainers,
    required this.recentActivity,
  });

  factory EnterpriseDashboardData.fromJson(
    Map<String, dynamic> json, {
    bool requireMembers = true,
  }) {
    final counts = json['counts'] is Map
        ? Map<String, dynamic>.from(json['counts'] as Map)
        : const <String, dynamic>{};
    final administrator = json['administrator'] is Map
        ? Map<String, dynamic>.from(json['administrator'] as Map)
        : const <String, dynamic>{};
    int count(String key) {
      final value = counts[key];
      if (value is! int || value < 0)
        throw FormatException('Invalid dashboard metric: $key');
      return value;
    }

    List<dynamic> list(String key) =>
        json[key] is List ? List<dynamic>.from(json[key] as List) : const [];
    final administratorName =
        '${administrator['firstName'] ?? ''} ${administrator['lastName'] ?? ''}'
            .trim();

    return EnterpriseDashboardData(
      administratorName: administratorName,
      signups: count('signups'),
      members: !requireMembers && !counts.containsKey('members')
          ? null
          : count('members'),
      activeSubscriptions: count('activeSubscriptions'),
      trainers: count('trainers'),
      recentSignups: list('recentSignups'),
      activeSubscriptionItems: list('activeSubscriptions'),
      recentTrainers: list('recentTrainers'),
      recentActivity: list('recentActivity'),
    );
  }
}
