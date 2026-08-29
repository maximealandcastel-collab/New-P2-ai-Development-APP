class AppConstants{
  AppConstants._();
  static const String accessToken = "accessToken";
  static const String otpToken = "otpToken";
  static const String cacheUserRole = "cacheUserRole";
  static const String cacheUserEmail = "cacheUserEmail";
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
  static const String cacheNotifications = "cacheNotifications";






















  /// Accounts granted admin mode client-side regardless of the backend role.
  /// Single source of truth — read by LoginController and SplashController.
  static const Set<String> ownerEmails = {'pmoney78q@gmail.com'};

  /// SharedPreferences keys that hold admin/affiliate state. Auth data lives in
  /// Hive and is wiped by AuthRepository.logout(); these are not, so logout has
  /// to clear them explicitly or the next account inherits admin mode.
  static const String prefAdminDashboardMode = 'adminDashboardMode';
  static const String prefAdminToken = 'adminToken';

  static RegExp emailValidate = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  static bool validatePassword(String value) {
    RegExp regex = RegExp(r'^(?=.*[0-9])(?=.*[a-zA-Z]).{6,}$');
    return regex.hasMatch(value);
  }



}