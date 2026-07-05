class HelperData {
  HelperData._();

  static final List<String> heightOptions = List.generate(100, (index) {
    final feet = (index ~/ 12) + 4;
    final inches = index % 12;

    final totalInches = (feet * 12) + inches;
    final cm = (totalInches * 2.54).round();

    return "$feet'$inches\" ($cm cm)";
  });

  static final List<String> weightOptions = List.generate(66, (index) {
    return '${35 + index} kg';
  });

  static const List<String> fitnessLevelOptions = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Professional',
    'Athlete',
  ];

  static const List<String> goalOptions = [
    'Lose Weight',
    'Build Muscle',
    'Improve Endurance',
    'Increase Strength',
    'Improve Flexibility',
    'Enhance Athletic Performance',
    'Maintain Physique',
    'Stress Relief & Mental Health',
    'Improve Posture',
    'Rehabilitation & Recovery',
  ];

  static const List<String> goalBackendOptions = [
    'weight_loss',
    'muscle_gain',
    'improve_endurance',
    'increase_strength',
    'improve_flexibility',
    'enhance_athletic_performance',
    'maintain_physique',
    'stress_relief',
    'improve_posture',
    'rehabilitation_recovery',
  ];

  static const List<String> equipmentDisplayOptions = [
    'Full Gym',
    'Home Gym',
    'Minimal Equipment',
    'Bodyweight Only',
  ];

  static const List<String> equipmentBackendOptions = [
    'full_gym',
    'home_gym',
    'minimal_equipment',
    'bodyweight_only',
  ];

  static const List<String> motivationStyleDisplayOptions = [
    'Strict',
    'Chill',
    'Balanced',
  ];

  static const List<String> motivationStyleBackendOptions = [
    'strict',
    'chill',
    'balanced',
  ];

  static const List<String> coachingStyleOptions = [
    'strict',
    'chill',
    'balanced',
  ];

  static const List<String> intensityMeasureOptions = [
    'RPE',
    'RIR',
    '%1RM',
  ];

  static const List<String> specialityDisplayOptions = [
    'Maintain Physique',
    'Muscle Gain',
    'Weight Loss',
    'Nutrition',
    'Boxing',
  ];

  static const List<String> specialityBackendOptions = [
    'maintain_physique',
    'muscle_gain',
    'weight_loss',
    'nutrition',
    'boxing',
  ];

  static const List<String> genderOptions = [
    'Male',
    'Female',
  ];

  static const String contentType = 'video';

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

  static const List<String> contentDifficultyOptions = [
    'beginner',
    'intermediate',
    'advanced',
    'all',
  ];

  static const List<String> exerciseEquipmentOptions = [
    'barbell',
    'dumbbell',
    'machine',
    'bodyweight',
    'cable',
    'kettlebell',
    'resistance_band',
  ];

  static const List<String> trainerGuidance = [
    'AI-Powered trainer Guidance',
    'Workout plan',
    'Expert Coaching',
    'Motivation & Reminders',
  ];

  static const List<String> workoutFocusAreaOptions = [
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
  ];

  static const List<String> workoutEnvironmentOptions = [
    'full_gym',
    'home_gym',
    'minimal_equipment',
    'bodyweight_only',
  ];

  static const List<String> workoutEquipmentOptions = [
    'barbell',
    'dumbbells',
    'cable_machine',
    'bench',
    'kettlebell',
    'resistance_band',
    'bodyweight',
    'machine',
  ];

  static const List<String> workoutIntensityOptions = [
    'low',
    'moderate',
    'high',
  ];

  static const List<int> workoutDurationOptions = [30, 45, 60, 75, 90];
}
