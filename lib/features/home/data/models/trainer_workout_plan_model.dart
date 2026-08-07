import 'package:pler_to_pler_app/features/user/workout/data/models/workout_model.dart';

/// Represents a single exercise in a trainer-created day plan.
class TrainerExerciseItem {
  final String name;
  final int? sets;
  final String? reps;
  final int? restSeconds;
  final String? weight;
  final String? notes;

  const TrainerExerciseItem({
    required this.name,
    this.sets,
    this.reps,
    this.restSeconds,
    this.weight,
    this.notes,
  });

  factory TrainerExerciseItem.fromJson(Map<String, dynamic> j) {
    return TrainerExerciseItem(
      name: j['name']?.toString() ?? '',
      sets: j['sets'] is int ? j['sets'] as int : int.tryParse('${j['sets'] ?? ''}'),
      reps: j['reps']?.toString(),
      restSeconds: j['restSeconds'] is int
          ? j['restSeconds'] as int
          : int.tryParse('${j['restSeconds'] ?? ''}'),
      weight: j['weight']?.toString(),
      notes: j['notes']?.toString(),
    );
  }

  /// Maps to the existing WorkoutExerciseModel so we can reuse all existing
  /// exercise-card widgets without modification.
  WorkoutExerciseModel toWorkoutExerciseModel(int index) {
    final restLabel = restSeconds != null && restSeconds! > 0
        ? (restSeconds! >= 60
            ? '${restSeconds! ~/ 60}m ${restSeconds! % 60 > 0 ? "${restSeconds! % 60}s" : ""}'.trim()
            : '${restSeconds}s')
        : null;

    return WorkoutExerciseModel(
      id: 'tp_${index}_$name',
      exerciseName: name,
      sets: sets,
      reps: reps,
      restTime: restLabel,
      rpe: weight,
      order: index,
      steps: notes != null && notes!.isNotEmpty
          ? [WorkoutExerciseStepModel(order: 1, instruction: notes, tip: null)]
          : [],
    );
  }
}

/// A single day in the trainer-created plan.
class TrainerPlanDay {
  final String dayLabel;
  final String focus;
  final String? warmupNotes;
  final String? cooldownNotes;
  final List<TrainerExerciseItem> exercises;

  const TrainerPlanDay({
    required this.dayLabel,
    required this.focus,
    this.warmupNotes,
    this.cooldownNotes,
    required this.exercises,
  });

  factory TrainerPlanDay.fromJson(Map<String, dynamic> j) {
    final raw = j['exercises'];
    final exercises = raw is List
        ? raw.map((e) => TrainerExerciseItem.fromJson(Map<String, dynamic>.from(e as Map))).toList()
        : <TrainerExerciseItem>[];
    return TrainerPlanDay(
      dayLabel:     j['dayLabel']?.toString() ?? '',
      focus:        j['focus']?.toString() ?? '',
      warmupNotes:  j['warmupNotes']?.toString(),
      cooldownNotes:j['cooldownNotes']?.toString(),
      exercises:    exercises,
    );
  }

  List<WorkoutExerciseModel> get workoutExercises =>
      exercises.asMap().entries.map((e) => e.value.toWorkoutExerciseModel(e.key)).toList();
}

/// The full trainer workout plan for this client.
class TrainerWorkoutPlanModel {
  final String title;
  final String? trainerName;
  final List<List<TrainerPlanDay>> weeks;

  const TrainerWorkoutPlanModel({
    required this.title,
    this.trainerName,
    required this.weeks,
  });

  /// Returns today's day (Monday=0 … Sunday=6) from week 0.
  TrainerPlanDay? get todayDay {
    if (weeks.isEmpty || weeks[0].isEmpty) return null;
    final idx = DateTime.now().weekday - 1; // Mon=1→0, Sun=7→6
    final week = weeks[0];
    if (idx < 0 || idx >= week.length) return null;
    return week[idx];
  }

  List<WorkoutExerciseModel> get todayExercises => todayDay?.workoutExercises ?? [];

  String get todayFocus => todayDay?.focus ?? '';
  String get todayLabel => todayDay?.dayLabel ?? '';
  String? get todayWarmup => todayDay?.warmupNotes;
  String? get todayCooldown => todayDay?.cooldownNotes;

  factory TrainerWorkoutPlanModel.fromJson(Map<String, dynamic> j) {
    final rawWeeks = j['weeks'];
    final weeks = <List<TrainerPlanDay>>[];
    if (rawWeeks is List) {
      for (final week in rawWeeks) {
        if (week is List) {
          weeks.add(week
              .map((d) => TrainerPlanDay.fromJson(Map<String, dynamic>.from(d as Map)))
              .toList());
        }
      }
    }
    final trainerRaw = j['trainerId'];
    String? trainerName;
    if (trainerRaw is Map) {
      trainerName = trainerRaw['name']?.toString();
    }
    return TrainerWorkoutPlanModel(
      title:       j['title']?.toString() ?? 'Your Training Plan',
      trainerName: trainerName,
      weeks:       weeks,
    );
  }

  /// Parses the full API response: { success, data: { plans: [...] } }
  static TrainerWorkoutPlanModel? fromApiResponse(Map<String, dynamic> resp) {
    final data = resp['data'];
    if (data == null) return null;
    final plans = data is Map ? data['plans'] : null;
    if (plans is! List || plans.isEmpty) return null;
    return TrainerWorkoutPlanModel.fromJson(Map<String, dynamic>.from(plans[0] as Map));
  }
}
