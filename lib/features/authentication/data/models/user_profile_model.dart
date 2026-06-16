class UserProfileModel {
  final String? primaryGoal;
  final String? gender;
  final String? dateOfBirth;
  final int? height;
  final int? weight;
  final String? fitnessLevel;
  final String? availableEquipment;
  final int? trainingDaysPerWeek;
  final List<String>? injuries;
  final String? preferredName;
  final String? motivationStyle;

  const UserProfileModel({
    this.primaryGoal,
    this.gender,
    this.dateOfBirth,
    this.height,
    this.weight,
    this.fitnessLevel,
    this.availableEquipment,
    this.trainingDaysPerWeek,
    this.injuries,
    this.preferredName,
    this.motivationStyle,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      primaryGoal: json['primaryGoal'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      height: json['height'] as int?,
      weight: json['weight'] as int?,
      fitnessLevel: json['fitnessLevel'] as String?,
      availableEquipment: json['availableEquipment'] as String?,
      trainingDaysPerWeek: json['trainingDaysPerWeek'] as int?,
      injuries: (json['injuries'] as List?)?.cast<String>(),
      preferredName: json['preferredName'] as String?,
      motivationStyle: json['motivationStyle'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (primaryGoal != null) 'primaryGoal': primaryGoal,
    if (gender != null) 'gender': gender,
    if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
    if (height != null) 'height': height,
    if (weight != null) 'weight': weight,
    if (fitnessLevel != null) 'fitnessLevel': fitnessLevel,
    if (availableEquipment != null) 'availableEquipment': availableEquipment,
    if (trainingDaysPerWeek != null) 'trainingDaysPerWeek': trainingDaysPerWeek,
    if (injuries != null) 'injuries': injuries,
    if (preferredName != null) 'preferredName': preferredName,
    if (motivationStyle != null) 'motivationStyle': motivationStyle,
  };
}