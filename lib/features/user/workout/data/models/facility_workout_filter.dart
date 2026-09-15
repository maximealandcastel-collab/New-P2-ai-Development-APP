/// Inventory supplied by the selected facility. This is a workout preference,
/// not authorization to access that facility. Empty inventory means bodyweight.
class FacilityWorkoutFilter {
  FacilityWorkoutFilter({required String facilityId, required List<String> equipment})
      : facilityId = facilityId.trim(),
        equipment = List<String>.unmodifiable(equipment) {
    if (this.facilityId.isEmpty) {
      throw ArgumentError.value(facilityId, 'facilityId', 'Must not be empty');
    }
  }

  final String facilityId;
  final List<String> equipment;

  /// Preserve every existing preference and let the server intersect the user's
  /// equipment selection with this inventory before generating any exercises.
  Map<String, dynamic> applyToPayload(Map<String, dynamic> payload) => {
        ...payload,
        'workoutPreferences': {
          ...(payload['workoutPreferences'] as Map<String, dynamic>? ?? {}),
          'facilityId': facilityId,
          'facilityEquipment': equipment,
        },
      };
}
