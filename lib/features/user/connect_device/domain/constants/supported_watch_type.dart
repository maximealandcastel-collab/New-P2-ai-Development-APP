class SupportedWatchType {
  const SupportedWatchType._({
    required this.apiValue,
    required this.displayName,
    required this.description,
    required this.bleNamePatterns,
    required this.usesHealthKit,
  });

  final String apiValue;
  final String displayName;
  final String description;
  final List<String> bleNamePatterns;
  final bool usesHealthKit;

  static const appleWatchS3 = SupportedWatchType._(
    apiValue: 'apple_watch_s3',
    displayName: 'Apple Watch',
    description: 'Sync through Apple Health on your iPhone',
    bleNamePatterns: [],
    usesHealthKit: true,
  );

  static const fittechA6 = SupportedWatchType._(
    apiValue: 'fittech_a6',
    displayName: 'FitTech A6',
    description: 'Pair over Bluetooth',
    bleNamePatterns: ['fittech', 'fit tech', 'a6'],
    usesHealthKit: false,
  );

  static const fitS3Ultra = SupportedWatchType._(
    apiValue: 'fit_s3_ultra',
    displayName: 'Fit S3 Ultra',
    description: 'Pair over Bluetooth',
    bleNamePatterns: ['fit s3', 's3 ultra', 'fits3', 'fit-s3'],
    usesHealthKit: false,
  );

  static const List<SupportedWatchType> all = [
    appleWatchS3,
    fittechA6,
    fitS3Ultra,
  ];

  bool matchesBleName(String name) {
    if (usesHealthKit) return false;
    final normalized = name.toLowerCase();
    return bleNamePatterns.any((pattern) => normalized.contains(pattern));
  }

  static SupportedWatchType? fromApiValue(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final type in all) {
      if (type.apiValue == value) return type;
    }
    return null;
  }

  static bool isAppleWatchType(String? deviceType) =>
      deviceType == appleWatchS3.apiValue;
}
