import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/themes/app_theme_data.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/trainer_details_model.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/controllers/subscribe_controller.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/screens/trainer_profile_screen.dart';

class _PendingTrainerController extends GetxController
    implements SubscribeController {
  final state = LoadingState.initial.obs;
  final details = Rxn<TrainerDetailsModel>();
  final response = Completer<TrainerDetailsModel>();

  @override
  LoadingState get detailsLoadingState => state.value;

  @override
  TrainerDetailsModel? get trainerDetails => details.value;

  @override
  Future<void> refresh() async {}

  @override
  Future<void> fetchDetails(String trainerId, {bool showLoader = true}) async {
    state.value = LoadingState.loading;
    details.value = await response.future;
    state.value = LoadingState.loaded;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  tearDown(Get.reset);

  testWidgets(
    'trainer profile renders initial and pending slivers, then loaded content',
    (tester) async {
      tester.view.physicalSize = const Size(1206, 2622);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final controller = _PendingTrainerController();
      Get.put<SubscribeController>(controller);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, _) => GetMaterialApp(
            theme: AppThemeData.forBrand(
              primaryColor: const Color(0xFF168A3A),
              scaffoldBackground: Colors.white,
            ),
            home: const TrainerProfileScreen(),
          ),
        ),
      );
      // The first frame uses the initial state; the post-frame request remains pending.
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(milliseconds: 100));
      expect(controller.detailsLoadingState, LoadingState.loading);
      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(find.byType(SliverToBoxAdapter), findsWidgets);
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -150));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);

      controller.response.complete(
        TrainerDetailsModel(
          name: 'Test Trainer',
          specialty: 'Strength',
          bio: 'Strength coaching',
        ),
      );
      await tester.pumpAndSettle();
      expect(controller.detailsLoadingState, LoadingState.loaded);
      expect(find.byType(NestedScrollView), findsOneWidget);
      expect(find.text('Test Trainer'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
}
