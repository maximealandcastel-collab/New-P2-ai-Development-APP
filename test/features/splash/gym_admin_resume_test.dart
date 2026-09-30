import 'package:flutter_test/flutter_test.dart';
import 'package:pler_to_pler_app/features/splash/controllers/splash_controller.dart';

void main() {
  test('resumes the first valid gym-admin tenant for every gym', () {
    expect(resumedGymAdminTenantId(['kmf-fitness']), 'kmf-fitness');
    expect(resumedGymAdminTenantId(['ymca-yonkers']), 'ymca-yonkers');
    expect(
      resumedGymAdminTenantId([null, '', '  ', 'future-gym']),
      'future-gym',
    );
  });

  test('does not resume from malformed or empty cached scope', () {
    expect(resumedGymAdminTenantId(null), isNull);
    expect(resumedGymAdminTenantId('kmf-fitness'), isNull);
    expect(resumedGymAdminTenantId([null, '', 42]), isNull);
  });

  test('resumes the selected building only when its admin scope permits it', () {
    final gyms = ['ymca-yonkers', 'kmf-fitness'];
    expect(resumedGymAdminTenantId(gyms, preferredTenantId: 'kmf-fitness'),
        'kmf-fitness');
    expect(resumedGymAdminTenantId(gyms, preferredTenantId: 'other-gym'),
        'ymca-yonkers');
  });
}
