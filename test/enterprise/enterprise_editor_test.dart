import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pler_to_pler_app/features/gyms/data/services/enterprise_service.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/tenant_configuration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/screens/enterprise_module_screen.dart';

void main() {
  testWidgets('plan editor validates a positive duration before submission', (
    tester,
  ) async {
    final module = enterpriseModules.firstWhere((m) => m.resource == 'plans');
    await tester.pumpWidget(
      MaterialApp(
        home: EnterpriseEditor(title: 'Create plan', fields: module.fields),
      ),
    );
    await tester.enterText(find.byType(TextFormField).at(0), 'Monthly');
    await tester.enterText(find.byType(TextFormField).at(2), '-1');
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Enter a positive whole number'), findsOneWidget);
  });
  testWidgets('facility editor rejects invalid branding input', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EnterpriseEditor(
          title: 'Branding',
          fields: [
            EnterpriseField('accentColor', 'Accent', type: 'color'),
            EnterpriseField('logoUrl', 'Logo', type: 'url'),
          ],
        ),
      ),
    );
    await tester.enterText(find.byType(TextFormField).at(0), 'green');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'javascript:alert(1)',
    );
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Use #RRGGBB'), findsOneWidget);
    expect(find.text('Use HTTPS URLs'), findsOneWidget);
  });
  testWidgets('record picker shows a name but submits its tenant record ID', (
    tester,
  ) async {
    final original = EnterpriseService.instance;
    addTearDown(() => EnterpriseService.replaceForTesting(original));
    final service = EnterpriseService(
      baseUrl: 'https://api.test',
      token: () => 'token',
      client: MockClient(
        (r) async => http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'items': [
                {'id': 'membership-private-id', 'name': 'Jamie Member'},
              ],
              'nextCursor': null,
            },
          }),
          200,
        ),
      ),
    );
    service.active.value = EnterpriseContext.fromJson({
      'tenant': jsonDecode(
        File('test/enterprise/fixtures/kmf.tenant.json').readAsStringSync(),
      ),
      'roles': ['admin'],
      'capabilities': [],
    });
    EnterpriseService.replaceForTesting(service);
    Map<String, dynamic>? submitted;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                submitted = await Navigator.of(context)
                    .push<Map<String, dynamic>>(
                      MaterialPageRoute(
                        builder: (_) => const EnterpriseEditor(
                          title: 'Assign plan',
                          fields: [
                            EnterpriseField(
                              'membershipId',
                              'Member',
                              type: 'members',
                            ),
                          ],
                        ),
                      ),
                    );
              },
              child: const Text('Open editor'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open editor'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jamie Member'));
    await tester.pumpAndSettle();
    expect(find.text('membership-private-id'), findsNothing);
    expect(find.widgetWithText(TextFormField, 'Jamie Member'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(submitted, {'membershipId': 'membership-private-id'});
  });
}
