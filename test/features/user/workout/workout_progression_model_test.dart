import 'package:flutter_test/flutter_test.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/workout_progression_model.dart';

void main() {
  group('WorkoutProgressionModel Tests', () {
    test('should parse WorkoutProgressionModel correctly from valid json', () {
      final json = {
        "date": "2026-07-06",
        "totalExercises": 7,
        "completedExercises": 7,
        "completionPercentage": 100
      };

      final model = WorkoutProgressionModel.fromJson(json);

      expect(model.date, "2026-07-06");
      expect(model.totalExercises, 7);
      expect(model.completedExercises, 7);
      expect(model.completionPercentage, 100);
    });

    test('should handle null/missing values gracefully with default values', () {
      final json = <String, dynamic>{};

      final model = WorkoutProgressionModel.fromJson(json);

      expect(model.date, "");
      expect(model.totalExercises, 0);
      expect(model.completedExercises, 0);
      expect(model.completionPercentage, 0);
    });

    test('should parse list of WorkoutProgressionModel correctly', () {
      final jsonList = [
        {
          "date": "2026-07-06",
          "totalExercises": 7,
          "completedExercises": 7,
          "completionPercentage": 100
        },
        {
          "date": "2026-07-07",
          "totalExercises": 7,
          "completedExercises": 2,
          "completionPercentage": 29
        }
      ];

      final list = WorkoutProgressionModel.listFromJson(jsonList);

      expect(list.length, 2);
      expect(list[0].date, "2026-07-06");
      expect(list[0].completionPercentage, 100);
      expect(list[1].date, "2026-07-07");
      expect(list[1].completionPercentage, 29);
    });
  });
}
