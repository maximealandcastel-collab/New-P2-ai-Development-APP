import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pler_to_pler_app/core/themes/app_theme_data.dart';
import 'package:pler_to_pler_app/core/themes/brand_color_mapper.dart';
import 'package:pler_to_pler_app/core/themes/brand_colors.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/user/user_profile/presentation/user_profile_screen.dart';

void main() {
  testWidgets('open profile updates for two gyms, bright accents, and logout', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final accent = ValueNotifier<Color?>(const Color(0xFF168A3A));
    addTearDown(accent.dispose);
    final navigatorKey = GlobalKey<NavigatorState>();
    final previewKey = GlobalKey();
    const profile = UserProfileScreen();
    const previewFont = String.fromEnvironment('THEME_PREVIEW_FONT');
    if (previewFont.isNotEmpty) {
      await tester.runAsync(() async {
        final textFont = FontLoader('PreviewSans')
          ..addFont(File(previewFont).readAsBytes().then(ByteData.sublistView));
        final icons = FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
        await Future.wait([textFont.load(), icons.load()]);
      });
    }
    ThemeData themeFor(Color? color) {
      final theme = color == null
          ? AppThemeData.themeData
          : AppThemeData.forBrand(
              primaryColor: color,
              scaffoldBackground: const Color(0xFFF5F7F6),
            );
      return previewFont.isEmpty
          ? theme
          : theme.copyWith(
              textTheme: theme.textTheme.apply(fontFamily: 'PreviewSans'),
              primaryTextTheme: theme.primaryTextTheme.apply(
                fontFamily: 'PreviewSans',
              ),
            );
    }

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, _) => ValueListenableBuilder<Color?>(
          valueListenable: accent,
          builder: (_, color, _) => MaterialApp(
            navigatorKey: navigatorKey,
            theme: themeFor(color),
            home: const Scaffold(body: Text('Home')),
          ),
        ),
      ),
    );
    navigatorKey.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => RepaintBoundary(key: previewKey, child: profile),
      ),
    );
    await tester.pumpAndSettle();

    Container avatar() => tester.widget<Container>(
      find
          .ancestor(
            of: find.byIcon(Icons.person_outline).first,
            matching: find.byType(Container),
          )
          .first,
    );
    Container messageButton() => tester.widget<Container>(
      find
          .ancestor(of: find.text('Message'), matching: find.byType(Container))
          .first,
    );

    for (final entry in <String, Color?>{
      'green': const Color(0xFF168A3A),
      'purple': const Color(0xFF673AB7),
      'yellow': const Color(0xFFFFEB3B),
      'p2p': null,
    }.entries) {
      accent.value = entry.value;
      await tester.pumpAndSettle();
      final expected = entry.value ?? AppColors.primary;
      expect((avatar().decoration as BoxDecoration).color, expected);
      expect((messageButton().decoration as BoxDecoration).color, expected);
      expect(
        tester.widget<Icon>(find.byIcon(Icons.local_fire_department)).color,
        expected,
      );
      final context = tester.element(find.byType(UserProfileScreen));
      final palette = BrandColors.of(context);
      expect(
        tester.widget<Text>(find.text('Message')).style!.color,
        palette.onPrimary,
      );
      final header = tester
          .widgetList<Container>(find.byType(Container))
          .firstWhere(
            (widget) =>
                widget.decoration is BoxDecoration &&
                (widget.decoration as BoxDecoration).gradient != null,
          );
      expect(
        ((header.decoration as BoxDecoration).gradient as LinearGradient)
            .colors,
        [palette.headerStart, palette.headerEnd],
      );
      expect(tester.takeException(), isNull);

      const previewDir = String.fromEnvironment('THEME_PREVIEW_DIR');
      if (previewDir.isNotEmpty) {
        await tester.runAsync(() async {
          final boundary =
              previewKey.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 3);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await Directory(previewDir).create(recursive: true);
          await File(
            '$previewDir/profile-${entry.key}.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
    }
    expect(
      Theme.of(
        tester.element(find.byType(UserProfileScreen)),
      ).colorScheme.primary,
      AppColors.primary,
    );
  });

  test(
    'SVG accents change without recoloring neutral illustration details',
    () {
      const green = Color(0xFF168A3A);
      const purple = Color(0xFF673AB7);
      const mapper = BrandColorMapper(green);
      expect(
        mapper.substitute(null, 'path', 'fill', const Color(0xFFFD7B00)),
        green,
      );
      expect(
        mapper.substitute(null, 'path', 'fill', Colors.white),
        Colors.white,
      );
      expect(
        mapper.substitute(null, 'path', 'fill', const Color(0xFFE53935)),
        const Color(0xFFE53935),
      );
      expect(mapper, isNot(const BrandColorMapper(purple)));
      expect(
        mapper.substitute(null, 'path', 'fill', const Color(0xFFFEC28A)),
        Color.lerp(green, Colors.white, 0.55),
      );
    },
  );
}
