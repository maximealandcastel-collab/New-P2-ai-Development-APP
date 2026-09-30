import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pler_to_pler_app/core/themes/enterprise_gym_theme.dart';
import 'package:pler_to_pler_app/widgets/logout_dialog.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/tenant_configuration.dart';
import 'package:pler_to_pler_app/features/gyms/data/services/enterprise_service.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/screens/enterprise_session_screen.dart';

void main() {
  testWidgets('logout keeps gym colors and prevents repeat submissions', (tester) async {
    final pending = Completer<void>();
    var calls = 0;
    final theme = EnterpriseGymTheme.fromColors(primary: Colors.blue);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: LogoutDialog(
      theme: theme,
      onLogout: () { calls++; return pending.future; },
    ))));
    await tester.tap(find.text('Log out'));
    await tester.pump();
    expect(find.text('Logging out…'), findsOneWidget);
    await tester.tap(find.text('Logging out…'));
    expect(calls, 1);
    final box = tester.widget<DecoratedBox>(find.byKey(const ValueKey('logout-gradient')));
    expect((box.decoration as BoxDecoration).gradient, theme.ctaGradient);
    pending.completeError(StateError('test failure'));
    await tester.pumpAndSettle();
    expect(find.text('Could not log out. Please try again.'), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);
  });

  testWidgets('access refresh preserves open page state for the same gym', (tester) async {
    final original = EnterpriseService.instance;
    final service = EnterpriseService(token: () => null);
    EnterpriseService.replaceForTesting(service);
    addTearDown(() => EnterpriseService.replaceForTesting(original));
    final tenant = Map<String, dynamic>.from(jsonDecode(
      File('test/enterprise/fixtures/kmf.tenant.json').readAsStringSync()) as Map);
    EnterpriseContext session() => EnterpriseContext.fromJson({
      'tenant': tenant, 'roles': ['member'], 'capabilities': [],
    });
    service.active.value = session();
    await tester.pumpWidget(MaterialApp(home: EnterpriseSessionScreen(
      flagshipBuilder: (_) => const TextField(),
    )));
    await tester.enterText(find.byType(TextField), 'Keep this page');
    service.active.value = session();
    await tester.pump();
    expect(find.text('Keep this page'), findsOneWidget);
    service.clear();
    await tester.pump();
    expect(find.text('Keep this page'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
