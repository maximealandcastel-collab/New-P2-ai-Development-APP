import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pler_to_pler_app/core/themes/enterprise_gym_theme.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/tenant_configuration.dart';

void main() {
  test('a bright gym hue keeps its identity with readable mesh and white surface', () {
    final theme = EnterpriseGymTheme.fromColors(
      primary: const Color(0xFF080908), accent: const Color(0xFF39FF14));
    expect(HSVColor.fromColor(theme.primaryBrandColor).hue, inInclusiveRange(100, 120));
    expect(theme.meshEnd.computeLuminance(), lessThanOrEqualTo(.18));
    expect(theme.surfaceTint.computeLuminance(), greaterThan(.8));
    expect(theme.textOnGradient, Colors.white);
  });

  test('franchise locations inherit brand unless a local override is approved', () {
    final tenant = TenantConfiguration.fromJson({
      'schemaVersion': 1, 'id': 'franchise', 'name': 'Franchise',
      'timezone': 'UTC', 'logoUrl': 'https://example.com/brand.png',
      'primaryColor': '#006CB7', 'secondaryColor': '#FFFFFF',
      'accentColor': '#004C82',
      'locations': [
        {'id': 'a', 'brandThemeOverride': {
          'approved': false, 'primaryBrandColor': '#50B424'}},
        {'id': 'b', 'brandThemeOverride': {
          'approved': true, 'primaryBrandColor': '#50B424'}},
      ],
    });
    final gyms = tenant.toGyms();
    expect(gyms.first.brandColor, const Color(0xFF006CB7));
    expect(gyms.last.brandColor, const Color(0xFF50B424));
    expect(gyms.every((gym) => gym.logoUrl == tenant.logoUrl), isTrue);
  });
}
