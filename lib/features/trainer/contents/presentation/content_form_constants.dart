class ContentFormConstants {
  ContentFormConstants._();

  static const String contentType = 'video';

  static const List<MapEntry<String, String>> categoryOptions = [
    MapEntry('cat_1', 'Muscles gain'),
    MapEntry('cat_2', 'Weight loss'),
    MapEntry('cat_3', 'Cardio'),
    MapEntry('cat_4', 'Boxing'),
    MapEntry('cat_5', 'Nutrition'),
  ];

  static const List<String> muscleGroupOptions = [
    'upper_body',
    'chest',
    'back',
    'shoulders',
    'arms',
    'lower_body',
    'legs',
    'glutes',
    'core',
    'full_body',
    'cardio',
    'boxing',
  ];

  static const List<String> difficultyOptions = [
    'beginner',
    'intermediate',
    'advanced',
    'all',
  ];

  static String formatLabel(String value) {
    return value
        .split('_')
        .map(
          (word) =>
              word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  static String formatSelectedList(List<String> values) {
    return values.map(formatLabel).join(', ');
  }
}
