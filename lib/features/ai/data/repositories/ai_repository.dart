import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/services/api_service.dart';
import 'package:pler_to_pler_app/features/ai/data/models/knowledge_pack_model.dart';

class AiRepository {
  final ApiService _apiService;

  AiRepository({required ApiService apiService}) : _apiService = apiService;

  Future<void> submitKnowledgePack({
    required String trainerId,
    required KnowledgePackModel data,
  }) async {
    try {
      await _apiService.post(
        ApiConstants.trainerKnowledgePack(trainerId),
        data: data.toJson(),
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }
}
