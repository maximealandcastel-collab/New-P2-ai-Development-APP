class ExerciseStepDraftModel {
  ExerciseStepDraftModel({
    required this.order,
    required this.instruction,
    required this.tip,
  });

  final int order;
  final String instruction;
  final String tip;

  Map<String, dynamic> toJson() {
    return {
      'order': order,
      'instruction': instruction,
      'tip': tip,
    };
  }
}

class CreateExerciseDraftModel {
  CreateExerciseDraftModel({
    required this.name,
    required this.muscleGroup,
    required this.difficulty,
    required this.equipment,
    required this.sets,
    required this.reps,
    required this.restTime,
    required this.rpe,
    required this.substitutions,
    required this.tags,
    required this.steps,
  });

  final String name;
  final String muscleGroup;
  final String difficulty;
  final String equipment;
  final int sets;
  final String reps;
  final String restTime;
  final String rpe;
  final Map<String, String> substitutions;
  final List<String> tags;
  final List<ExerciseStepDraftModel> steps;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'muscleGroup': muscleGroup,
      'difficulty': difficulty,
      'equipment': equipment,
      'sets': sets,
      'reps': reps,
      'restTime': restTime,
      'rpe': rpe,
      'substitutions': substitutions,
      'tags': tags,
      'steps': steps.map((step) => step.toJson()).toList(),
    };
  }
}
