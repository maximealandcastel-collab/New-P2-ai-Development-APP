import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/tenant_configuration.dart';
import 'package:pler_to_pler_app/features/gyms/data/services/enterprise_service.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/screens/enterprise_module_screen.dart';

void main() {
  for (final module in enterpriseModules) {
    testWidgets(
      '${module.title}: refresh, editor and record actions are connected',
      (tester) async {
        final original = EnterpriseService.instance;
        addTearDown(() => EnterpriseService.replaceForTesting(original));
        final requests = <http.Request>[];
        final service = EnterpriseService(
          baseUrl: 'https://test.invalid/api/v1',
          token: () => 'test-only',
          client: MockClient((request) async {
            requests.add(request);
            return http.Response(
              jsonEncode({
                'success': true,
                'data': request.method == 'GET'
                    ? {
                        'items': [
                          {
                            'id': 'record-a',
                            'name': 'Test record',
                            'allowedActions': module.actions
                                .map((a) => a.path)
                                .toList(),
                          },
                        ],
                        'nextCursor': null,
                      }
                    : <String, dynamic>{},
              }),
              200,
            );
          }),
        );
        service.active.value = EnterpriseContext.fromJson({
          'tenant': jsonDecode(
            File('test/enterprise/fixtures/kmf.tenant.json').readAsStringSync(),
          ),
          'roles': ['admin'],
          'capabilities': [],
        });
        EnterpriseService.replaceForTesting(service);
        await tester.pumpWidget(
          MaterialApp(home: EnterpriseModuleScreen(module: module)),
        );
        await tester.pumpAndSettle();
        final base =
            '/api/v1/enterprise/tenants/kmf-fitness/admin/${module.resource}';
        expect(requests.single.url.path, base);
        await tester.tap(find.byTooltip('Refresh'));
        await tester.pumpAndSettle();
        expect(requests.length, 2);
        if (module.createLabel != null) {
          await tester.tap(find.text(module.createLabel!));
          await tester.pumpAndSettle();
          expect(find.byType(EnterpriseEditor), findsOneWidget);
          await tester.scrollUntilVisible(
            find.text('Save'),
            400,
            scrollable: find
                .descendant(
                  of: find.byType(EnterpriseEditor),
                  matching: find.byType(Scrollable),
                )
                .first,
          );
          expect(find.text('Save'), findsOneWidget);
          await tester.pageBack();
          await tester.pumpAndSettle();
          expect(requests.where((r) => r.method != 'GET'), isEmpty);
        }
        for (final action in module.actions) {
          await tester.ensureVisible(
            find.widgetWithText(TextButton, action.label),
          );
          await tester.tap(find.widgetWithText(TextButton, action.label));
          await tester.pumpAndSettle();
          expect(find.byType(AlertDialog), findsOneWidget);
          await tester.tap(find.widgetWithText(TextButton, 'Keep unchanged'));
          await tester.pumpAndSettle();
          final count = requests.length;
          await tester.tap(find.widgetWithText(TextButton, action.label));
          await tester.pumpAndSettle();
          expect(requests.length, count);
          await tester.tap(find.widgetWithText(FilledButton, action.label));
          await tester.pumpAndSettle();
          final write = requests[count];
          expect(write.method, 'POST');
          expect(write.url.path, '$base/record-a/${action.path}');
          expect(jsonDecode(write.body), isEmpty);
          expect(requests.last.method, 'GET');
        }
        if (module.resource == 'analytics') {
          await tester.tap(find.byTooltip('Date range'));
          await tester.pumpAndSettle();
          expect(find.byType(DateRangePickerDialog), findsOneWidget);
          await tester.tap(find.byTooltip('Close'));
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
}
