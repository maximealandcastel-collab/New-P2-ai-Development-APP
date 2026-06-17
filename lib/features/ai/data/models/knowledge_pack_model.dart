class KnowledgePackModel {
  final int daysPerWeek;
  final List<String> preferredSplits;
  final String repRanges;
  final String restTimes;
  final String intensityMeasure;
  final String deloadFrequency;
  final String cardioPhilosophy;
  final List<String> mustUseExercises;
  final List<String> avoidExercises;
  final List<String> accessoryFavorites;
  final String proteinTarget;
  final String hydrationRule;
  final String maintenancePlate;
  final String weekendStrategy;
  final String consistencyMethod;
  final String motivationDropResponse;
  final String plateauProtocol;
  final String deloadRules;
  final List<String> naturalPhrases;
  final List<String> neverSayPhrases;
  final String coachingStyle;

  const KnowledgePackModel({
    required this.daysPerWeek,
    required this.preferredSplits,
    required this.repRanges,
    required this.restTimes,
    required this.intensityMeasure,
    required this.deloadFrequency,
    required this.cardioPhilosophy,
    required this.mustUseExercises,
    required this.avoidExercises,
    required this.accessoryFavorites,
    required this.proteinTarget,
    required this.hydrationRule,
    required this.maintenancePlate,
    required this.weekendStrategy,
    required this.consistencyMethod,
    required this.motivationDropResponse,
    required this.plateauProtocol,
    required this.deloadRules,
    required this.naturalPhrases,
    required this.neverSayPhrases,
    required this.coachingStyle,
  });

  Map<String, dynamic> toJson() => {
    'daysPerWeek': daysPerWeek,
    'preferredSplits': preferredSplits,
    'repRanges': repRanges,
    'restTimes': restTimes,
    'intensityMeasure': intensityMeasure,
    'deloadFrequency': deloadFrequency,
    'cardioPhilosophy': cardioPhilosophy,
    'mustUseExercises': mustUseExercises,
    'avoidExercises': avoidExercises,
    'accessoryFavorites': accessoryFavorites,
    'proteinTarget': proteinTarget,
    'hydrationRule': hydrationRule,
    'maintenancePlate': maintenancePlate,
    'weekendStrategy': weekendStrategy,
    'consistencyMethod': consistencyMethod,
    'motivationDropResponse': motivationDropResponse,
    'plateauProtocol': plateauProtocol,
    'deloadRules': deloadRules,
    'naturalPhrases': naturalPhrases,
    'neverSayPhrases': neverSayPhrases,
    'coachingStyle': coachingStyle,
  };
}
