import 'package:flutter_test/flutter_test.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/facility_workout_filter.dart';

void main() {
  test('adds facility constraints without mutating personal preferences', () {
    final inventory = ['dumbbells', 'bench'];
    final filter = FacilityWorkoutFilter(facilityId: ' gym-a ', equipment: inventory);
    inventory.clear();
    final payload = <String, dynamic>{
      'goal': ['strength'],
      'focusArea': ['chest'],
      'duration': 45,
      'equipment_availablity': ['dumbbells', 'cable_machine'],
      'workoutPreferences': {'daysPerWeek': 4, 'injuries': ['test constraint']},
    };
    final result = filter.applyToPayload(payload);
    expect(result['duration'], 45);
    expect(result['goal'], ['strength']);
    expect(result['focusArea'], ['chest']);
    expect(result['equipment_availablity'], ['dumbbells', 'cable_machine']);
    expect(result['workoutPreferences'], {
      'daysPerWeek': 4, 'injuries': ['test constraint'],
      'facilityId': 'gym-a', 'facilityEquipment': ['dumbbells', 'bench'],
    });
    expect((payload['workoutPreferences'] as Map).containsKey('facilityId'), false);
  });

  test('empty inventory stays explicit and blank facility IDs are rejected', () {
    final filter = FacilityWorkoutFilter(facilityId: 'gym-b', equipment: []);
    expect(filter.applyToPayload({})['workoutPreferences']['facilityEquipment'], isEmpty);
    expect(() => FacilityWorkoutFilter(facilityId: ' ', equipment: []), throwsArgumentError);
  });
}
