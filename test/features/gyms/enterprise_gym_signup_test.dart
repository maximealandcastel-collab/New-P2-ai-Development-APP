import 'package:flutter_test/flutter_test.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_gym_model.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/screens/enterprise_gym_signup_flow.dart';

void main() {
  test('YMCA and KMF are configured as distinct enterprise identities', () {
    final ymca = EnterpriseGymModel.partners.firstWhere(
      (gym) => gym.id == 'ymca_yonkers',
    );
    final kmf = EnterpriseGymModel.partners.firstWhere(
      (gym) => gym.id == 'kmf_fitness_club',
    );

    expect(ymca.tenantId, 'ymca-yonkers');
    expect(kmf.tenantId, 'kmf-fitness');
    expect(ymca.name, isNot(kmf.name));
    expect(ymca.brandColor, isNot(kmf.brandColor));
  });

  test('only members may self-register for a gym', () {
    expect(enterpriseRoleCanSelfRegister('Member'), isTrue);
    expect(enterpriseRoleCanSelfRegister('Trainer'), isFalse);
    expect(enterpriseRoleCanSelfRegister('Gym Staff'), isFalse);
    expect(enterpriseRoleCanSelfRegister('Admin'), isFalse);
  });

  test('enterprise password policy enforces all displayed requirements', () {
    expect(isStrongEnterprisePassword('StrongPass1'), isTrue);
    expect(isStrongEnterprisePassword('weakpass1'), isFalse);
    expect(isStrongEnterprisePassword('WEAKPASS1'), isFalse);
    expect(isStrongEnterprisePassword('WeakPassword'), isFalse);
    expect(isStrongEnterprisePassword('Short1A'), isFalse);
  });
}
