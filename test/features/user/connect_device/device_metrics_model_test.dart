import 'package:flutter_test/flutter_test.dart';
import 'package:pler_to_pler_app/features/user/connect_device/data/models/device_metrics_model.dart';

void main() {
  group('DeviceMetricsModel', () {
    test('parses flat metrics payload', () {
      final model = DeviceMetricsModel.fromJson({
        'steps': 5420,
        'heartRate': 72.5,
        'distanceMeters': 3200,
        'deviceType': 'apple_watch_s3',
        'syncedAt': '2026-06-24T10:30:00.000Z',
        'calories': 180,
        'activeMinutes': 45,
      });

      expect(model.steps, 5420);
      expect(model.heartRate, 72.5);
      expect(model.distanceMeters, 3200);
      expect(model.deviceType, 'apple_watch_s3');
      expect(model.calories, 180);
      expect(model.activeMinutes, 45);
      expect(model.syncedAt, isNotNull);
    });

    test('parses nested metrics object', () {
      final model = DeviceMetricsModel.fromJson({
        'metrics': {
          'totalSteps': 4000,
          'heart_rate': 68,
          'distance_meters': 1500,
          'synced_at': '2026-06-24T08:00:00.000Z',
        },
      });

      expect(model.steps, 4000);
      expect(model.heartRate, 68);
      expect(model.distanceMeters, 1500);
    });

    test('parses sessions list', () {
      final model = DeviceMetricsModel.fromJson({
        'steps': 5000,
        'sessions': [
          {
            'steps': 3000,
            'heartRate': 70,
            'deviceType': 'apple_watch_s3',
            'startedAt': '2026-06-24T08:00:00.000Z',
          },
          {
            'steps': 2000,
            'heartRate': 75,
            'deviceType': 'fittech_a6',
          },
        ],
      });

      expect(model.sessions.length, 2);
      expect(model.sessions.first.steps, 3000);
      expect(model.sessions.last.deviceType, 'fittech_a6');
    });

    test('fromResponse handles list and empty data', () {
      expect(DeviceMetricsModel.fromResponse(null).isEmpty, isTrue);
      expect(DeviceMetricsModel.fromResponse([]).isEmpty, isTrue);

      final fromList = DeviceMetricsModel.fromResponse([
        {'steps': 100, 'heartRate': 60},
      ]);
      expect(fromList.steps, 100);
      expect(fromList.heartRate, 60);
    });

    test('isEmpty returns true for zeroed metrics', () {
      expect(const DeviceMetricsModel().isEmpty, isTrue);
    });
  });
}
