import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/features/trainer/balance/data/models/balance_model.dart';
import 'package:pler_to_pler_app/services/api_urls.dart';
import 'package:pler_to_pler_app/services/network/dio_api_client.dart';

class BalanceController extends GetxController {
  static BalanceController get to => Get.find();

  // ── State ─────────────────────────────────────────────────────
  final _loadingState    = LoadingState.initial.obs;
  final _withdrawState   = LoadingState.initial.obs;
  final _earnings        = Rx<TrainerEarningsModel?>(null);
  final _subscribers     = <TrainerSubscriberPaymentModel>[].obs;
  final _thisMonthCents  = 0.obs;

  LoadingState get loadingState  => _loadingState.value;
  LoadingState get withdrawState => _withdrawState.value;
  TrainerEarningsModel? get earnings => _earnings.value;
  List<TrainerSubscriberPaymentModel> get subscribers => _subscribers;
  int get thisMonthCents => _thisMonthCents.value;

  String get thisMonthFormatted =>
      '\$${(_thisMonthCents.value / 100).toStringAsFixed(0)}';

  // ── Lifecycle ─────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  // ── Fetch earnings + subscriber history ──────────────────────
  Future<void> fetchAll() async {
    _loadingState.value = LoadingState.loading;
    try {
      final results = await Future.wait([
        _fetchEarnings(),
        _fetchSubscribers(),
      ]);
      if (results.every((ok) => ok)) {
        _loadingState.value = LoadingState.loaded;
      } else {
        _loadingState.value = LoadingState.error;
      }
    } catch (e) {
      _loadingState.value = LoadingState.error;
      if (kDebugMode) debugPrint('[Balance] fetchAll error: $e');
    }
  }

  Future<bool> _fetchEarnings() async {
    try {
      final response = await NetworkCaller.instance.getRequest(
        url: '${ApiUrls.baseUrl}/withdrawal/earnings',
      );
      if (response.isSuccess && response.responseBody != null) {
        final data = response.responseBody as Map<String, dynamic>;
        _earnings.value = TrainerEarningsModel.fromJson(data);
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('[Balance] earnings error: $e');
      return false;
    }
  }

  Future<bool> _fetchSubscribers() async {
    try {
      final response = await NetworkCaller.instance.getRequest(
        url: '${ApiUrls.baseUrl}/withdrawal/payments',
      );
      if (response.isSuccess && response.responseBody != null) {
        final list = response.responseBody as List<dynamic>;
        _subscribers.value = list
            .map((e) => TrainerSubscriberPaymentModel.fromJson(
                e as Map<String, dynamic>))
            .toList();

        // Calculate this-month earnings
        final now = DateTime.now();
        _thisMonthCents.value = _subscribers
            .where((p) =>
                p.createdAt.year == now.year &&
                p.createdAt.month == now.month)
            .fold(0, (sum, p) => sum + p.amountCents);
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('[Balance] subscribers error: $e');
      return false;
    }
  }

  // ── Request Withdrawal ────────────────────────────────────────
  Future<bool> requestWithdraw({
    required int amountCents,
    required String method,   // 'paypal' | 'stripe' | 'bank_transfer'
    required String email,
    String? note,
  }) async {
    _withdrawState.value = LoadingState.loading;
    try {
      final response = await NetworkCaller.instance.postRequest(
        url: '${ApiUrls.baseUrl}/withdrawal',
        body: {
          'requestedAmountCents': amountCents,
          'withdrawalMethod': method,
          'paymentEmail': email,
          if (note != null && note.isNotEmpty) 'additionalNote': note,
        },
      );
      if (response.isSuccess) {
        _withdrawState.value = LoadingState.loaded;
        await fetchAll(); // refresh balance
        return true;
      } else {
        _withdrawState.value = LoadingState.error;
        return false;
      }
    } catch (e) {
      _withdrawState.value = LoadingState.error;
      if (kDebugMode) debugPrint('[Balance] withdraw error: $e');
      return false;
    }
  }
}
