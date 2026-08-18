import 'package:pler_to_pler_app/features/trainer/schedule/domain/entities/schedule_summary_entity.dart';

/// Data Model for Schedule Summary
class ScheduleSummaryModel extends ScheduleSummaryEntity {
  const ScheduleSummaryModel({
    required super.sessionToday,
    required super.needAttention,
    super.totalSessions = 0,
    super.upcomingSessions = 0,
  });

  /// Create from JSON
  factory ScheduleSummaryModel.fromJson(Map<String, dynamic> json) {
    return ScheduleSummaryModel(
      sessionToday: json['sessionToday'] as int,
      needAttention: json['needAttention'] as int,
      totalSessions: json['totalSessions'] as int? ?? 0,
      upcomingSessions: json['upcomingSessions'] as int? ?? 0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'sessionToday': sessionToday,
      'needAttention': needAttention,
      'totalSessions': totalSessions,
      'upcomingSessions': upcomingSessions,
    };
  }

  /// Convert to domain entity
  ScheduleSummaryEntity toEntity() {
    return ScheduleSummaryEntity(
      sessionToday: sessionToday,
      needAttention: needAttention,
      totalSessions: totalSessions,
      upcomingSessions: upcomingSessions,
    );
  }
}
