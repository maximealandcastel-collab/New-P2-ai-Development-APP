/// true: previous KMF-only flow using the existing gym-admin API.
/// false: shared multi-gym engine (requires the enterprise backend).
/// Change defaultValue or use --dart-define=IS_SINGLE_MODE=false, then rebuild.
/// This selects the experience; backend roles still control account access.
const bool isSingleMode = bool.fromEnvironment(
  'IS_SINGLE_MODE',
  defaultValue: true,
);
