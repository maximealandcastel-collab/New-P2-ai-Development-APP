import 'package:pler_to_pler_app/features/trainer/schedule/domain/repositories/schedule_repository.dart';

/// Use case for rescheduling a session
class RescheduleSessionUseCase {
  final ScheduleRepository repository;

  RescheduleSessionUseCase(this.repository);

  Future<void> call(String sessionId, DateTime newDate, String newTime) async {
    return await repository.rescheduleSession(sessionId, newDate, newTime);
  }
}
