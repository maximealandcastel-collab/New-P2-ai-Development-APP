import 'package:pler_to_pler_app/features/trainer/schedule/domain/repositories/schedule_repository.dart';

/// Use case for cancelling a session
class CancelSessionUseCase {
  final ScheduleRepository repository;

  CancelSessionUseCase(this.repository);

  Future<void> call(String sessionId) async {
    return await repository.cancelSession(sessionId);
  }
}
