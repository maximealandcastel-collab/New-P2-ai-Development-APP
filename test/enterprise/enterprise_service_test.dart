import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_dashboard_data.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/tenant_configuration.dart';
import 'package:pler_to_pler_app/features/gyms/data/services/enterprise_service.dart';

Map<String, dynamic> config(String id) => {
  'schemaVersion': 1,
  'id': id,
  'name': '$id Fitness',
  'slogan': 'Move',
  'logoUrl': 'https://example.com/logo.png',
  'timezone': 'America/New_York',
  'primaryColor': '#102030',
  'secondaryColor': '#304050',
  'accentColor': '#39FF14',
  'photos': <String>[],
  'locations': <dynamic>[],
  'contact': <String, dynamic>{},
};
Map<String, dynamic> context(
  String id, {
  List<String> roles = const ['member'],
}) => {'tenant': config(id), 'roles': roles, 'capabilities': <String>[]};
http.Response ok(Map<String, dynamic> data) =>
    http.Response(jsonEncode({'success': true, 'data': data}), 200);
void main() {
  test(
    'dashboard counts remain distinct and incomplete counts fail closed',
    () {
      final data = EnterpriseDashboardData.fromJson({
        'counts': {
          'signups': 10,
          'members': 3,
          'activeSubscriptions': 2,
          'trainers': 1,
        },
      });
      expect(data.members, 3);
      expect(data.signups, 10);
      expect(
        () => EnterpriseDashboardData.fromJson({
          'counts': {'signups': 10},
        }),
        throwsFormatException,
      );
    },
  );
  test('dashboard accepts an omitted optional members metric', () {
    final data = EnterpriseDashboardData.fromJson({
      'counts': {'signups': 10, 'activeSubscriptions': 2, 'trainers': 1},
    }, requireMembers: false);
    expect(data.members, isNull);
    expect(data.signups, 10);
  });
  test('KMF seed and a second gym use the same configuration model', () {
    for (final file in ['kmf.tenant.json', 'abc.example.tenant.json']) {
      final tenant = TenantConfiguration.fromJson(
        jsonDecode(File('test/enterprise/fixtures/$file').readAsStringSync())
            as Map<String, dynamic>,
      );
      expect(tenant.toGym().tenantId, tenant.id);
      expect(tenant.toGym().logoUrl, tenant.logoUrl);
      expect(tenant.toGym().isActivated, true);
    }
  });
  test(
    'configuration rejects unsupported versions and falls back for invalid colors',
    () {
      expect(
        () =>
            TenantConfiguration.fromJson({...config('a'), 'schemaVersion': 9}),
        throwsFormatException,
      );
      expect(
        TenantConfiguration.fromJson({
          ...config('a'),
          'accentColor': 'green',
        }).accent.toARGB32(),
        0xFFB83B12,
      );
    },
  );
  test(
    'directory is public, encoded and paginated without activating a gym',
    () async {
      final service = EnterpriseService(
        baseUrl: 'https://api.test',
        token: () => 'secret',
        client: MockClient((request) async {
          expect(request.headers['Authorization'], isNull);
          expect(request.url.queryParameters['cursor'], 'a&b');
          expect(request.url.queryParameters['q'], 'ABC Fitness');
          return ok({
            'items': [config('abc')],
            'nextCursor': 'next',
          });
        }),
      );
      final page = await service.directory(cursor: 'a&b', query: 'ABC Fitness');
      expect(page.nextCursor, 'next');
      expect(service.active.value, isNull);
    },
  );
  test(
    'restore trusts current server context rather than cached selection',
    () async {
      final service = EnterpriseService(
        baseUrl: 'https://api.test',
        token: () => 'token',
        client: MockClient((r) async => ok({'context': context('b')})),
      );
      service.active.value = EnterpriseContext.fromJson(context('a'));
      await service.restore();
      expect(service.active.value!.tenant.id, 'b');
    },
  );
  test('member cannot issue an admin operation', () {
    final service = EnterpriseService(token: () => 'token');
    service.active.value = EnterpriseContext.fromJson(context('a'));
    expect(
      () => service.scoped('members', admin: true),
      throwsA(isA<EnterpriseException>()),
    );
  });
  test('scoped route includes authorized tenant and bearer token', () async {
    final service = EnterpriseService(
      baseUrl: 'https://api.test',
      token: () => 'token',
      client: MockClient((r) async {
        expect(r.url.path, '/enterprise/tenants/a/admin/dashboard');
        expect(r.headers['Authorization'], 'Bearer token');
        return ok({
          'counts': {'signups': 8, 'members': 3},
        });
      }),
    );
    service.active.value = EnterpriseContext.fromJson(
      context('a', roles: ['admin']),
    );
    final result = await service.scoped('dashboard', admin: true);
    expect(result['counts']['signups'], 8);
    expect(result['counts']['members'], 3);
  });
  test('old tenant response cannot complete after switching', () async {
    final pending = Completer<http.Response>();
    final service = EnterpriseService(
      baseUrl: 'https://api.test',
      token: () => 'token',
      client: MockClient((r) async {
        if (r.method == 'PUT') return ok({'context': context('b')});
        return pending.future;
      }),
    );
    service.active.value = EnterpriseContext.fromJson(context('a'));
    final old = service.scoped('content');
    final assertion = expectLater(old, throwsA(isA<EnterpriseException>()));
    await service.switchTenant('b');
    pending.complete(
      ok({
        'items': [
          {'id': 'private-a'},
        ],
        'nextCursor': null,
      }),
    );
    await assertion;
    expect(service.active.value!.tenant.id, 'b');
  });
  test('revocation removes active branding and data context', () async {
    final service = EnterpriseService(
      baseUrl: 'https://api.test',
      token: () => 'token',
      client: MockClient((r) async => http.Response('{}', 403)),
    );
    service.active.value = EnterpriseContext.fromJson(context('a'));
    await expectLater(
      service.scoped('content'),
      throwsA(isA<EnterpriseException>()),
    );
    expect(service.active.value, isNull);
  });
  test('failed switch clears old context and never falls back to it', () async {
    final service = EnterpriseService(
      baseUrl: 'https://api.test',
      token: () => 'token',
      client: MockClient((r) async => http.Response('{}', 500)),
    );
    service.active.value = EnterpriseContext.fromJson(context('a'));
    await expectLater(
      service.switchTenant('b'),
      throwsA(isA<EnterpriseException>()),
    );
    expect(service.active.value, isNull);
  });
  test(
    'logout during switch cannot reactivate an old authenticated session',
    () async {
      final pending = Completer<http.Response>();
      final service = EnterpriseService(
        baseUrl: 'https://api.test',
        token: () => 'token',
        client: MockClient((r) => pending.future),
      );
      final switching = service.switchTenant('a');
      final assertion = expectLater(
        switching,
        throwsA(isA<EnterpriseException>()),
      );
      service.clear();
      pending.complete(ok({'context': context('a')}));
      await assertion;
      expect(service.active.value, isNull);
    },
  );
  test(
    'overlapping switches are rejected and mismatched response cannot activate',
    () async {
      final pending = Completer<http.Response>();
      final service = EnterpriseService(
        baseUrl: 'https://api.test',
        token: () => 'token',
        client: MockClient((r) => pending.future),
      );
      final first = service.switchTenant('a');
      final assertion = expectLater(first, throwsA(isA<EnterpriseException>()));
      await expectLater(
        service.switchTenant('b'),
        throwsA(isA<EnterpriseException>()),
      );
      pending.complete(ok({'context': context('b')}));
      await assertion;
      expect(service.active.value, isNull);
    },
  );
  test('personal context is explicitly acknowledged by server', () async {
    final service = EnterpriseService(
      baseUrl: 'https://api.test',
      token: () => 'token',
      client: MockClient((r) async {
        expect(jsonDecode(r.body), {'tenantId': null});
        return ok({'context': null});
      }),
    );
    await service.switchTenant(null);
    expect(service.active.value, isNull);
  });
}
