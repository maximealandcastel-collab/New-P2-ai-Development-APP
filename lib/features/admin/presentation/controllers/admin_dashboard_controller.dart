import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/utils/helpers/prefs_helper.dart';

// ─── Models ────────────────────────────────────────────────────────────────

class AdminOverview {
  final int totalUsers;
  final int todaySignups;
  final int weekSignups;
  final int monthSignups;
  final int verifiedUsers;
  final int unverifiedUsers;
  final int activeSubscriptions;
  final int adminBypassUsers;

  AdminOverview({
    required this.totalUsers,
    required this.todaySignups,
    required this.weekSignups,
    required this.monthSignups,
    required this.verifiedUsers,
    required this.unverifiedUsers,
    required this.activeSubscriptions,
    required this.adminBypassUsers,
  });

  factory AdminOverview.fromJson(Map<String, dynamic> j) => AdminOverview(
        totalUsers: (j['totalUsers'] as num?)?.toInt() ?? 0,
        todaySignups: (j['todaySignups'] as num?)?.toInt() ?? 0,
        weekSignups: (j['weekSignups'] as num?)?.toInt() ?? 0,
        monthSignups: (j['monthSignups'] as num?)?.toInt() ?? 0,
        verifiedUsers: (j['verifiedUsers'] as num?)?.toInt() ?? 0,
        unverifiedUsers: (j['unverifiedUsers'] as num?)?.toInt() ?? 0,
        activeSubscriptions: (j['activeSubscriptions'] as num?)?.toInt() ?? 0,
        adminBypassUsers: (j['adminBypassUsers'] as num?)?.toInt() ?? 0,
      );
}

class RoleCount {
  final String role;
  final int count;
  RoleCount({required this.role, required this.count});
  factory RoleCount.fromJson(Map<String, dynamic> j) => RoleCount(
        role: j['role']?.toString() ?? '',
        count: (j['count'] as num?)?.toInt() ?? 0,
      );
}

class SubCount {
  final String tier;
  final int count;
  SubCount({required this.tier, required this.count});
  factory SubCount.fromJson(Map<String, dynamic> j) => SubCount(
        tier: j['tier']?.toString() ?? '',
        count: (j['count'] as num?)?.toInt() ?? 0,
      );
}

class DailySignup {
  final String date;
  final int count;
  DailySignup({required this.date, required this.count});
  factory DailySignup.fromJson(Map<String, dynamic> j) => DailySignup(
        date: j['date']?.toString() ?? '',
        count: (j['count'] as num?)?.toInt() ?? 0,
      );
}

class RecentUser {
  final String id;
  final String email;
  final String role;
  final bool isVerified;
  final String subscriptionTier;
  final DateTime createdAt;

  RecentUser({
    required this.id,
    required this.email,
    required this.role,
    required this.isVerified,
    required this.subscriptionTier,
    required this.createdAt,
  });

