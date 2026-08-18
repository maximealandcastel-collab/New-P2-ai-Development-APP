import 'package:pler_to_pler_app/features/trainer/schedule/domain/entities/session_entity.dart';

/// Data Model for Session - extends domain entity
class SessionModel extends SessionEntity {
  final String? imageUrl;
  final Map<String, dynamic>? metadata;

  const SessionModel({
    required super.id,
    required super.date,
    required super.time,
    required super.clientName,
    required super.clientId,
    required super.type,
    super.aiNote,
    super.sessionNote,
    super.sessionId,
    super.isCompleted = false,
    super.isCancelled = false,
    this.imageUrl,
    this.metadata,
  });

  /// Create SessionModel from JSON
  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      clientName: json['clientName'] as String,
      clientId: json['clientId'] as String,
      type: SessionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SessionType.followUpChat,
      ),
      aiNote: json['aiNote'] as String?,
      sessionNote: json['sessionNote'] as String?,
      sessionId: json['sessionId'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isCancelled: json['isCancelled'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert SessionModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'time': time,
      'clientName': clientName,
      'clientId': clientId,
      'type': type.name,
      'aiNote': aiNote,
      'sessionNote': sessionNote,
      'sessionId': sessionId,
      'isCompleted': isCompleted,
      'isCancelled': isCancelled,
      'imageUrl': imageUrl,
      'metadata': metadata,
    };
  }

  /// Convert to domain entity
  SessionEntity toEntity(){
    return SessionEntity(
      id: id,
      date: date,
      time: time,
      clientName: clientName,
      clientId: clientId,
      type: type,
      aiNote: aiNote,
      sessionNote: sessionNote,
      sessionId: sessionId,
      isCompleted: isCompleted,
      isCancelled: isCancelled,
    );
  }

  /// Create a copy with updated fields
  SessionModel copyWith({
    String? id,
    DateTime? date,
    String? time,
    String? clientName,
    String? clientId,
    SessionType? type,
    String? aiNote,
    String? sessionNote,
    String? sessionId,
    bool? isCompleted,
    bool? isCancelled,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) {
    return SessionModel(
      id: id ?? this.id,
      date: date ?? this.date,
      time: time ?? this.time,
      clientName: clientName ?? this.clientName,
      clientId: clientId ?? this.clientId,
      type: type ?? this.type,
      aiNote: aiNote ?? this.aiNote,
      sessionNote: sessionNote ?? this.sessionNote,
      sessionId: sessionId ?? this.sessionId,
      isCompleted: isCompleted ?? this.isCompleted,
      isCancelled: isCancelled ?? this.isCancelled,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
    );
  }
}
