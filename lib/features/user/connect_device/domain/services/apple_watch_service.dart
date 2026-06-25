import 'dart:io';

import 'package:health/health.dart';
import 'package:pler_to_pler_app/features/user/connect_device/data/models/device_metrics_payload.dart';
import 'package:pler_to_pler_app/features/user/connect_device/domain/constants/supported_watch_type.dart';

class AppleWatchService {
  AppleWatchService() : _health = Health();

  final Health _health;

  static const _types = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
  ];

  static const _permissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  bool get isAvailable => Platform.isIOS;

  Future<void> _configure() async {
    if (!Platform.isIOS) return;
    await _health.configure();
  }

  Future<bool> requestAuthorization() async {
    if (!Platform.isIOS) return false;

    await _configure();
    return await _health.requestAuthorization(
      _types,
      permissions: _permissions,
    );
  }

  Future<bool> hasPermissions() async {
    if (!Platform.isIOS) return false;
    await _configure();
    return await _health.hasPermissions(_types, permissions: _permissions) ??
        false;
  }

  Future<DeviceMetricsPayload> fetchTodayMetrics() async {
    if (!Platform.isIOS) {
      throw Exception('Apple Watch sync is only available on iPhone');
    }

    await _configure();

    if (!await hasPermissions()) {
      final granted = await requestAuthorization();
      if (!granted) {
        throw Exception('Health permission is required to read Apple Watch data');
      }
    }

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);

    final steps = await _getSteps(start, now);
    final heartRate = await _getHeartRate(start, now);

    return DeviceMetricsPayload(
      steps: steps,
      heartRate: heartRate,
      deviceType: SupportedWatchType.appleWatchS3.apiValue,
      syncedAt: now,
    );
  }

  Future<int> _getSteps(DateTime start, DateTime end) async {
    final data = await _health.getHealthDataFromTypes(
      types: [HealthDataType.STEPS],
      startTime: start,
      endTime: end,
    );

    double total = 0;
    for (final point in data) {
      if (point.type == HealthDataType.STEPS) {
        total += (point.value as NumericHealthValue).numericValue;
      }
    }
    return total.round();
  }

  Future<double?> _getHeartRate(DateTime start, DateTime end) async {
    final data = await _health.getHealthDataFromTypes(
      types: [HealthDataType.HEART_RATE],
      startTime: start,
      endTime: end,
    );

    final readings = data
        .where((point) => point.type == HealthDataType.HEART_RATE)
        .toList();
    if (readings.isEmpty) return null;

    readings.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
    return (readings.first.value as NumericHealthValue).numericValue.toDouble();
  }

  String getDeviceSerial() => 'apple_watch_healthkit';
}
