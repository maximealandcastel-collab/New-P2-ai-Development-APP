class WorkoutPlanStepModel {
  int? order;
  String? instruction;
  String? tip;
  String? duration;

  WorkoutPlanStepModel({
    this.order,
    this.instruction,
    this.tip,
    this.duration,
  });

  factory WorkoutPlanStepModel.fromJson(Map<String, dynamic> json) {
    return WorkoutPlanStepModel(
      order: json['order'] is int ? json['order'] as int : int.tryParse('${json['order']}'),
      instruction: json['instruction']?.toString(),
      tip: json['tip']?.toString(),
      duration: json['duration']?.toString(),
    );
  }
}

class WorkoutExerciseStepModel {
  int? order;
  String? instruction;
  String? tip;
  String? duration;

  WorkoutExerciseStepModel({
    this.order,
    this.instruction,
    this.tip,
    this.duration,
  });

  factory WorkoutExerciseStepModel.fromJson(Map<String, dynamic> json) {
    return WorkoutExerciseStepModel(
      order: json['order'] is int ? json['order'] as int : int.tryParse('${json['order']}'),
      instruction: json['instruction']?.toString(),
      tip: json['tip']?.toString(),
      duration: json['duration']?.toString(),
    );
  }
}

class WorkoutExerciseModel {
  String? id;
  String? exerciseId;
  String? blockId;
  String? blockName;
  String? exerciseName;
  String? muscleGroup;
  int? sets;
  String? reps;
  String? restTime;
  String? rpe;
  List<WorkoutExerciseStepModel>? steps;
  Map<String, String>? substitutions;
  int? order;
  bool? isCompleted;

  WorkoutExerciseModel({
    this.id,
    this.exerciseId,
    this.blockId,
    this.blockName,
    this.exerciseName,
    this.muscleGroup,
    this.sets,
    this.reps,
    this.restTime,
    this.rpe,
    this.steps,
    this.substitutions,
    this.order,
    this.isCompleted,
  });

  factory WorkoutExerciseModel.fromJson(Map<String, dynamic> json) {
    return WorkoutExerciseModel(
      id: json['_id']?.toString(),
      exerciseId: json['exerciseId']?.toString(),
      blockId: json['blockId']?.toString(),
      blockName: json['blockName']?.toString(),
      exerciseName: json['exerciseName']?.toString(),
      muscleGroup: json['muscleGroup']?.toString(),
      sets: json['sets'] is int ? json['sets'] as int : int.tryParse('${json['sets']}'),
      reps: json['reps']?.toString(),
      restTime: json['restTime']?.toString(),
      rpe: json['rpe']?.toString(),
      steps: json['steps'] is List
          ? (json['steps'] as List)
              .map((item) => WorkoutExerciseStepModel.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ))
              .toList()
          : null,
      substitutions: json['substitutions'] is Map
          ? (json['substitutions'] as Map).map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            )
          : null,
      order: json['order'] is int ? json['order'] as int : int.tryParse('${json['order']}'),
      isCompleted: json['isCompleted'] as bool?,
    );
  }
}

class WorkoutAiPlanModel {
  String? coachNote;
  List<String>? thisWeekFocus;
  String? nutritionTip;
  List<WorkoutPlanStepModel>? warmUp;
  List<WorkoutExerciseModel>? mainWork;
  List<WorkoutExerciseModel>? accessories;
  List<WorkoutExerciseModel>? finisher;
  List<WorkoutPlanStepModel>? coolDown;
  int? estimatedDurationMinutes;
  String? cardioGuidance;
  String? suggestedVideo;
  String? checkInQuestion;
  String? generatedAt;
  String? trainerPersona;
  String? trainerSpecialty;

  WorkoutAiPlanModel({
    this.coachNote,
    this.thisWeekFocus,
    this.nutritionTip,
    this.warmUp,
    this.mainWork,
    this.accessories,
    this.finisher,
    this.coolDown,
    this.estimatedDurationMinutes,
    this.cardioGuidance,
    this.suggestedVideo,
    this.checkInQuestion,
    this.generatedAt,
    this.trainerPersona,
    this.trainerSpecialty,
  });

