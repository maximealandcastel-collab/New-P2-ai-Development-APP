import 'package:pler_to_pler_app/features/gyms/presentation/screens/enterprise_gym_admin_dashboard_screen.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/tenant_configuration.dart';
import 'package:pler_to_pler_app/features/gyms/data/services/enterprise_service.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/screens/enterprise_session_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = FontLoader('Figtree')
      ..addFont(
        Future.value(
          ByteData.sublistView(
            await File('assets/fonts/Figtree-Regular.ttf').readAsBytes(),
          ),
        ),
      );
    await font.load();
    final packageConfig =
        jsonDecode(File('.dart_tool/package_config.json').readAsStringSync())
            as Map<String, dynamic>;
    final root = Uri.parse(packageConfig['flutterRoot'] as String).toFilePath();
    final icons = FontLoader('MaterialIcons')
      ..addFont(
        Future.value(
          ByteData.sublistView(
            await File(
              '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
            ).readAsBytes(),
          ),
        ),
      );
    await icons.load();
  });
  late EnterpriseService original;
  setUp(() => original = EnterpriseService.instance);
  tearDown(() => EnterpriseService.replaceForTesting(original));
  Future<void> mount(
    WidgetTester tester, {
    String file = 'kmf.tenant.json',
    bool fail = false,
    bool capture = false,
    bool legacy = false,
  }) async {
    tester.view.physicalSize = const Size(430, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final tenant =
        jsonDecode(File('test/enterprise/fixtures/$file').readAsStringSync())
            as Map<String, dynamic>;
    // Omit external test-image fetches; bundled KMF photos remain renderable.
    if (file.startsWith('abc')) {
      tenant['photos'] = <String>[];
      tenant['logoUrl'] = '';
    }
    final service = EnterpriseService(
      baseUrl: 'https://api.test',
      token: () => 'token',
      client: MockClient((r) async {
        if (legacy) expect(r.url.path, '/gym-admin/kmf-fitness/dashboard');
        if (fail) return http.Response('{}', 403);
        return http.Response(
          jsonEncode({
            'success': true,
            'data': r.url.path.endsWith('dashboard')
                ? {
                    'administrator': {'firstName': 'Alex', 'lastName': 'Owner'},
                    'counts': {
                      'signups': 10,
                      if (!legacy) 'members': 3,
                      'activeSubscriptions': 2,
                      'trainers': 1,
                    },
                    'recentSignups': [
                      {'name': 'Private member A'},
                    ],
                    'activeSubscriptions': [],
                    'recentTrainers': [],
                    'recentActivity': [],
                  }
                : {
                    'items': [
                      {
                        'id': 'member-a',
                        'name': 'Private member A',
                        'allowedActions': ['suspend'],
                      },
                    ],
                    'nextCursor': null,
                  },
          }),
          200,
        );
      }),
    );
    service.active.value = EnterpriseContext.fromJson({
      'tenant': tenant,
      'roles': ['admin'],
      'capabilities': [],
    });
    EnterpriseService.replaceForTesting(service);
    final boundary = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(fontFamily: 'Figtree'),
        home: RepaintBoundary(
          key: boundary,
          child: legacy
              ? const EnterpriseGymAdminDashboardScreen(legacyKmf: true)
              : const EnterpriseSessionScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    if (capture && file.startsWith('kmf')) {
      await tester.runAsync(() async {
        await precacheImage(
          AssetImage(tenant['logoUrl'] as String),
          boundary.currentContext!,
        );
        for (final path in tenant['photos'] as List) {
          await precacheImage(
            AssetImage(path as String),
            boundary.currentContext!,
          );
        }
      });
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
    if (capture) {
      await tester.runAsync(() async {
        final image =
            await (boundary.currentContext!.findRenderObject()
                    as RenderRepaintBoundary)
                .toImage();
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        await Directory('build/enterprise-review').create(recursive: true);
        await File(
          'build/enterprise-review/$file.png',
        ).writeAsBytes(data!.buffer.asUint8List());
        image.dispose();
      });
    }
  }

  testWidgets('KMF dashboard renders the shared template and distinct counts', (
    tester,
  ) async {
    await mount(tester, capture: true);
    expect(find.text('KMF Fitness Club'), findsWidgets);
    expect(find.text('Signups'), findsWidgets);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });
  testWidgets('second tenant renders the same dashboard without KMF text', (
    tester,
  ) async {
    await mount(tester, file: 'abc.example.tenant.json', capture: true);
    expect(find.text('ABC Fitness'), findsWidgets);
    expect(find.text('KMF Fitness Club'), findsNothing);
    expect(find.text('Signups'), findsWidgets);
    expect(find.text('3'), findsOneWidget);
  });
  testWidgets('revocation disposes protected nested navigation and records', (
    tester,
  ) async {
    await mount(tester);
    await tester.scrollUntilVisible(
      find.widgetWithText(ActionChip, 'Members'),
      200,
    );
    await tester.tap(find.widgetWithText(ActionChip, 'Members'));
    await tester.pumpAndSettle();
    expect(find.text('Private member A'), findsOneWidget);
    EnterpriseService.instance.clear();
    await tester.pumpAndSettle();
    expect(find.text('Private member A'), findsNothing);
    expect(find.text('Gym session'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('server permission denial shows the locked session', (
    tester,
  ) async {
    await mount(tester, fail: true);
    expect(find.text('Gym session'), findsOneWidget);
    expect(find.text('Private member A'), findsNothing);
  });
  testWidgets(
    'legacy KMF shares dashboard and uses only the protected old endpoint',
    (tester) async {
      await mount(tester, legacy: true);
      expect(find.text('KMF Fitness Club'), findsWidgets);
      expect(find.text('Signups'), findsOneWidget);
      expect(find.text('Members'), findsNothing);
      expect(find.byType(ActionChip), findsNothing);
      expect(find.byTooltip('Switch gym'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('legacy endpoint denial exposes no private records', (
    tester,
  ) async {
    await mount(tester, legacy: true, fail: true);
    expect(find.text('Private member A'), findsNothing);
    expect(find.text('Try again'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
