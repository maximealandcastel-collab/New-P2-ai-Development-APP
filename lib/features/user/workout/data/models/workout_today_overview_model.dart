class WorkoutTodayOverviewModel {
  String? workoutId;
  List<String>? goal;
  List<String>? focusArea;
  int? duration;
  List<String>? workoutIntensity;
  List<String>? equipmentAvailability;
  List<String>? workoutEnvironment;
  String? status;
  int? totalExercises;
  int? completedExercises;
  int? completionPercentage;

  WorkoutTodayOverviewModel({
    this.workoutId,
    this.goal,
    this.focusArea,
    this.duration,
    this.workoutIntensity,
    this.equipmentAvailability,
    this.workoutEnvironment,
    this.status,
    this.totalExercises,
    this.completedExercises,
    this.completionPercentage,
  });

  factory WorkoutTodayOverviewModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    return WorkoutTodayOverviewModel(
      workoutId: data['workoutId']?.toString(),
      goal: data['goal'] is List ? List<String>.from(data['goal'] as List) : null,
      focusArea: data['focusArea'] is List
          ? List<String>.from(data['focusArea'] as List)
          : null,
      duration: data['duration'] is int
          ? data['duration'] as int
          : int.tryParse('${data['duration']}'),
      workoutIntensity: data['workout_intensity'] is List
          ? List<String>.from(data['workout_intensity'] as List)
          : null,
      equipmentAvailability: data['equipment_availablity'] is List
          ? List<String>.from(data['equipment_availablity'] as List)
          : null,
      workoutEnvironment: data['workout_environment'] is List
          ? List<String>.from(data['workout_environment'] as List)
          : null,
      status: data['status']?.toString(),
      totalExercises: data['totalExercises'] is int
          ? data['totalExercises'] as int
          : int.tryParse('${data['totalExercises']}'),
      completedExercises: data['completedExercises'] is int
          ? data['completedExercises'] as int
          : int.tryParse('${data['completedExercises']}'),
      completionPercentage: data['completionPercentage'] is int
          ? data['completionPercentage'] as int
          : int.tryParse('${data['completionPercentage']}'),
    );
  }
}
