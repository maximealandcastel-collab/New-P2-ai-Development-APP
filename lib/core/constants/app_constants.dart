class AppConstants{
  AppConstants._();
  static const String accessToken = "accessToken";
  static const String otpToken = "otpToken";
  static const String cacheUserRole = "cacheUserRole";
  static const String cacheUserGender = "cacheUserGender";
  static const String cacheUserProfile = "cacheUserProfile";
  static const String cacheTrainerProfile = "cacheTrainerProfile";
  static const String cacheTrainers = "cacheTrainers";
  static const String cacheCategories = "cacheCategories";
  static const String cacheContentFeedPrefix = "cacheContentFeed:";
  static const String cacheExerciseBlocks = "cacheExerciseBlocks";
  static const String cacheTrainerClientsPaid = "cacheTrainerClientsPaid";
  static const String cacheTrainerClientsSent = "cacheTrainerClientsSent";
  static const String cacheTrainerInvoicesAll = "cacheTrainerInvoicesAll";
  static const String cacheTrainerRequests = "cacheTrainerRequests";
  static const String cacheTrainerDashboard = "cacheTrainerDashboard";
  static const String cacheTrainerEarnings = "cacheTrainerEarnings";
  static const String cacheTrainerPayments = "cacheTrainerPayments";
  static const String cacheUserDevices = "cacheUserDevices";






















  static RegExp emailValidate = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  static bool validatePassword(String value) {
    RegExp regex = RegExp(r'^(?=.*[0-9])(?=.*[a-zA-Z]).{6,}$');
    return regex.hasMatch(value);
  }



}