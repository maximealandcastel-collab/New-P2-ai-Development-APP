import 'package:pler_to_pler_app/features/anam/data/models/anam_session_models.dart';
import 'package:pler_to_pler_app/features/anam/data/models/anam_usage_model.dart';
import 'package:pler_to_pler_app/features/anam/data/repositories/anam_repository.dart';

class AnamService {
  AnamService({required AnamRepository repository}) : _repository = repository;

  final AnamRepository _repository;

  Future<AnamUsageModel> getUsage() => _repository.getUsage();

  Future<AnamStartSessionModel> startSession(String trainerId) =>
      _repository.startSession(trainerId);

  Future<AnamMessageReplyModel> sendMessage({
    required String dbSessionId,
    required String trainerId,
    required String message,
  }) =>
      _repository.sendMessage(
        dbSessionId: dbSessionId,
        trainerId: trainerId,
        message: message,
      );

  Future<AnamEndSessionModel> endSession(String dbSessionId) =>
      _repository.endSession(dbSessionId);

  Future<AnamPersonaModel> saveTrainerPersona({
    required String trainerId,
    required String personaId,
  }) =>
      _repository.saveTrainerPersona(
        trainerId: trainerId,
        personaId: personaId,
      );

  Future<void> removeTrainerPersona(String trainerId) =>
      _repository.removeTrainerPersona(trainerId);
}
