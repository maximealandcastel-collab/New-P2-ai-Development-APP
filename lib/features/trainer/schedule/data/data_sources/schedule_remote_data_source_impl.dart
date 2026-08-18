import 'package:pler_to_pler_app/features/trainer/schedule/data/data_sources/schedule_remote_data_source.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/data/models/schedule_summary_model.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/data/models/session_model.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/domain/entities/session_entity.dart';

/// Implementation of ScheduleRemoteDataSource
/// Currently uses mock data - replace with actual API calls
class ScheduleRemoteDataSourceImpl implements ScheduleRemoteDataSource {
  // Mock sessions data - Replace with actual API integration
  final List<SessionModel> _mockSessions = [
    SessionModel(
      id: '1',
      date: DateTime(2025, 12, 25),
      time: '10:30 AM',
      clientName: 'Smith III',
      clientId: 'client_001',
      type: SessionType.virtualTherapy,
    ),
    SessionModel(
      id: '2',
      date: DateTime(2025, 11, 12),
      time: '08:45 AM',
      clientName: 'Smith III',
      clientId: 'client_001',
      type: SessionType.followUpChat,
      aiNote: 'revising her approach while enjoying a soothing massage to ease tension and enhance wellness.',
    ),
    SessionModel(
      id: '3',
      date: DateTime(2025, 3, 5),
      time: '02:15 PM',
      clientName: 'Smith III',
      clientId: 'client_001',
      type: SessionType.virtualTherapy,
    ),
    SessionModel(
      id: '4',
      date: DateTime(2025, 4, 30),
      time: '11:00 AM',
      clientName: 'Smith III',
      clientId: 'client_001',
      type: SessionType.followUpChat,
      aiNote: 'revising her approach while enjoying a soothing massage to ease tension and enhance wellness.',
    ),
  ];

  @override
  Future<List<SessionModel>> getSessionsForDate(DateTime date) async {
    // TODO: Replace with actual API call
    // Example: final response = await _dio.get('/api/sessions', queryParameters: {'date': date.toIso8601String()});
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    return _mockSessions;
  }

  @override
  Future<List<SessionModel>> getWeeklySessions() async {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockSessions;
  }

  @override
  Future<ScheduleSummaryModel> getScheduleSummary(DateTime date) async {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(milliseconds: 500));
    return const ScheduleSummaryModel(
      sessionToday: 5,
      needAttention: 4,
      totalSessions: 10,
      upcomingSessions: 6,
    );
  }

  @override
  Future<SessionModel> getSessionById(String sessionId) async {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockSessions.firstWhere(
      (session) => session.id == sessionId,
      orElse: () => throw Exception('Session not found'),
    );
  }

  @override
  Future<void> cancelSession(String sessionId) async {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulate successful cancellation
  }

  @override
  Future<void> rescheduleSession(String sessionId, DateTime newDate, String newTime) async {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulate successful rescheduling
  }

  @override
  Future<void> startCallSession(String sessionId) async {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulate starting a call
  }

  @override
  Future<void> sendMessageToClient(String clientId, String message) async {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulate sending a message
  }
}
