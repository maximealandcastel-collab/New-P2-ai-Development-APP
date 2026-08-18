import 'package:pler_to_pler_app/features/trainer/schedule/data/models/session_model.dart';

/// Abstract class defining local data source operations
abstract class ScheduleLocalDataSource {
  /// Cache sessions locally
  Future<void> cacheSessions(List<SessionModel> sessions);

  /// Get cached sessions for a date
  Future<List<SessionModel>?> getCachedSessions(DateTime date);

  /// Clear cached sessions
  Future<void> clearCachedSessions();

  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTime();

  /// Update last sync timestamp
  Future<void> updateLastSyncTime(DateTime time);
}
