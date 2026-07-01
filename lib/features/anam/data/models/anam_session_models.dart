import 'package:pler_to_pler_app/features/anam/data/models/anam_usage_model.dart';

class AnamStartSessionModel {
  AnamStartSessionModel({
    required this.dbSessionId,
    required this.personaId,
    required this.usage,
    this.sessionToken,
    this.trainerName,
  });

  factory AnamStartSessionModel.fromJson(Map<String, dynamic> json) {
    return AnamStartSessionModel(
      dbSessionId: json['dbSessionId'] as String,
      sessionToken: json['sessionToken'] as String?,
      personaId: json['personaId'] as String,
      trainerName: json['trainerName'] as String?,
      usage: AnamUsageModel.fromJson(
        Map<String, dynamic>.from(json['usage'] as Map),
      ),
    );
  }

  final String dbSessionId;
  final String? sessionToken;
  final String personaId;
  final String? trainerName;
  final AnamUsageModel usage;
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
