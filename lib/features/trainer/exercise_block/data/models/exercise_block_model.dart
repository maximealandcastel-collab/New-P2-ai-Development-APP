import 'package:intl/intl.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';

class ExerciseBlockModel {
  ExerciseBlockModel({
    this.id,
    this.trainerId,
    this.name,
    this.description,
    this.category,
    this.isAiGenerated,
    this.isApproved,
    this.createdAt,
    this.updatedAt,
    this.exercises,
  });

  final String? id;
  final String? trainerId;
  final String? name;
  final String? description;
  final String? category;
  final bool? isAiGenerated;
  final bool? isApproved;
  final String? createdAt;
  final String? updatedAt;
  final List<BlockExerciseModel>? exercises;

  String get title => name ?? '';
  String get categoryLabel => StringFormat.formatSpecialty(category ?? '');

  String get formattedCreatedAt {
    if (createdAt == null || createdAt!.trim().isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(createdAt!).toLocal();
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (_) {
      return createdAt!;
    }
  }

  factory ExerciseBlockModel.fromJson(Map<String, dynamic> json) {
    return ExerciseBlockModel(
      id: json['_id'] as String?,
      trainerId: json['trainerId'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      isAiGenerated: json['isAiGenerated'] as bool?,
      isApproved: json['isApproved'] as bool?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      exercises: (json['exercises'] as List?)
          ?.map((item) => BlockExerciseModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'trainerId': trainerId,
      'name': name,
      'description': description,
      'category': category,
      'isAiGenerated': isAiGenerated,
      'isApproved': isApproved,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'exercises': exercises?.map((item) => item.toJson()).toList(),
    };
  }
}

class BlockExerciseModel {
  BlockExerciseModel({
    this.id,
    this.blockId,
    this.trainerId,
    this.name,
    this.muscleGroup,
    this.difficulty,
    this.equipment,
    this.sets,
    this.reps,
    this.restTime,
    this.rpe,
    this.substitutions,
    this.tags,
    this.isAiGenerated,
    this.isApproved,
    this.createdAt,
    this.updatedAt,
    this.steps,
  });

  final String? id;
  final String? blockId;
  final String? trainerId;
  final String? name;
  final String? muscleGroup;
  final String? difficulty;
  final String? equipment;
  final int? sets;
  final String? reps;
  final String? restTime;
  final String? rpe;
  final Map<String, String>? substitutions;
  final List<String>? tags;
  final bool? isAiGenerated;
  final bool? isApproved;
  final String? createdAt;
  final String? updatedAt;
  final List<ExerciseStepModel>? steps;

  factory BlockExerciseModel.fromJson(Map<String, dynamic> json) {
    return BlockExerciseModel(
      id: json['_id'] as String?,
      blockId: json['blockId'] as String?,
      trainerId: json['trainerId'] as String?,
      name: json['name'] as String?,
      muscleGroup: json['muscleGroup'] as String?,
      difficulty: json['difficulty'] as String?,
      equipment: json['equipment'] as String?,
      sets: json['sets'] as int?,
      reps: json['reps'] as String?,
      restTime: json['restTime'] as String?,
      rpe: json['rpe'] as String?,
      substitutions: (json['substitutions'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, value.toString())),
      tags: (json['tags'] as List?)?.map((item) => item.toString()).toList(),
      isAiGenerated: json['isAiGenerated'] as bool?,
      isApproved: json['isApproved'] as bool?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      steps: (json['steps'] as List?)
          ?.map((item) => ExerciseStepModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'blockId': blockId,
      'trainerId': trainerId,
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
      'isAiGenerated': isAiGenerated,
      'isApproved': isApproved,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'steps': steps?.map((item) => item.toJson()).toList(),
    };
  }
}

class ExerciseStepModel {
  ExerciseStepModel({
    this.id,
    this.exerciseId,
    this.order,
    this.instruction,
    this.tip,
    this.duration,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String? exerciseId;
  final int? order;
  final String? instruction;
  final String? tip;
  final String? duration;
  final String? createdAt;
  final String? updatedAt;

  factory ExerciseStepModel.fromJson(Map<String, dynamic> json) {
    return ExerciseStepModel(
      id: json['_id'] as String?,
      exerciseId: json['exerciseId'] as String?,
      order: json['order'] as int?,
      instruction: json['instruction'] as String?,
      tip: json['tip'] as String?,
      duration: json['duration'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'exerciseId': exerciseId,
      'order': order,
      'instruction': instruction,
      'tip': tip,
      'duration': duration,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
