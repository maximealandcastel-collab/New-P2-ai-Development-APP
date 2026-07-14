class WorkoutProgressionModel {
  final String date;
  final int totalExercises;
  final int completedExercises;
  final int completionPercentage;

  WorkoutProgressionModel({
    required this.date,
    required this.totalExercises,
    required this.completedExercises,
    required this.completionPercentage,
  });

  factory WorkoutProgressionModel.fromJson(Map<String, dynamic> json) {
    return WorkoutProgressionModel(
      date: json['date']?.toString() ?? '',
      totalExercises: json['totalExercises'] is int
          ? json['totalExercises'] as int
          : int.tryParse('${json['totalExercises']}') ?? 0,
      completedExercises: json['completedExercises'] is int
          ? json['completedExercises'] as int
          : int.tryParse('${json['completedExercises']}') ?? 0,
      completionPercentage: json['completionPercentage'] is int
          ? json['completionPercentage'] as int
          : int.tryParse('${json['completionPercentage']}') ?? 0,
    );
  }

  static List<WorkoutProgressionModel> listFromJson(dynamic json) {
    if (json == null) return [];
    if (json is List) {
      return json
          .map((item) => WorkoutProgressionModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    }
    return [];
  }
}
