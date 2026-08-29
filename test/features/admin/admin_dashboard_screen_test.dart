import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pler_to_pler_app/features/admin/presentation/controllers/admin_dashboard_controller.dart';
import 'package:pler_to_pler_app/features/admin/presentation/screens/admin_dashboard_screen.dart';

/// Regression guard for the Admin tab render failure.
///
/// AdminDashboardScreen's sliver list used to read:
///
///     Obx(() => SliverToBoxAdapter(child: _KpiGrid(c: c)))
///
/// which looks reactive but is not. The closure only *constructs* widgets;
/// _KpiGrid.build() — where c.metrics is actually read — runs later, in its own
/// element, outside the window in which GetX records observable reads
/// (RxInterface.notifyChildren sets the proxy, calls the builder, and throws if
/// nothing registered). GetX therefore threw ObxError, Flutter turned that into
/// an ErrorWidget, and because an ErrorWidget is a RenderBox sitting directly in
/// `slivers:`, the whole screen failed with:
///
///     A RenderViewport expected a child of type RenderSliver but received a
///     child of type RenderErrorBox
///
/// The screen renders with no metrics loaded here (every accessor is null-safe),
/// which is exactly the state the tab is in on first paint — the state that used
/// to fail. If someone reintroduces the wrapper, this test fails.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(Get.reset);

  testWidgets('renders its slivers without throwing ObxError', (tester) async {
    // The default 800x600 test surface is a tablet in landscape; ScreenUtil is
    // configured for a 375x812 phone, so leaving the default overflows the KPI
    // rows and masks the failure we actually care about with a RenderFlex error.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    // No network in a widget test: loadAll()'s Dio calls fail and are swallowed
    // by the controller's own try/catch, leaving metrics null and withdrawals
    // empty. That is the first-paint state we want to exercise.
    Get.put(AdminDashboardController());

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, __) => const GetMaterialApp(home: AdminDashboardScreen()),
      ),
    );
    await tester.pump();

    expect(
      tester.takeException(),
      isNull,
      reason: 'ObxError or a sliver/box mismatch escaped during build or layout',
    );
    expect(
      find.byType(ErrorWidget),
      findsNothing,
      reason: 'a section built an ErrorWidget instead of its content',
    );

    // The screen really rendered, rather than passing by rendering nothing.
    expect(find.text('Admin Dashboard'), findsOneWidget);
    expect(find.text('TOTAL TRAINERS'), findsOneWidget);

    // The viewport is lazy, so the lower sections have not been built yet —
    // and it was the viewport/sliver contract that used to blow up. Scroll the
    // whole list so every sliver is forced through layout at least once.
    for (final title in ['Quick Actions', 'Platform Overview', 'Trainer Management']) {
      await tester.scrollUntilVisible(
        find.text(title),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      expect(tester.takeException(), isNull, reason: 'threw while building "$title"');
      expect(find.text(title), findsOneWidget);
    }
    expect(find.byType(ErrorWidget), findsNothing);
  });
}