  factory WorkoutAiPlanModel.fromJson(Map<String, dynamic> json) {
    return WorkoutAiPlanModel(
      coachNote: json['coachNote']?.toString(),
      thisWeekFocus: json['thisWeekFocus'] is List
          ? List<String>.from(json['thisWeekFocus'] as List)
          : null,
      nutritionTip: json['nutritionTip']?.toString(),
      warmUp: _parsePlanSteps(json['warmUp']),
      mainWork: _parseExercises(json['mainWork']),
      accessories: _parseExercises(json['accessories']),
      finisher: _parseExercises(json['finisher']),
      coolDown: _parsePlanSteps(json['coolDown']),
      estimatedDurationMinutes: json['estimatedDurationMinutes'] is int
          ? json['estimatedDurationMinutes'] as int
          : int.tryParse('${json['estimatedDurationMinutes']}'),
      cardioGuidance: json['cardioGuidance']?.toString(),
      suggestedVideo: json['suggestedVideo']?.toString(),
      checkInQuestion: json['checkInQuestion']?.toString(),
      generatedAt: json['generatedAt']?.toString(),
      trainerPersona: json['trainerPersona']?.toString(),
      trainerSpecialty: json['trainerSpecialty']?.toString(),
    );
  }

  static List<WorkoutPlanStepModel>? _parsePlanSteps(dynamic value) {
    if (value is! List) return null;
    return value
        .map((item) => WorkoutPlanStepModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ))
        .toList();
  }

  static List<WorkoutExerciseModel>? _parseExercises(dynamic value) {
    if (value is! List) return null;
    return value
        .map((item) => WorkoutExerciseModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ))
        .toList();
  }
}

class WorkoutModel {
  String? id;
  String? userId;
  List<String>? goal;
  List<String>? focusArea;
  List<String>? workoutEnvironment;
  List<String>? equipmentAvailability;
  List<String>? workoutIntensity;
  int? duration;
  String? date;
  String? trainerId;
  String? trainerName;
  WorkoutAiPlanModel? aiPlan;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? startedAt;

  WorkoutModel({
    this.id,
    this.userId,
    this.goal,
    this.focusArea,
    this.workoutEnvironment,
    this.equipmentAvailability,
    this.workoutIntensity,
    this.duration,
    this.date,
    this.trainerId,
    this.trainerName,
    this.aiPlan,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.startedAt,
  });

  static List<WorkoutModel> listFromResponse(dynamic responseData) {
    if (responseData is! Map) return [];

    final data = responseData['data'];
    if (data is! List) return [];

    return data
        .map(
          (item) => WorkoutModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    final trainer = data['trainerId'];

    return WorkoutModel(
      id: data['_id']?.toString(),
      userId: data['userId']?.toString(),
      goal: data['goal'] is List ? List<String>.from(data['goal'] as List) : null,
      focusArea: data['focusArea'] is List
          ? List<String>.from(data['focusArea'] as List)
          : null,
      workoutEnvironment: data['workout_environment'] is List
          ? List<String>.from(data['workout_environment'] as List)
          : null,
      equipmentAvailability: data['equipment_availablity'] is List
          ? List<String>.from(data['equipment_availablity'] as List)
          : null,
      workoutIntensity: data['workout_intensity'] is List
          ? List<String>.from(data['workout_intensity'] as List)
          : null,
      duration: data['duration'] is int
          ? data['duration'] as int
          : int.tryParse('${data['duration']}'),
      date: data['date']?.toString(),
      trainerId: trainer is Map
          ? trainer['_id']?.toString()
          : trainer?.toString(),
      trainerName: trainer is Map ? trainer['name']?.toString() : null,
      aiPlan: data['aiPlan'] is Map
          ? WorkoutAiPlanModel.fromJson(
              Map<String, dynamic>.from(data['aiPlan'] as Map),
            )
          : null,
      status: data['status']?.toString(),
      createdAt: data['createdAt']?.toString(),
      updatedAt: data['updatedAt']?.toString(),
      startedAt: data['startedAt']?.toString(),
    );
  }

  (int completed, int total) exerciseProgress(List<WorkoutExerciseModel>? exercises) {
    if (exercises == null || exercises.isEmpty) return (0, 0);

    final completedCount =
        exercises.where((exercise) => exercise.isCompleted == true).length;
    return (completedCount, exercises.length);
  }
}
