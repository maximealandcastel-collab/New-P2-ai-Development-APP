import 'package:pler_to_pler_app/features/trainer/schedule/domain/entities/session_entity.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/domain/repositories/schedule_repository.dart';

/// Use case for getting sessions for a specific date
class GetSessionsForDateUseCase {
  final ScheduleRepository repository;

  GetSessionsForDateUseCase(this.repository);

  Future<List<SessionEntity>> call(DateTime date) async {
    return await repository.getSessionsForDate(date);
  }
}
