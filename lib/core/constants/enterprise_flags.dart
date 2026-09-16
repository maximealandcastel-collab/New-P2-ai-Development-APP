/// true: use the bundled gym partner directory.
/// false: use the shared live enterprise directory endpoint.
///
/// Keep the bundled directory as the release default so a missing or unavailable
/// enterprise endpoint can never make the Gyms screen empty. Live-directory
/// builds must opt in explicitly with --dart-define=IS_SINGLE_MODE=false.
/// Backend roles still control account and tenant access.
const bool isSingleMode = bool.fromEnvironment(
  'IS_SINGLE_MODE',
  defaultValue: true,
);
