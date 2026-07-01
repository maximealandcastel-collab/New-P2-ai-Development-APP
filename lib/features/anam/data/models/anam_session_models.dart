import 'package:pler_to_pler_app/features/anam/data/models/anam_usage_model.dart';

class AnamStartSessionModel {
  AnamStartSessionModel({
    required this.dbSessionId,
    required this.personaId,
    required this.usage,
    this.sessionToken,
    this.trainerName,
    this.anamSessionId,
    this.preNegotiatedSession,
    this.customLlm = false,
    this.llmId,
    this.integrationMode,
    this.flutterHint,
  });

  factory AnamStartSessionModel.fromJson(Map<String, dynamic> json) {
    final preNegotiated = _parsePreNegotiatedSession(json);

    return AnamStartSessionModel(
      dbSessionId: _readDbSessionId(json),
      sessionToken: _parseSessionToken(json, preNegotiated),
      personaId: json['personaId'] as String,
      trainerName: json['trainerName'] as String?,
      anamSessionId: json['anamSessionId'] as String?,
      usage: AnamUsageModel.fromJson(
        Map<String, dynamic>.from(json['usage'] as Map),
      ),
      preNegotiatedSession: preNegotiated,
      customLlm: json['customLlm'] as bool? ?? false,
      llmId: json['llmId'] as String?,
      integrationMode: json['integrationMode'] as String?,
      flutterHint: json['flutterHint'] as String?,
    );
  }

  static String _readDbSessionId(Map<String, dynamic> json) {
    for (final key in ['dbSessionId', '_id']) {
      final value = json[key];
      if (value == null) continue;
      final id = value.toString().trim();
      if (id.isNotEmpty) return id;
    }
    throw FormatException('Missing dbSessionId in anam session start response');
  }

  static String? _readToken(Map<String, dynamic> source) {
    for (final key in ['sessionToken', 'token', 'anamSessionToken']) {
      final value = source[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  static String? _parseSessionToken(
    Map<String, dynamic> json,
    Map<String, dynamic>? preNegotiated,
  ) {
    return _readToken(json) ??
        (preNegotiated != null ? _readToken(preNegotiated) : null);
  }

  static Map<String, dynamic>? _parsePreNegotiatedSession(
    Map<String, dynamic> json,
  ) {
    if (json['preNegotiatedSession'] is Map) {
      return Map<String, dynamic>.from(json['preNegotiatedSession'] as Map);
    }

    for (final key in ['engineSession', 'anamEngineSession', 'anamSession']) {
      final nested = json[key];
      if (nested is Map) {
        final parsed = _parsePreNegotiatedSession(
          Map<String, dynamic>.from(nested),
        );
        if (parsed != null) return parsed;
      }
    }

    // Anam engine session id — never use dbSessionId here (that is for Bazz APIs).
    final sessionId = json['sessionId'] ?? json['anamSessionId'];
    final engineHost = json['engineHost'];
    final sessionToken = _readToken(json);

    if (sessionId == null || engineHost == null || sessionToken == null) {
      return null;
    }

    return {
      'sessionId': sessionId,
      'sessionToken': sessionToken,
      'engineHost': engineHost,
      'engineProtocol': json['engineProtocol'] ?? 'https',
      'signallingEndpoint':
          json['signallingEndpoint'] ?? json['signalingEndpoint'],
      'clientConfig': json['clientConfig'] ?? const {},
    };
  }

  final String dbSessionId;
  final String? sessionToken;
  final String personaId;
  final String? trainerName;
  final String? anamSessionId;
  final AnamUsageModel usage;
  final Map<String, dynamic>? preNegotiatedSession;
  final bool customLlm;
  final String? llmId;
  final String? integrationMode;
  final String? flutterHint;

  bool get hasConnectPayload =>
      (sessionToken?.isNotEmpty ?? false) || preNegotiatedSession != null;

  bool get usesClientCustomLlm =>
      customLlm ||
      llmId == 'CUSTOMER_CLIENT_V1' ||
      integrationMode == 'client_custom_llm';
}

class AnamMessageReplyModel {
  AnamMessageReplyModel({
    required this.assistantText,
    required this.suggestedContentTitles,
  });

  factory AnamMessageReplyModel.fromJson(Map<String, dynamic> json) {
    final assistant = json['assistantMessage'] as Map<String, dynamic>? ?? {};
    return AnamMessageReplyModel(
      assistantText: assistant['content'] as String? ?? '',
      suggestedContentTitles:
          (json['suggestedContentTitles'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
    );
  }

  final String assistantText;
  final List<String> suggestedContentTitles;
}

class AnamEndSessionModel {
  AnamEndSessionModel({
    required this.durationSeconds,
    this.usage,
  });

  factory AnamEndSessionModel.fromJson(Map<String, dynamic> json) {
    return AnamEndSessionModel(
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      usage: json['usage'] is Map
          ? AnamUsageModel.fromJson(
              Map<String, dynamic>.from(json['usage'] as Map),
            )
          : null,
    );
  }

  final int durationSeconds;
  final AnamUsageModel? usage;
}

class AnamPersonaModel {
  AnamPersonaModel({
    required this.trainerId,
    required this.personaId,
    required this.isEnabled,
  });

  factory AnamPersonaModel.fromJson(Map<String, dynamic> json) {
    return AnamPersonaModel(
      trainerId: json['trainerId'] as String? ?? '',
      personaId: json['personaId'] as String? ?? '',
      isEnabled: json['isEnabled'] as bool? ?? false,
    );
  }

  final String trainerId;
  final String personaId;
  final bool isEnabled;
}
