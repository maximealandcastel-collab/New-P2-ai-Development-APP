import 'dart:convert';

import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/services/storage_service.dart';
import 'package:pler_to_pler_app/features/anam/data/models/anam_session_models.dart';
import 'package:pler_to_pler_app/features/anam/data/models/anam_usage_model.dart';

class AnamStoredSession {
  const AnamStoredSession({
    required this.dbSessionId,
    required this.trainerId,
    required this.trainerName,
    required this.personaId,
    required this.usesClientCustomLlm,
    this.sessionToken,
    this.preNegotiatedSession,
    this.needsRecovery = false,
  });

  final String dbSessionId;
  final String trainerId;
  final String trainerName;
  final String personaId;
  final bool usesClientCustomLlm;
  final String? sessionToken;
  final Map<String, dynamic>? preNegotiatedSession;
  final bool needsRecovery;

  bool get canResume =>
      sessionToken?.isNotEmpty == true || preNegotiatedSession != null;

  AnamStartSessionModel toStartSessionModel() {
    return AnamStartSessionModel(
      dbSessionId: dbSessionId,
      personaId: personaId,
      sessionToken: sessionToken,
      preNegotiatedSession: preNegotiatedSession,
      customLlm: usesClientCustomLlm,
      usage: AnamUsageModel(
        monthlyMinutesLimit: 0,
        minutesUsedThisMonth: 0,
        minutesRemaining: 0,
        isLimitReached: false,
        periodResetDate: DateTime.now(),
      ),
    );
  }
}

class AnamSessionStore {
  AnamSessionStore({StorageService? storage})
      : _storage = storage ?? Get.find<StorageService>();

  final StorageService _storage;

  AnamStoredSession? read() {
    final dbSessionId = _storage.getString(StorageKeys.anamActiveDbSessionId);
    final trainerId = _storage.getString(StorageKeys.anamActiveTrainerId);
    final trainerName = _storage.getString(StorageKeys.anamActiveTrainerName);
    final personaId = _storage.getString(StorageKeys.anamActivePersonaId);

    if (dbSessionId == null ||
        dbSessionId.isEmpty ||
        trainerId == null ||
        trainerId.isEmpty ||
        personaId == null ||
        personaId.isEmpty) {
      return null;
    }

    Map<String, dynamic>? preNegotiated;
    final rawPreNegotiated =
        _storage.getString(StorageKeys.anamActivePreNegotiated);
    if (rawPreNegotiated != null && rawPreNegotiated.isNotEmpty) {
      try {
        preNegotiated = Map<String, dynamic>.from(
          jsonDecode(rawPreNegotiated) as Map,
        );
      } catch (_) {
        preNegotiated = null;
      }
    }

    return AnamStoredSession(
      dbSessionId: dbSessionId,
      trainerId: trainerId,
      trainerName: trainerName ?? '',
      personaId: personaId,
      usesClientCustomLlm:
          _storage.getBool(StorageKeys.anamActiveCustomLlm) ?? false,
      sessionToken: _storage.getString(StorageKeys.anamActiveSessionToken),
      preNegotiatedSession: preNegotiated,
      needsRecovery:
          _storage.getBool(StorageKeys.anamSessionNeedsRecovery) ?? false,
    );
  }

  bool get hasActiveSession => read() != null;

  Future<void> saveFromStartSession({
    required AnamStartSessionModel session,
    required String trainerId,
    required String trainerName,
  }) async {
    await _storage.setString(
      StorageKeys.anamActiveDbSessionId,
      session.dbSessionId,
    );
    await _storage.setString(StorageKeys.anamActiveTrainerId, trainerId);
    await _storage.setString(StorageKeys.anamActiveTrainerName, trainerName);
    await _storage.setString(StorageKeys.anamActivePersonaId, session.personaId);
    await _storage.setBool(
      StorageKeys.anamActiveCustomLlm,
      session.usesClientCustomLlm,
    );

    final token = session.sessionToken;
    if (token != null && token.isNotEmpty) {
      await _storage.setString(StorageKeys.anamActiveSessionToken, token);
    } else {
      await _storage.remove(StorageKeys.anamActiveSessionToken);
    }

    final preNegotiated = session.preNegotiatedSession;
    if (preNegotiated != null) {
      await _storage.setString(
        StorageKeys.anamActivePreNegotiated,
        jsonEncode(preNegotiated),
      );
    } else {
      await _storage.remove(StorageKeys.anamActivePreNegotiated);
    }

    await _storage.setBool(StorageKeys.anamSessionNeedsRecovery, false);
  }

  Future<void> markNeedsRecovery() {
    return _storage.setBool(StorageKeys.anamSessionNeedsRecovery, true);
  }

  Future<void> clear() async {
    await _storage.remove(StorageKeys.anamActiveDbSessionId);
    await _storage.remove(StorageKeys.anamActiveTrainerId);
    await _storage.remove(StorageKeys.anamActiveTrainerName);
    await _storage.remove(StorageKeys.anamActiveSessionToken);
    await _storage.remove(StorageKeys.anamActivePersonaId);
    await _storage.remove(StorageKeys.anamActiveCustomLlm);
    await _storage.remove(StorageKeys.anamActivePreNegotiated);
    await _storage.remove(StorageKeys.anamSessionNeedsRecovery);
  }
}

enum AnamSessionRecoveryChoice {
  endSession,
  continueCall,
  cancel,
}
