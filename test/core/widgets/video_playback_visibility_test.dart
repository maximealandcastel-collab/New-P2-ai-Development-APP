import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pler_to_pler_app/core/widgets/video_playback_visibility.dart';

void main() {
  testWidgets('playback follows tab, route, and foreground state', (
    tester,
  ) async {
    final navigator = GlobalKey<NavigatorState>();
    final changes = <bool>[];
    late StateSetter updateTab;
    var selected = 0;

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        home: StatefulBuilder(
          builder: (context, setState) {
            updateTab = setState;
            return IndexedStack(
              index: selected,
              children: [
                const SizedBox(),
                TickerMode(
                  enabled: selected == 1,
                  child: VideoPlaybackVisibility(
                    onVisibilityChanged: changes.add,
                    child: const SizedBox.expand(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
    expect(changes, [false]);

    updateTab(() => selected = 1);
    await tester.pump();
    expect(changes.last, isTrue);

    // An unnamed, transparent route must also stop playback underneath it.
    navigator.currentState!.push(
      PageRouteBuilder<void>(
        opaque: false,
        pageBuilder: (_, _, _) => const SizedBox.expand(),
      ),
    );
    await tester.pumpAndSettle();
    expect(changes.last, isFalse);
    navigator.currentState!.pop();
    await tester.pumpAndSettle();
    expect(changes.last, isTrue);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    expect(changes.last, isFalse);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    expect(changes.last, isTrue);

    updateTab(() => selected = 0);
    await tester.pump();
    expect(changes.last, isFalse);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(changes.last, isFalse);
    expect(changes, [false, true, false, true, false, true, false]);
  });
}