  factory RecentUser.fromJson(Map<String, dynamic> j) => RecentUser(
        id: j['_id']?.toString() ?? '',
        email: j['email']?.toString() ?? '',
        role: j['role']?.toString() ?? '',
        isVerified: j['isVerified'] == true,
        subscriptionTier: j['subscriptionTier']?.toString() ?? 'free',
        createdAt: j['createdAt'] != null
            ? DateTime.tryParse(j['createdAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );
}

class AdminMetrics {
  final AdminOverview overview;
  final List<RoleCount> roleBreakdown;
  final List<SubCount> subscriptionBreakdown;
  final List<DailySignup> dailySignups;
  final List<RecentUser> recentUsers;

  AdminMetrics({
    required this.overview,
    required this.roleBreakdown,
    required this.subscriptionBreakdown,
    required this.dailySignups,
    required this.recentUsers,
  });

  factory AdminMetrics.fromJson(Map<String, dynamic> json) => AdminMetrics(
        overview: AdminOverview.fromJson(
            (json['overview'] as Map<String, dynamic>?) ?? {}),
        roleBreakdown: ((json['roleBreakdown'] as List?) ?? [])
            .map((e) => RoleCount.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        subscriptionBreakdown: ((json['subscriptionBreakdown'] as List?) ?? [])
            .map((e) => SubCount.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        dailySignups: ((json['dailySignups'] as List?) ?? [])
            .map((e) =>
                DailySignup.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        recentUsers: ((json['recentUsers'] as List?) ?? [])
            .map((e) =>
                RecentUser.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}

class WithdrawalItem {
  final String id;
  final String trainerId;
  final int requestedAmountCents;
  final String status;
  final String withdrawalMethod;
  final String paymentEmail;
  final String? additionalNote;
  final DateTime createdAt;

  WithdrawalItem({
    required this.id,
    required this.trainerId,
    required this.requestedAmountCents,
    required this.status,
    required this.withdrawalMethod,
    required this.paymentEmail,
    this.additionalNote,
    required this.createdAt,
  });

  double get amountDollars => requestedAmountCents / 100.0;
  bool get isPending => status == 'pending';
  bool get requiresApproval => isPending && requestedAmountCents >= 200000;

  factory WithdrawalItem.fromJson(Map<String, dynamic> json) => WithdrawalItem(
        id: json['_id']?.toString() ?? '',
        trainerId: json['trainerId']?.toString() ?? '',
        requestedAmountCents:
            (json['requestedAmountCents'] as num?)?.toInt() ?? 0,
        status: json['status']?.toString() ?? 'pending',
        withdrawalMethod: json['withdrawalMethod']?.toString() ?? '',
        paymentEmail: json['paymentEmail']?.toString() ?? '',
        additionalNote: json['additionalNote']?.toString(),
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );
}

// ─── AdminUserModel ──────────────────────────────────────────────────────────

class AdminUserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final bool isVerified;
  final bool isSuspended;
  final String subscriptionTier;
  final DateTime? subscriptionEndDate;
  final DateTime createdAt;
  final String? referredByCode;
  final String? profilePicture;
  final String? phoneNumber;

  AdminUserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.isVerified,
    required this.isSuspended,
    required this.subscriptionTier,
    this.subscriptionEndDate,
    required this.createdAt,
    this.referredByCode,
    this.profilePicture,
    this.phoneNumber,
  });

  String get fullName => '$firstName $lastName'.trim();
  bool get hasActiveSub =>
      subscriptionEndDate != null &&
      subscriptionEndDate!.isAfter(DateTime.now()) &&
      subscriptionTier != 'free';

  AdminUserModel copyWith({
    String? role, bool? isVerified, bool? isSuspended, String? subscriptionTier,
    DateTime? subscriptionEndDate,
  }) => AdminUserModel(
    id: id, email: email, firstName: firstName, lastName: lastName,
    role: role ?? this.role,
    isVerified: isVerified ?? this.isVerified,
    isSuspended: isSuspended ?? this.isSuspended,
    subscriptionTier: subscriptionTier ?? this.subscriptionTier,
    subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
    createdAt: createdAt, referredByCode: referredByCode,
    profilePicture: profilePicture, phoneNumber: phoneNumber,
  );

  factory AdminUserModel.fromJson(Map<String, dynamic> j) => AdminUserModel(
        id: j['_id']?.toString() ?? '',
        email: j['email']?.toString() ?? '',
        firstName: j['firstName']?.toString() ?? '',
        lastName: j['lastName']?.toString() ?? '',
        role: j['role']?.toString() ?? 'user',
        isVerified: j['isVerified'] == true,
        isSuspended: j['isDeleted'] == true,
        subscriptionTier: j['subscriptionTier']?.toString() ?? 'free',
        subscriptionEndDate: j['subscriptionEndDate'] != null
            ? DateTime.tryParse(j['subscriptionEndDate'].toString())
            : null,
        createdAt: j['createdAt'] != null
            ? DateTime.tryParse(j['createdAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
        referredByCode: j['referredByCode']?.toString(),
        profilePicture: j['profilePicture']?.toString(),
        phoneNumber: j['phoneNumber']?.toString(),
      );
}

// ─── Controller ─────────────────────────────────────────────────────────────

/// Key used to persist the admin-specific JWT returned by the bypass endpoint.
/// Separate from the regular user token so admin sessions survive re-logins.
const String _kAdminTokenKey = 'adminToken';

class AdminDashboardController extends GetxController {
  static AdminDashboardController get to => Get.find();

  /// Dio instance — auth header is injected per-request by the interceptor
  /// so token refreshes / late stores are picked up automatically.
  final _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    headers: {'Content-Type': 'application/json'},
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  final _metricsLoading = false.obs;
  final _withdrawalsLoading = false.obs;
  final _actionLoading = ''.obs;

  bool get metricsLoading => _metricsLoading.value;
  bool get withdrawalsLoading => _withdrawalsLoading.value;
  String get actionLoading => _actionLoading.value;

  final _metrics = Rxn<AdminMetrics>();
  final _withdrawals = <WithdrawalItem>[].obs;
  final _error = ''.obs;

  // Filtered user list (for drill-down screens)
  final _filteredUsers = <AdminUserModel>[].obs;
  final _filteredUsersLoading = false.obs;
  final filterSearchQuery = ''.obs;

  AdminMetrics? get metrics => _metrics.value;
  List<WithdrawalItem> get withdrawals => _withdrawals;
  String get error => _error.value;
  List<AdminUserModel> get filteredUsers => _filteredUsers;
  bool get filteredUsersLoading => _filteredUsersLoading.value;

  @override
  void onInit() {
    super.onInit();
    // Attach a request interceptor that reads the stored admin JWT
    // (or falls back to the regular session token) before every call.
    // This avoids the need to cache the token at construction time.
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Prefer the admin-specific JWT issued by the bypass endpoint;
        // fall back to the regular bearer token for backwards compatibility.
        var token = await PrefsHelper.getString(_kAdminTokenKey);
        if (token.isEmpty) {
          token = await PrefsHelper.getString('bearerToken');
        }
        if (token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
    loadAll();
  }

  Future<void> loadAll() async {
    await Future.wait([fetchMetrics(), fetchWithdrawals()]);
  }

  Future<void> fetchMetrics() async {
    _metricsLoading.value = true;
    _error.value = '';
    try {
      final resp = await _dio.get('/api/v1/admin/metrics');
      if (resp.data['success'] == true) {
        _metrics.value =
            AdminMetrics.fromJson(resp.data['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      _error.value = 'Could not load metrics';
    } finally {
      _metricsLoading.value = false;
    }
  }

  Future<void> fetchWithdrawals() async {
    _withdrawalsLoading.value = true;
    try {
      final resp = await _dio.get('/api/v1/withdrawal/admin/all');
      if (resp.data['success'] == true) {
        final list = (resp.data['data'] as List? ?? [])
            .map((e) => WithdrawalItem.fromJson(e as Map<String, dynamic>))
            .toList();
        _withdrawals.assignAll(list);
      }
    } catch (_) {
      // withdrawals section shows empty gracefully
    } finally {
      _withdrawalsLoading.value = false;
    }
  }

  Future<void> approve(String id) async {
    _actionLoading.value = id;
    try {
      await _dio.patch('/api/v1/withdrawal/$id/approve');
      _withdrawals.removeWhere((w) => w.id == id);
      Get.snackbar('✅ Approved', 'Withdrawal approved.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('Error', 'Could not approve withdrawal.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      _actionLoading.value = '';
    }
  }

  Future<void> reject(String id) async {
    _actionLoading.value = id;
    try {
      await _dio.patch('/api/v1/withdrawal/$id/reject',
          data: {'adminNote': 'Rejected by admin'});
      _withdrawals.removeWhere((w) => w.id == id);
      Get.snackbar('❌ Rejected', 'Withdrawal rejected.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('Error', 'Could not reject withdrawal.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      _actionLoading.value = '';
    }
  }

  Future<void> fetchFilteredUsers(String filter) async {
    _filteredUsersLoading.value = true;
    filterSearchQuery.value = '';
    try {
      final resp = await _dio.get(
        '/api/v1/admin/users',
        queryParameters: {'filter': filter, 'limit': 100},
      );
      if (resp.data['success'] == true) {
        final list = (resp.data['data']['users'] as List? ?? [])
            .map((e) => AdminUserModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _filteredUsers.assignAll(list);
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not load users',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      _filteredUsersLoading.value = false;
    }
  }

  Future<void> setVerified(String userId, bool isVerified) async {
    try {
      await _dio.patch('/api/v1/admin/users/$userId/verify',
          data: {'isVerified': isVerified});
      _updateUserInList(userId, (u) => u.copyWith(isVerified: isVerified));
      await fetchMetrics();
    } catch (_) {}
  }

  Future<void> setRole(String userId, String role) async {
    try {
      await _dio.patch('/api/v1/admin/users/$userId/role', data: {'role': role});
      _updateUserInList(userId, (u) => u.copyWith(role: role));
      await fetchMetrics();
    } catch (_) {}
  }

  Future<void> suspendUser(String userId, bool suspend, {String reason = ''}) async {
    try {
      await _dio.patch('/api/v1/admin/users/$userId/suspend',
          data: {'suspend': suspend, 'reason': reason});
      _updateUserInList(userId, (u) => u.copyWith(isSuspended: suspend));
      await fetchMetrics();
    } catch (_) {}
  }

  Future<void> grantAccess(String userId, {String tier = 'annual', int days = 365}) async {
    try {
      await _dio.patch('/api/v1/admin/users/$userId/grant-access',
          data: {'tier': tier, 'days': days});
      final expiry = DateTime.now().add(Duration(days: days));
      _updateUserInList(userId, (u) => u.copyWith(subscriptionTier: tier, subscriptionEndDate: expiry));
      await fetchMetrics();
    } catch (_) {}
  }

  void _updateUserInList(String userId, AdminUserModel Function(AdminUserModel) updater) {
    final idx = _filteredUsers.indexWhere((u) => u.id == userId);
    if (idx >= 0) _filteredUsers[idx] = updater(_filteredUsers[idx]);
  }
}
