import 'package:pler_to_pler_app/features/trainer/schedule/data/models/schedule_summary_model.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/data/models/session_model.dart';

/// Abstract class defining remote data source operations
abstract class ScheduleRemoteDataSource {
  /// Get sessions for a specific date from API
  Future<List<SessionModel>> getSessionsForDate(DateTime date);

  /// Get weekly sessions from API
  Future<List<SessionModel>> getWeeklySessions();

  /// Get schedule summary from API
  Future<ScheduleSummaryModel> getScheduleSummary(DateTime date);

  /// Get session details by ID from API
  Future<SessionModel> getSessionById(String sessionId);

  /// Cancel a session via API
  Future<void> cancelSession(String sessionId);

  /// Reschedule a session via API
  Future<void> rescheduleSession(String sessionId, DateTime newDate, String newTime);

  /// Start a call session via API
  Future<void> startCallSession(String sessionId);

  /// Send message to client via API
  Future<void> sendMessageToClient(String clientId, String message);
}
