import 'package:flutter_test/flutter_test.dart';
import 'package:pler_to_pler_app/core/constants/enterprise_flags.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_gym_model.dart';

void main() {
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
}
