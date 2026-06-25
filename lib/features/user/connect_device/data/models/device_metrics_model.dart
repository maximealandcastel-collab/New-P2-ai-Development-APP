class DeviceMetricsSession {
  const DeviceMetricsSession({
    required this.steps,
    this.heartRate,
    this.distanceMeters,
    this.startedAt,
    this.endedAt,
    this.deviceType,
  });

  final int steps;
  final double? heartRate;
  final double? distanceMeters;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String? deviceType;

  factory DeviceMetricsSession.fromJson(Map<String, dynamic> json) {
    return DeviceMetricsSession(
      steps: _metricsParseInt(json['steps'] ?? json['totalSteps']),
      heartRate: _metricsParseDouble(json['heartRate'] ?? json['heart_rate']),
      distanceMeters: _metricsParseDouble(
        json['distanceMeters'] ?? json['distance_meters'] ?? json['distance'],
      ),
      startedAt: _metricsParseDate(
        json['startedAt'] ?? json['startTime'] ?? json['sessionStart'],
      ),
      endedAt: _metricsParseDate(
        json['endedAt'] ?? json['endTime'] ?? json['sessionEnd'],
      ),
      deviceType: json['deviceType']?.toString(),
    );
  }
}

class DeviceMetricsModel {
  const DeviceMetricsModel({
    this.steps = 0,
    this.heartRate,
    this.distanceMeters,
    this.deviceType,
    this.syncedAt,
    this.calories,
    this.activeMinutes,
    this.sessions = const [],
  });

  final int steps;
  final double? heartRate;
  final double? distanceMeters;
  final String? deviceType;
  final DateTime? syncedAt;
  final int? calories;
  final int? activeMinutes;
  final List<DeviceMetricsSession> sessions;

  bool get isEmpty =>
      steps == 0 &&
      heartRate == null &&
      distanceMeters == null &&
      calories == null &&
      activeMinutes == null &&
      sessions.isEmpty;

  factory DeviceMetricsModel.fromResponse(dynamic data) {
    if (data == null) return const DeviceMetricsModel();

    if (data is List) {
      if (data.isEmpty) return const DeviceMetricsModel();
      final first = data.first;
      if (first is Map<String, dynamic>) {
        return DeviceMetricsModel.fromJson(first);
      }
      return const DeviceMetricsModel();
    }

    if (data is Map<String, dynamic>) {
      return DeviceMetricsModel.fromJson(data);
    }

    return const DeviceMetricsModel();
  }

  factory DeviceMetricsModel.fromJson(Map<String, dynamic> json) {
    final metricsNode = json['metrics'];
    final metrics = metricsNode is Map<String, dynamic> ? metricsNode : json;

    final sessionsRaw = json['sessions'] ?? metrics['sessions'];
    final sessions = _parseSessions(sessionsRaw);

    return DeviceMetricsModel(
      steps: _metricsParseInt(metrics['steps'] ?? metrics['totalSteps'] ?? json['steps']),
      heartRate: _metricsParseDouble(
        metrics['heartRate'] ?? metrics['heart_rate'] ?? json['heartRate'],
      ),
      distanceMeters: _metricsParseDouble(
        metrics['distanceMeters'] ??
            metrics['distance_meters'] ??
            metrics['distance'] ??
            json['distanceMeters'],
      ),
      deviceType: metrics['deviceType']?.toString() ?? json['deviceType']?.toString(),
      syncedAt: _metricsParseDate(
        metrics['syncedAt'] ??
            metrics['synced_at'] ??
            json['syncedAt'] ??
            json['lastSyncedAt'],
      ),
      calories: _metricsParseInt(metrics['calories'] ?? json['calories']),
      activeMinutes: _metricsParseInt(
        metrics['activeMinutes'] ??
            metrics['active_minutes'] ??
            json['activeMinutes'],
      ),
      sessions: sessions,
    );
  }

  static List<DeviceMetricsSession> _parseSessions(dynamic raw) {
    if (raw is! List) return const [];

    return raw
        .whereType<Map>()
        .map((item) => DeviceMetricsSession.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .toList();
  }
}

int _metricsParseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.round();
  return int.tryParse(value.toString()) ?? 0;
}

double? _metricsParseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString());
}

DateTime? _metricsParseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
