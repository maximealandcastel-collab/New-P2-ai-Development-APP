import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/constants/api_constants.dart';

// ─── Lightweight models (inline — no separate file risk) ───────────────────

class AdminMetrics {
  final int totalUsers;
  final int todaySignups;
  final int weekSignups;
  final int activeSubscriptions;
  final int adminBypassUsers;
  final List<Map<String, dynamic>> roleBreakdown;

  AdminMetrics({
    required this.totalUsers,
    required this.todaySignups,
    required this.weekSignups,
    required this.activeSubscriptions,
    required this.adminBypassUsers,
    required this.roleBreakdown,
  });

  factory AdminMetrics.fromJson(Map<String, dynamic> json) {
    final overview = json['overview'] as Map<String, dynamic>? ?? {};
    final roles = (json['roleBreakdown'] as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    return AdminMetrics(
      totalUsers: (overview['totalUsers'] as num?)?.toInt() ?? 0,
      todaySignups: (overview['todaySignups'] as num?)?.toInt() ?? 0,
      weekSignups: (overview['weekSignups'] as num?)?.toInt() ?? 0,
      activeSubscriptions: (overview['activeSubscriptions'] as num?)?.toInt() ?? 0,
      adminBypassUsers: (overview['adminBypassUsers'] as num?)?.toInt() ?? 0,
      roleBreakdown: roles,
    );
  }
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
  bool get requiresApproval => isPending && requestedAmountCents >= 200000; // ≥ $2k

  factory WithdrawalItem.fromJson(Map<String, dynamic> json) {
    return WithdrawalItem(
      id: json['_id']?.toString() ?? '',
      trainerId: json['trainerId']?.toString() ?? '',
      requestedAmountCents: (json['requestedAmountCents'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'pending',
      withdrawalMethod: json['withdrawalMethod']?.toString() ?? '',
      paymentEmail: json['paymentEmail']?.toString() ?? '',
      additionalNote: json['additionalNote']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

// ─── Controller ────────────────────────────────────────────────────────────

class AdminDashboardController extends GetxController {
  static AdminDashboardController get to => Get.find();

  static const _adminKey = '2931';

  final _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    headers: {'x-admin-key': _adminKey, 'Content-Type': 'application/json'},
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  // ─── State ───────────────────────────────────────────────────────────────
  final _metricsLoading = false.obs;
  final _withdrawalsLoading = false.obs;
  final _actionLoading = ''.obs; // holds id of withdrawal being processed

  bool get metricsLoading => _metricsLoading.value;
  bool get withdrawalsLoading => _withdrawalsLoading.value;
  String get actionLoading => _actionLoading.value;

  final _metrics = Rxn<AdminMetrics>();
  final _withdrawals = <WithdrawalItem>[].obs;
  final _error = ''.obs;

  AdminMetrics? get metrics => _metrics.value;
  List<WithdrawalItem> get withdrawals => _withdrawals;
  List<WithdrawalItem> get pendingLarge =>
      _withdrawals.where((w) => w.requiresApproval).toList();
  String get error => _error.value;

  @override
  void onInit() {
    super.onInit();
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
        _metrics.value = AdminMetrics.fromJson(
          resp.data['data'] as Map<String, dynamic>,
        );
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
      Get.snackbar('✅ Approved', 'Withdrawal approved successfully.',
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
      Get.snackbar('❌ Rejected', 'Withdrawal has been rejected.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('Error', 'Could not reject withdrawal.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      _actionLoading.value = '';
    }
  }
}
