import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/constants/app_constants.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/services/api_service.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:pler_to_pler_app/features/settings/data/models/earnings_model.dart';
import 'package:pler_to_pler_app/features/settings/data/models/payment_transaction_model.dart';

class EarningsRepository {
  final ApiService _apiService;
  final CacheService _cacheService;

  EarningsRepository({
    required ApiService apiService,
    required CacheService cacheService,
  })  : _apiService = apiService,
        _cacheService = cacheService;

  Future<EarningsModel> getEarnings() async {
    try {
      final response = await _apiService.get(ApiConstants.trainerEarnings);
      final model = EarningsModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );

      await _cacheService.put(
        AppConstants.cacheTrainerEarnings,
        model.toJson(),
      );

      return model;
    } on AppException {
      if (hasEarningsCache()) {
        return getCachedEarnings()!;
      }
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  bool hasEarningsCache() {
    return _cacheService.containsKey(AppConstants.cacheTrainerEarnings);
  }

  EarningsModel? getCachedEarnings() {
    try {
      final cachedJson = _cacheService.get<Map>(AppConstants.cacheTrainerEarnings);
      if (cachedJson == null) return null;
      return EarningsModel.fromJson(
        Map<String, dynamic>.from(cachedJson),
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<PaymentTransactionModel>> getPayments({
    required int page,
    required int limit,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.trainerPayments(page: page, limit: limit),
      );
      
      final payload = response.data;
      if (payload == null) return [];
      
      final dataList = payload['data'] as List? ?? [];
      final payments = dataList
          .map((item) => PaymentTransactionModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();

      if (page == 1) {
        await _cacheService.put(
          AppConstants.cacheTrainerPayments,
          payments.map((item) => item.toJson()).toList(),
        );
      }

      return payments;
    } on AppException {
      if (page == 1 && hasPaymentsCache()) {
        return getCachedPayments();
      }
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  bool hasPaymentsCache() {
    return _cacheService.containsKey(AppConstants.cacheTrainerPayments);
  }

  List<PaymentTransactionModel> getCachedPayments() {
    try {
      final list = _cacheService.get<List>(AppConstants.cacheTrainerPayments);
      if (list == null) return [];
      return list
          .map((item) => PaymentTransactionModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
