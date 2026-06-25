class DeviceMetricsPayload {
  const DeviceMetricsPayload({
    required this.steps,
    this.heartRate,
    this.distanceMeters,
    required this.deviceType,
    required this.syncedAt,
  });

  final int steps;
  final double? heartRate;
  final double? distanceMeters;
  final String deviceType;
  final DateTime syncedAt;

  Map<String, dynamic> toJson() => {
        'steps': steps,
        if (heartRate != null) 'heartRate': heartRate,
        if (distanceMeters != null) 'distanceMeters': distanceMeters,
        'deviceType': deviceType,
        'syncedAt': syncedAt.toIso8601String(),
      };
}
