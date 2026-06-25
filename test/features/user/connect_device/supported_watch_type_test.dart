import 'package:flutter_test/flutter_test.dart';
import 'package:pler_to_pler_app/features/user/connect_device/domain/constants/supported_watch_type.dart';

void main() {
  group('SupportedWatchType', () {
    test('matches FitTech A6 BLE names', () {
      final type = SupportedWatchType.fittechA6;

      expect(type.matchesBleName('FitTech A6'), isTrue);
      expect(type.matchesBleName('FITTECH-A6'), isTrue);
      expect(type.matchesBleName('Random Speaker'), isFalse);
    });

    test('matches Fit S3 Ultra BLE names', () {
      final type = SupportedWatchType.fitS3Ultra;

      expect(type.matchesBleName('Fit S3 Ultra'), isTrue);
      expect(type.matchesBleName('FITS3'), isTrue);
      expect(type.matchesBleName('Galaxy Watch'), isFalse);
    });

    test('Apple Watch does not match BLE names', () {
      final type = SupportedWatchType.appleWatchS3;

      expect(type.matchesBleName('Apple Watch'), isFalse);
      expect(type.usesHealthKit, isTrue);
    });

    test('fromApiValue resolves backend strings', () {
      expect(
        SupportedWatchType.fromApiValue('apple_watch_s3'),
        SupportedWatchType.appleWatchS3,
      );
      expect(
        SupportedWatchType.fromApiValue('fittech_a6'),
        SupportedWatchType.fittechA6,
      );
      expect(
        SupportedWatchType.fromApiValue('fit_s3_ultra'),
        SupportedWatchType.fitS3Ultra,
      );
      expect(SupportedWatchType.fromApiValue('unknown'), isNull);
    });
  });
}
