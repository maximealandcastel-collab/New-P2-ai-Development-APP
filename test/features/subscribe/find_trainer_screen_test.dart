import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/themes/app_theme_data.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/controllers/subscribe_controller.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/screens/find_trainer_screen.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/screens/widgets/find_trainer_shimmer.dart';

class _LoadingTrainersController extends GetxController
    implements SubscribeController {
  final state = LoadingState.initial.obs;

  @override
  LoadingState get loadingState => state.value;

  @override
  final selectedGender = 'all'.obs;

  @override
  final selectedSpecialty = 'all'.obs;

  @override
  Future<void> refresh() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  tearDown(Get.reset);

  for (final size in [
    const Size(320, 568),
    const Size(402, 874),
    const Size(844, 390),
  ]) {
    testWidgets('trainer loading grid fits and scrolls at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size * 3;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final controller = _LoadingTrainersController();
      Get.put<SubscribeController>(controller);
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (_, _) => GetMaterialApp(
            theme: AppThemeData.forBrand(
              primaryColor: const Color(0xFF168A3A),
              scaffoldBackground: Colors.white,
            ),
            home: const FindTrainerScreen(),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(FindTrainerShimmer), findsWidgets);
      controller.state.value = LoadingState.loading;
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);
      // A landscape grid cell can extend below the viewport: drag its visible
      // area rather than targeting the off-screen center of the whole card.
      await tester.dragFrom(
        Offset(size.width / 2, size.height - 30),
        const Offset(0, -300),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);
      final scroll = tester.state<NestedScrollViewState>(
        find.byType(NestedScrollView),
      );
      expect(
        scroll.outerController.offset + scroll.innerController.offset,
        greaterThan(0),
      );
      // Dispose the repeating shimmer without waiting for animations to settle.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
  }
}
