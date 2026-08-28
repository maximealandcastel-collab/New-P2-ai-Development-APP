import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:pler_to_pler_app/features/smarter_care/presentation/screens/smarter_care_screen.dart';

/// Guards the layout of the Fitness / Clinical choice cards.
///
/// The two cards size to their own content and Clinical has more of it, so the
/// Row centred them and the pair sat visibly misaligned. The fix is
/// CrossAxisAlignment.stretch — but this Row is a child of a Column, so its
/// height constraint is unbounded, and stretch against an unbounded cross axis
/// resolves to a *tight infinite* constraint, which throws:
///
///     BoxConstraints forces an infinite height
///
/// IntrinsicHeight is what makes it legal, by resolving the height to the
/// taller card before the Row lays out. Dropping it looks like a harmless
/// simplification and is not — hence this test.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets('choice cards lay out without an unbounded-constraint error',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    // Asset loading always fails under `flutter test` (there is no asset
    // bundle), and that is not what this test is about. Collect every error and
    // assert on the layout ones specifically, rather than on "any exception".
    final errors = <String>[];
    final previous = FlutterError.onError;
    FlutterError.onError = (details) => errors.add(details.toString());

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, __) => const GetMaterialApp(home: SmarterCareScreen()),
      ),
    );
    await tester.pump();

    // Restore BEFORE the first expect(). The binding asserts that a test which
    // overrode FlutterError.onError has put it back before any assertion runs;
    // doing this in addTearDown instead fails the test with a confusing
    // "_pendingExceptionDetails != null" and then hangs the suite.
    FlutterError.onError = previous;

    // Only unbounded-constraint errors are in scope here.
    //
    // Deliberately NOT asserting on RenderFlex overflow: the outer Column
    // overflows this test surface by 52px, but that is a pre-existing artifact
    // of the test font, whose glyphs are far wider than any real one, so the
    // copy wraps to more lines than it ever would on a device. Confirmed by
    // running this same test against the pre-change file: 52px there too, so
    // the restyle moved it by exactly zero pixels. Asserting on it would fail
    // for a reason that has nothing to do with this screen.
    final unboundedErrors =
        errors.where((e) => e.contains('infinite')).toList();

    expect(
      unboundedErrors,
      isEmpty,
      reason: 'the choice-card Row hit an unbounded-constraint error:\n'
          '${unboundedErrors.join("\n")}',
    );

    // The screen genuinely rendered, rather than passing by rendering nothing.
    expect(find.text('Fitness'), findsOneWidget);
    expect(find.text('Clinical'), findsOneWidget);
    expect(find.text('Coming Soon'), findsOneWidget);

    // Both cards share a height — the misalignment this layout was fixing.
    final fitness = tester.getRect(
      find.ancestor(of: find.text('Fitness'), matching: find.byType(Container)).first,
    );
    final clinical = tester.getRect(
      find.ancestor(of: find.text('Clinical'), matching: find.byType(Container)).first,
    );
    expect(fitness.height, clinical.height,
        reason: 'the two choice cards should be the same height');
    expect(fitness.top, clinical.top,
        reason: 'the two choice cards should be aligned at the top');
  });
}
