import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/services/api_service.dart';
import 'package:pler_to_pler_app/features/anam/data/models/anam_session_models.dart';
import 'package:pler_to_pler_app/features/anam/data/models/anam_usage_model.dart';

class AnamRepository {
  AnamRepository({required ApiService apiService}) : _apiService = apiService;

  final ApiService _apiService;

  Future<AnamUsageModel> getUsage() async {
    try {
      final response = await _apiService.get(ApiConstants.anamUsage);
      return AnamUsageModel.fromJson(
        Map<String, dynamic>.from(response.data['data'] as Map),
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<AnamStartSessionModel> startSession(String trainerId) async {
    try {
      final response = await _apiService.post(
        ApiConstants.anamSessionStart,
        data: {'trainerId': trainerId},
      );
      return AnamStartSessionModel.fromJson(
        Map<String, dynamic>.from(response.data['data'] as Map),
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<AnamMessageReplyModel> sendMessage({
    required String dbSessionId,
    required String trainerId,
    required String message,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.anamSessionMessage(dbSessionId),
        data: {'trainerId': trainerId, 'message': message},
      );
      return AnamMessageReplyModel.fromJson(
        Map<String, dynamic>.from(response.data['data'] as Map),
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<AnamEndSessionModel> endSession(String dbSessionId) async {
    try {
      final response = await _apiService.patch(
        ApiConstants.anamSessionEnd(dbSessionId),
      );
      return AnamEndSessionModel.fromJson(
        Map<String, dynamic>.from(response.data['data'] as Map),
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<AnamPersonaModel> saveTrainerPersona({
    required String trainerId,
    required String personaId,
  }) async {
    try {
      final response = await _apiService.put(
        ApiConstants.trainerAnam(trainerId),
        data: {'personaId': personaId},
      );
      return AnamPersonaModel.fromJson(
        Map<String, dynamic>.from(response.data['data'] as Map),
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<void> removeTrainerPersona(String trainerId) async {
    try {
      await _apiService.delete(ApiConstants.trainerAnam(trainerId));
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }
}
