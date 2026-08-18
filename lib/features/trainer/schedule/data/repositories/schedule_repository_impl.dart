import 'package:pler_to_pler_app/features/trainer/schedule/data/data_sources/schedule_local_data_source.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/data/data_sources/schedule_remote_data_source.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/data/models/schedule_summary_model.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/data/models/session_model.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/domain/entities/schedule_summary_entity.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/domain/entities/session_entity.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/domain/repositories/schedule_repository.dart';

/// Repository Implementation
/// Bridges Domain Layer with Data Layer
class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleRemoteDataSource remoteDataSource;
  final ScheduleLocalDataSource localDataSource;

  ScheduleRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<SessionEntity>> getSessionsForDate(DateTime date) async {
    try {
      // Try to get from remote data source
      final sessions = await remoteDataSource.getSessionsForDate(date);
      
      // Cache locally
      await localDataSource.cacheSessions(sessions);
      await localDataSource.updateLastSyncTime(DateTime.now());
      
      // Return as domain entities
      return sessions.map((s) => s.toEntity()).toList();
    } catch (e) {
      // Fallback to local cache if remote fails
      final cached = await localDataSource.getCachedSessions(date);
      if (cached != null) {
        return cached.map((s) => s.toEntity()).toList();
      }
      throw Exception('Failed to get sessions: ${e.toString()}');
    }
  }

  @override
  Future<List<SessionEntity>> getWeeklySessions() async {
    try {
      final sessions = await remoteDataSource.getWeeklySessions();
      await localDataSource.cacheSessions(sessions);
      return sessions.map((s) => s.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get weekly sessions: ${e.toString()}');
    }
  }

  @override
  Future<ScheduleSummaryEntity> getScheduleSummary(DateTime date) async {
    try {
      final summary = await remoteDataSource.getScheduleSummary(date);
      return summary.toEntity();
    } catch (e) {
      throw Exception('Failed to get schedule summary: ${e.toString()}');
    }
  }

  @override
  Future<SessionEntity> getSessionById(String sessionId) async {
    try {
      final session = await remoteDataSource.getSessionById(sessionId);
      return session.toEntity();
    } catch (e) {
      throw Exception('Failed to get session details: ${e.toString()}');
    }
  }

  @override
  Future<void> cancelSession(String sessionId) async {
    try {
      await remoteDataSource.cancelSession(sessionId);
      // Refresh cached data
      await getWeeklySessions();
    } catch (e) {
      throw Exception('Failed to cancel session: ${e.toString()}');
    }
  }

  @override
  Future<void> rescheduleSession(String sessionId, DateTime newDate, String newTime) async {
    try {
      await remoteDataSource.rescheduleSession(sessionId, newDate, newTime);
      // Refresh cached data
      await getWeeklySessions();
    } catch (e) {
      throw Exception('Failed to reschedule session: ${e.toString()}');
    }
  }

  @override
  Future<void> startCallSession(String sessionId) async {
    try {
      await remoteDataSource.startCallSession(sessionId);
    } catch (e) {
      throw Exception('Failed to start call: ${e.toString()}');
    }
  }

  @override
  Future<void> sendMessageToClient(String clientId, String message) async {
    try {
      await remoteDataSource.sendMessageToClient(clientId, message);
    } catch (e) {
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }

  @override
  Future<List<SessionEntity>> getSessionsForClient(String clientId) {
    // TODO: implement getSessionsForClient
    throw UnimplementedError();
  }
}
