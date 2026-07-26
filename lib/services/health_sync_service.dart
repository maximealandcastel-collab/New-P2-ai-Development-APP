import 'dart:developer';
import 'dart:io';

import 'package:health/health.dart';
import 'package:pler_to_pler_app/services/api_urls.dart';
import 'package:pler_to_pler_app/services/network/api_client.dart';

/// Syncs watch/health data (Apple Health on iOS — which receives Apple Watch
/// data automatically — and Health Connect on Android, which receives
/// Wear OS / Samsung / Fitbit / Garmin data) to the P2P FitTech AI backend.
class HealthSyncService {
  HealthSyncService._();
  static final HealthSyncService instance = HealthSyncService._();

  final Health _health = Health();

  static const List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WORKOUT,
  ];

  String? _pairedDeviceId;
  String? get pairedDeviceId => _pairedDeviceId;

  /// Ask the OS for permission to read health data.
  /// Returns true when the user granted access.
  Future<bool> requestPermissions() async {
    try {
      await _health.configure();
      final granted = await _health.requestAuthorization(
        _types,
        permissions: _types.map((_) => HealthDataAccess.READ).toList(),
      );
      log('Health permissions granted: $granted');
      return granted;
    } catch (e) {
      log('Health permission error: $e');
      return false;
    }
  }

  /// Register this phone/watch as a paired device on the backend.
  /// Returns the backend device id, or null on failure.
  Future<String?> pairDevice() async {
    try {
      final response = await ApiClient.postData(ApiUrls.devicePair, {
        'name': Platform.isIOS ? 'Apple Health (Apple Watch)' : 'Health Connect (Android watch)',
        'type': Platform.isIOS ? 'apple_health' : 'health_connect',
        'platform': Platform.operatingSystem,
      });
      if (response.statusCode == 200 && response.body is Map) {
        final data = (response.body as Map)['data'];
        final id = data is Map ? (data['_id'] ?? data['id'])?.toString() : null;
        _pairedDeviceId = id;
        return id;
      }
    } catch (e) {
      log('pairDevice error: $e');
    }
    return null;
  }

  /// Read the last [days] days of health data and push it to the backend.
  /// Returns a human-readable summary, or null on failure.
  Future<Map<String, num>?> syncMetrics({int days = 7}) async {
    final deviceId = _pairedDeviceId;
    if (deviceId == null) return null;
    try {
      final now = DateTime.now();
      final start = now.subtract(Duration(days: days));

      final steps = await _health.getTotalStepsInInterval(start, now) ?? 0;

      final points = await _health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE, HealthDataType.ACTIVE_ENERGY_BURNED],
        startTime: start,
        endTime: now,
      );

      double heartRateSum = 0;
      int heartRateCount = 0;
      double calories = 0;
      for (final p in points) {
        final value = p.value;
        if (value is NumericHealthValue) {
          if (p.type == HealthDataType.HEART_RATE) {
            heartRateSum += value.numericValue.toDouble();
            heartRateCount++;
          } else if (p.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
            calories += value.numericValue.toDouble();
          }
        }
      }
      final avgHeartRate =
          heartRateCount == 0 ? 0 : (heartRateSum / heartRateCount).round();

      final response = await ApiClient.postData(
        ApiUrls.deviceMetrics(deviceId),
        {
          'from': start.toIso8601String(),
          'to': now.toIso8601String(),
          'steps': steps,
          'heartRate': avgHeartRate,
          'calories': calories.round(),
        },
      );
      if (response.statusCode == 200) {
        return {
          'steps': steps,
          'heartRate': avgHeartRate,
          'calories': calories.round(),
        };
      }
    } catch (e) {
      log('syncMetrics error: $e');
    }
    return null;
  }
}
