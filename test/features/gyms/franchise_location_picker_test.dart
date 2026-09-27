import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_gym_model.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/tenant_configuration.dart';
import 'package:pler_to_pler_app/features/gyms/data/services/enterprise_service.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/screens/gym_detail_screen.dart';

class _DirectoryStub extends EnterpriseService {
  @override
  Future<EnterprisePage> directory({
    String? cursor,
    String query = '',
    String? tag,
  }) async => EnterprisePage([
        {
          'schemaVersion': 1,
          'id': 'la-yonkers',
          'name': 'LA Fitness',
          'franchiseId': 'la_fitness',
          'franchiseName': 'LA Fitness',
          'timezone': 'America/New_York',
          'primaryColor': '#1A1A2E',
          'secondaryColor': '#FFFFFF',
          'accentColor': '#D4AF37',
          'locations': [
            {
              'id': 'yonkers',
              'name': 'LA Fitness Yonkers',
              'city': 'Yonkers',
              'state': 'NY',
              'address': '1 Main St, Yonkers, NY',
            },
          ],
        },
      ], null);

  @override
  Future<List<TenantConfiguration>> searchFacilities(
    String address, {
    double? latitude,
    double? longitude,
    String? kind,
  }) async => const [];
}

void main() {
  for (final brandId in [
    'equinox',
    'planet_fitness',
    'pure_barre',
    'hotworx',
    'yogasix',
  ]) {
    testWidgets('$brandId exposes city and state selection with one bundled entry',
        (tester) async {
      tester.view.physicalSize = const Size(1125, 2436);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final original = EnterpriseService.instance;
      EnterpriseService.replaceForTesting(_DirectoryStub());
      addTearDown(() => EnterpriseService.replaceForTesting(original));
      final gym = EnterpriseGymModel.partners.firstWhere((item) => item.id == brandId);

      await tester.pumpWidget(ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, __) => MaterialApp(
          home: GymDetailScreen(
            gym: gym,
            onOpenMaps: (_) {},
            onClaim: (_) {},
            onEnter: (_) {},
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Choose city, town or location'), findsOneWidget);
      await tester.tap(find.text('Choose city, town or location'));
      await tester.pumpAndSettle();
      expect(find.text('New York, NY'), findsOneWidget);
      expect(find.textContaining('${gym.name} locations'), findsOneWidget);
    });
  }

  testWidgets('a single bundled franchise opens cities and selects an onboarded branch',
      (tester) async {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final original = EnterpriseService.instance;
    EnterpriseService.replaceForTesting(_DirectoryStub());
    addTearDown(() => EnterpriseService.replaceForTesting(original));
    final laFitness = EnterpriseGymModel.partners
        .firstWhere((gym) => gym.id == 'la_fitness');
    EnterpriseGymModel? selected;

    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => MaterialApp(
        home: GymDetailScreen(
          gym: laFitness,
          onOpenMaps: (_) {},
          onClaim: (_) {},
          onEnter: (gym) { selected = gym; },
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Choose city, town or location'), findsOneWidget);
    await tester.tap(find.text('Choose city, town or location'));
    await tester.pumpAndSettle();
    expect(find.text('New York, NY'), findsOneWidget);
    expect(find.text('LA Fitness Yonkers'), findsWidgets);

    await tester.tap(find.text('LA Fitness Yonkers'));
    await tester.pumpAndSettle();
    expect(find.text('LA Fitness Yonkers'), findsWidgets);
    await tester.ensureVisible(find.text('Enter LA Fitness Yonkers'));
    await tester.tap(find.text('Enter LA Fitness Yonkers'));
    expect(selected?.id, 'la-yonkers');
  });
}
