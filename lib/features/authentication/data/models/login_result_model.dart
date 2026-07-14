class LoginResultModel {
  final String token;
  final bool onboardingCompleted;
  final bool isSubscribed;

  LoginResultModel({
    required this.token,
    required this.onboardingCompleted,
    required this.isSubscribed,
  });

  factory LoginResultModel.fromJson(Map<String, dynamic> json) {
    return LoginResultModel(
      token: json['token']?.toString() ?? '',
      // Backend may send either `onboardingCompleted` or `isProfile`.
      onboardingCompleted:
          json['onboardingCompleted'] == true || json['isProfile'] == true,
      isSubscribed: json['isSubscribed'] == true,
    );
  }
}
