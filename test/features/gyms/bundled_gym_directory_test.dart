import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pler_to_pler_app/core/constants/enterprise_flags.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_gym_model.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/tenant_configuration.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('release defaults to the complete bundled gym directory', () {
    expect(isSingleMode, isTrue);

    final partners = EnterpriseGymModel.partners;
    final sorted = EnterpriseGymModel.sortForDirectory(partners);

    expect(partners.length, greaterThanOrEqualTo(25));
    expect(sorted, hasLength(partners.length));
    expect(sorted.map((gym) => gym.id).toSet(), hasLength(partners.length));
    expect(sorted.take(2).map((gym) => gym.id), [
      'p2p_fit_factor',
      'ymca_yonkers',
    ]);
    expect(sorted.last.id, 'kmf_fitness_club');
  });

  test('every catalog gym has an image registered in the Flutter bundle', () async {
    for (final gym in EnterpriseGymModel.partners) {
      final image = gym.stockPhotoAssetPath;
      expect(image, startsWith('assets/images/gym_photos/'),
          reason: '${gym.name} has no bundled facility image');
      final bytes = await rootBundle.load(image);
      expect(bytes.lengthInBytes, greaterThan(0),
          reason: '${gym.name} image could not be loaded from the bundle');
      expect(gym.displayGalleryAssetPaths, isNotEmpty);
    }
  });

  test('enterprise tenants expose every backend franchise location', () {
    final tenant = TenantConfiguration.fromJson({
      'schemaVersion': 1,
      'id': 'yogasix',
      'name': 'YogaSix',
      'slogan': 'Yoga for everyone',
      'logoUrl': 'https://example.com/yogasix.png',
      'timezone': 'America/New_York',
      'primaryColor': '#0D7377',
      'secondaryColor': '#FFFFFF',
      'accentColor': '#53B9AE',
      'photos': ['https://example.com/studio.jpg'],
      'locations': [
        {
          'id': 'yonkers',
          'name': 'YogaSix Yonkers',
          'address': '1 Main St',
          'city': 'Yonkers',
          'state': 'NY',
          'zipCode': '10701',
        },
        {
          'id': 'meriden',
          'name': 'YogaSix Meriden',
          'address': '2 Main St',
          'city': 'Meriden',
          'state': 'CT',
          'zipCode': '06450',
        },
      ],
      'contact': <String, dynamic>{},
    });

    final locations = tenant.toGyms();

    expect(locations, hasLength(2));
    expect(locations.map((gym) => gym.city), ['Yonkers', 'Meriden']);
    expect(locations.map((gym) => gym.franchiseKey).toSet(), {'yogasix'});
    expect(locations.map((gym) => gym.id).toSet(), hasLength(2));
  });
}
