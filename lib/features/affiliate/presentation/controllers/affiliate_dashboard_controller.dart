import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/constants/api_constants.dart';

// ─── Models ─────────────────────────────────────────────────────────────────

class AffiliateStats {
  final String name;
  final String promoCode;
  final int revenueSharePercent;
  final int totalReferrals;
  final int paidReferrals;
  final int balanceCents;
  final int totalEarnedCents;
  final int totalWithdrawnCents;
  final int pendingWithdrawalsCents;
  final int availableToWithdrawCents;
  final List<AffiliateWithdrawal> recentWithdrawals;

  AffiliateStats({
    required this.name,
    required this.promoCode,
    required this.revenueSharePercent,
    required this.totalReferrals,
    required this.paidReferrals,
    required this.balanceCents,
    required this.totalEarnedCents,
    required this.totalWithdrawnCents,
    required this.pendingWithdrawalsCents,
    required this.availableToWithdrawCents,
    required this.recentWithdrawals,
  });

  double get balanceDollars => balanceCents / 100.0;
  double get totalEarnedDollars => totalEarnedCents / 100.0;
  double get totalWithdrawnDollars => totalWithdrawnCents / 100.0;
  double get availableDollars => availableToWithdrawCents / 100.0;

  factory AffiliateStats.fromJson(Map<String, dynamic> j) => AffiliateStats(
        name: j['name']?.toString() ?? '',
        promoCode: j['promoCode']?.toString() ?? '',
        revenueSharePercent: (j['revenueSharePercent'] as num?)?.toInt() ?? 60,
        totalReferrals: (j['totalReferrals'] as num?)?.toInt() ?? 0,
        paidReferrals: (j['paidReferrals'] as num?)?.toInt() ?? 0,
        balanceCents: (j['balanceCents'] as num?)?.toInt() ?? 0,
        totalEarnedCents: (j['totalEarnedCents'] as num?)?.toInt() ?? 0,
        totalWithdrawnCents: (j['totalWithdrawnCents'] as num?)?.toInt() ?? 0,
        pendingWithdrawalsCents: (j['pendingWithdrawalsCents'] as num?)?.toInt() ?? 0,
        availableToWithdrawCents: (j['availableToWithdrawCents'] as num?)?.toInt() ?? 0,
        recentWithdrawals: ((j['recentWithdrawals'] as List?) ?? [])
            .map((e) => AffiliateWithdrawal.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}

class AffiliateWithdrawal {
  final int amountCents;
  final String paymentMethod;
  final String paymentEmail;
  final String status;
  final DateTime requestedAt;

  AffiliateWithdrawal({
    required this.amountCents,
    required this.paymentMethod,
    required this.paymentEmail,
    required this.status,
    required this.requestedAt,
  });

  double get amountDollars => amountCents / 100.0;

  factory AffiliateWithdrawal.fromJson(Map<String, dynamic> j) => AffiliateWithdrawal(
        amountCents: (j['amountCents'] as num?)?.toInt() ?? 0,
        paymentMethod: j['paymentMethod']?.toString() ?? '',
        paymentEmail: j['paymentEmail']?.toString() ?? '',
        status: j['status']?.toString() ?? 'pending',
        requestedAt: j['requestedAt'] != null
            ? DateTime.tryParse(j['requestedAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );
}

class AffiliateReferral {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String subscriptionTier;
  final bool isVerified;
  final DateTime joinedAt;

  AffiliateReferral({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.subscriptionTier,
    required this.isVerified,
    required this.joinedAt,
  });

  bool get isPaid => ['monthly', 'annual', 'paid', 'premium'].contains(subscriptionTier);
  String get displayName => '$firstName $lastName'.trim();

  factory AffiliateReferral.fromJson(Map<String, dynamic> j) => AffiliateReferral(
        id: j['_id']?.toString() ?? '',
        firstName: j['firstName']?.toString() ?? '',
        lastName: j['lastName']?.toString() ?? '',
        email: j['email']?.toString() ?? '',
        subscriptionTier: j['subscriptionTier']?.toString() ?? 'free',
        isVerified: j['isVerified'] == true,
        joinedAt: j['createdAt'] != null
            ? DateTime.tryParse(j['createdAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );
}

// ─── Controller ─────────────────────────────────────────────────────────────

class AffiliateDashboardController extends GetxController {
  static AffiliateDashboardController get to => Get.find();

  String promoCode; // mutable: allows DI .new registration
  AffiliateDashboardController({this.promoCode = ''});

  late final Dio _dio;

  final _loading = false.obs;
  final _referralsLoading = false.obs;
  final _withdrawLoading = false.obs;

  bool get loading => _loading.value;
  bool get referralsLoading => _referralsLoading.value;
  bool get withdrawLoading => _withdrawLoading.value;

  final _stats = Rxn<AffiliateStats>();
  final _referrals = <AffiliateReferral>[].obs;
  final _error = ''.obs;

  AffiliateStats? get stats => _stats.value;
  List<AffiliateReferral> get referrals => _referrals;
  String get error => _error.value;

  @override
  void onInit() {
    super.onInit();
    // Pick up promoCode from navigation arguments when screen is pushed with args
    final _navArgs = Get.arguments;
    if (_navArgs is Map && (_navArgs['promoCode'] as String? ?? '').isNotEmpty) {
      promoCode = _navArgs['promoCode'] as String;
    }
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      headers: {
        'x-affiliate-code': promoCode,
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));
    loadAll();
  }

  Future<void> loadAll() async {
    _loading.value = true;
    _error.value = '';
    try {
      await Future.wait([fetchDashboard(), fetchReferrals()]);
    } finally {
      _loading.value = false;
    }
  }

  Future<void> fetchDashboard() async {
    try {
      final resp = await _dio.get(ApiConstants.affiliateDashboard);
      if (resp.data['success'] == true) {
        _stats.value = AffiliateStats.fromJson(
            resp.data['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      _error.value = 'Could not load dashboard';
    }
  }

  Future<void> fetchReferrals() async {
    _referralsLoading.value = true;
    try {
      final resp = await _dio.get(ApiConstants.affiliateReferrals);
      if (resp.data['success'] == true) {
        final list = (resp.data['data']['users'] as List? ?? [])
            .map((e) => AffiliateReferral.fromJson(e as Map<String, dynamic>))
            .toList();
        _referrals.assignAll(list);
      }
    } catch (_) {
      // show empty gracefully
    } finally {
      _referralsLoading.value = false;
    }
  }

  Future<bool> requestWithdraw({
    required int amountCents,
    required String paymentMethod,
    required String paymentEmail,
  }) async {
    _withdrawLoading.value = true;
    try {
      final resp = await _dio.post(ApiConstants.affiliateWithdraw, data: {
        'amountCents': amountCents,
        'paymentMethod': paymentMethod,
        'paymentEmail': paymentEmail,
      });
      if (resp.data['success'] == true) {
        await fetchDashboard();
        return true;
      }
      return false;
    } catch (e) {
      final msg = (e is DioException)
          ? (e.response?.data['message'] ?? 'Withdrawal failed')
          : 'Withdrawal failed';
      Get.snackbar('Error', msg.toString(),
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      _withdrawLoading.value = false;
    }
  }
}
