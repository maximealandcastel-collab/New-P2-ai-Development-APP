# Home branding contract for future gym builds

Every gym home screen must show the active gym logo and name below the greeting,
before workout progress or client statistics. This placement is built into the
shared home screens using `lib/features/home/widgets/home_gym_brand.dart`.
On the member home, place the brand first and the Achievements pill second in
the same horizontal row using `HomeGymBrand(trailing: _AchievementsPill())`.
Use the compact logo and name sizing provided by the shared widget. Do not add
outer padding to the pill or move it to a separate row.

## Instructions for the gym-building bot

- Preserve `HomeGymBrand` in `UserHomeScreen`, `TrainerHomeScreen`, and the legacy
  `HomeScreen`. Reuse it in any new gym home layout.
- Supply the gym's own `name` and `logoUrl` in its tenant configuration, following
  `tenant.schema.json` and `scripts/provision-enterprise.mjs`. Do not copy KMF's
  branding into another gym or add per-gym home-screen branches.
- Branding comes from `TenantBrandService.activeBrand`. Enterprise context changes
  refresh the strip automatically. Legacy single mode uses the bundled KMF logo
  only for cached tenant `kmf-fitness`. Future gyms use enterprise mode
  (`--dart-define=IS_SINGLE_MODE=false`) and their authorized tenant context.
- Use an `assets/` image path registered in `pubspec.yaml`, or a public HTTPS image
  URL. Provisioning uploads bundled images and substitutes server URLs.
- Keep the complete logo visible with `BoxFit.contain`, a white backing, and an
  accessible label. Keep the personal avatar and notifications separate.
- Personal mode without an active gym hides the brand but keeps Achievements.
  Unavailable images use
  `TenantImage`'s fitness icon fallback while retaining the gym name.

Before delivering a gym build, verify member and trainer homes show its logo,
long names fit on narrow phones, switching tenants replaces branding, and leaving
gym mode removes it. Check both bundled and HTTPS logos. The dedicated enterprise
admin dashboard already has its own gym logo header.
