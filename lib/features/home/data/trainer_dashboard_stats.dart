class TrainerDashboardStats {
  final int activeClients;
  final int newClientsLast7Days;
  final int newClientsThisWeek;
  final int mealsAssigned;
  final int workoutsAssigned;

  const TrainerDashboardStats({
    required this.activeClients,
    required this.newClientsLast7Days,
    required this.newClientsThisWeek,
    required this.mealsAssigned,
    required this.workoutsAssigned,
  });

  const TrainerDashboardStats.empty()
      : activeClients = 0,
        newClientsLast7Days = 0,
        newClientsThisWeek = 0,
        mealsAssigned = 0,
        workoutsAssigned = 0;

  factory TrainerDashboardStats.fromJson(Map<String, dynamic> json) {
    final newClients = json['newUsersThisWeek'];
    final newClientsMap =
        newClients is Map ? Map<String, dynamic>.from(newClients) : const {};
    final workoutStats = json['workoutBlocksStats'];
    final workoutStatsMap =
        workoutStats is Map ? Map<String, dynamic>.from(workoutStats) : const {};

    return TrainerDashboardStats(
      activeClients: _asInt(json['activeUsersCount']),
      newClientsLast7Days: _asInt(newClientsMap['rolling7Days']),
      newClientsThisWeek: _asInt(newClientsMap['calendarWeek']),
      mealsAssigned: _asInt(json['mealsAssigned']),
      workoutsAssigned: _asInt(workoutStatsMap['total']),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }
}