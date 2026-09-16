import 'package:flutter_test/flutter_test.dart';
import 'package:pler_to_pler_app/core/constants/api_constants.dart';

void main() {
  test('production clients must share the configured origin and API path', () {
    ApiConstants.validateProductionOrigins('${ApiConstants.baseUrl}/api/v1', ApiConstants.baseUrl);
    expect(() => ApiConstants.validateProductionOrigins('https://other.example/api/v1', ApiConstants.baseUrl), throwsStateError);
    expect(() => ApiConstants.validateProductionOrigins('${ApiConstants.baseUrl}/api', ApiConstants.baseUrl), throwsStateError);
    expect(() => ApiConstants.validateProductionOrigins('${ApiConstants.baseUrl}/api/v1', 'http://localhost:3000'), throwsStateError);
  });
}
