import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/legacy_kmf_configuration.dart';
import 'package:pler_to_pler_app/features/gyms/data/services/enterprise_service.dart';

http.Response directoryFixtureResponse() => http.Response(
  jsonEncode({
    'success': true,
    'data': {
      'items': [legacyKmfConfiguration],
      'nextCursor': null,
    },
  }),
  200,
);
EnterpriseService directoryFixtureService() => EnterpriseService(
  baseUrl: 'https://directory.example.test',
  client: MockClient((_) async => directoryFixtureResponse()),
);
