/// Domain Entity for schedule summary statistics
class ScheduleSummaryEntity {
  final int sessionToday;
  final int needAttention;
  final int totalSessions;
  final int upcomingSessions;

  const ScheduleSummaryEntity({
    required this.sessionToday,
    required this.needAttention,
    this.totalSessions = 0,
    this.upcomingSessions = 0,
  });
}
