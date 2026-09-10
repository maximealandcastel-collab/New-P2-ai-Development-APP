class LoginResultModel {
  final String token;
  final bool onboardingCompleted;
  final bool isSubscribed;
  final TenantScope? tenantScope;

  LoginResultModel({
    required this.token,
    required this.onboardingCompleted,
    required this.isSubscribed,
    this.tenantScope,
  });

  factory LoginResultModel.fromJson(Map<String, dynamic> json) {
    return LoginResultModel(
      token: json['token']?.toString() ?? '',
      // Backend may send either `onboardingCompleted` or `isProfile`.
      onboardingCompleted:
          json['onboardingCompleted'] == true || json['isProfile'] == true,
      isSubscribed: json['isSubscribed'] == true,
      tenantScope: json['user'] is Map && json['user']['tenantScope'] != null
          ? TenantScope.fromJson(
              Map<String, dynamic>.from(json['user']['tenantScope'] as Map),
            )
          : json['tenantScope'] is Map
              ? TenantScope.fromJson(
                  Map<String, dynamic>.from(json['tenantScope'] as Map),
                )
              : null,
    );
  }
}

/// Authorization scope issued by the backend with a successful login.
///
/// A gym-admin tenant must come from this value; it must never be inferred
/// from an email address or a client-side role selection.
class TenantScope {
  final String? tenantId;
  final List<String> gymAdminTenantIds;
  final List<String> capabilities;

  const TenantScope({
    this.tenantId,
    required this.gymAdminTenantIds,
    required this.capabilities,
  });

  factory TenantScope.fromJson(Map<String, dynamic> json) {
    List<String> strings(dynamic value) => value is List
        ? value.map((entry) => entry.toString()).toList()
        : const <String>[];

    return TenantScope(
      tenantId: json['tenantId']?.toString(),
      gymAdminTenantIds: strings(json['gymAdminTenantIds']),
      capabilities: strings(json['capabilities']),
    );
  }
}
