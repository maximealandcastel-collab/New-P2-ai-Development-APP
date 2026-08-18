import 'package:pler_to_pler_app/features/trainer/schedule/domain/entities/session_entity.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/domain/repositories/schedule_repository.dart';

/// Use case for getting session details by ID
class GetSessionDetailsUseCase {
  final ScheduleRepository repository;

  GetSessionDetailsUseCase(this.repository);

  Future<SessionEntity> call(String sessionId) async {
    return await repository.getSessionById(sessionId);
  }
}
