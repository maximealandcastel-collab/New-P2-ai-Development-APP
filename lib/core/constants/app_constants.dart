class AppConstants{
  AppConstants._();
  static const String accessToken = "accessToken";
  static const String otpToken = "otpToken";
  static const String cacheUserRole = "cacheUserRole";
  static const String cacheUserGender = "cacheUserGender";
  static const String cacheUserProfile = "cacheUserProfile";
  static const String cacheTrainers = "cacheTrainers";
  static const String cacheCategories = "cacheCategories";
  static const String cacheUserDevices = "cacheUserDevices";






















  static RegExp emailValidate = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  static bool validatePassword(String value) {
    RegExp regex = RegExp(r'^(?=.*[0-9])(?=.*[a-zA-Z]).{6,}$');
    return regex.hasMatch(value);
  }



}