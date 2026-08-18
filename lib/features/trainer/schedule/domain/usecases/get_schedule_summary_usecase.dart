import 'package:pler_to_pler_app/features/trainer/schedule/domain/entities/schedule_summary_entity.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/domain/repositories/schedule_repository.dart';

/// Use case for getting schedule summary statistics
class GetScheduleSummaryUseCase {
  final ScheduleRepository repository;

  GetScheduleSummaryUseCase(this.repository);

  Future<ScheduleSummaryEntity> call(DateTime date) async {
    return await repository.getScheduleSummary(date);
  }
}
