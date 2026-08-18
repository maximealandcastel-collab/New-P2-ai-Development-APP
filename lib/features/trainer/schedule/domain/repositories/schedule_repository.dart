import 'package:pler_to_pler_app/features/trainer/schedule/domain/entities/schedule_summary_entity.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/domain/entities/session_entity.dart';

/// Repository Interface - Defines contracts for schedule data operations
/// Part of Domain layer - should NOT depend on external data sources
abstract class ScheduleRepository {
  /// Get sessions for a specific date
  Future<List<SessionEntity>> getSessionsForDate(DateTime date);

  /// Get all sessions for the current week
  Future<List<SessionEntity>> getWeeklySessions();

  /// Get sessions for a specific client
  Future<List<SessionEntity>> getSessionsForClient(String clientId);

  /// Get schedule summary statistics
  Future<ScheduleSummaryEntity> getScheduleSummary(DateTime date);

  /// Get session details by ID
  Future<SessionEntity> getSessionById(String sessionId);

  /// Cancel a session
  Future<void> cancelSession(String sessionId);

  /// Reschedule a session
  Future<void> rescheduleSession(String sessionId, DateTime newDate, String newTime);

  /// Start a call session
  Future<void> startCallSession(String sessionId);

  /// Send message to client
  Future<void> sendMessageToClient(String clientId, String message);
}
