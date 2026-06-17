import 'package:pler_to_pler_app/features/ai/data/models/knowledge_pack_model.dart';
import 'package:pler_to_pler_app/features/ai/data/repositories/ai_repository.dart';

class AiService {
  final AiRepository _repository;

  AiService({required AiRepository repository}) : _repository = repository;

  Future<void> submitKnowledgePack({
    required String trainerId,
    required KnowledgePackModel data,
  }) {
    return _repository.submitKnowledgePack(
      trainerId: trainerId,
      data: data,
    );
  }
}
