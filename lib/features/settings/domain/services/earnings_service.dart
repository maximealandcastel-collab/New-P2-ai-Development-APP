import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/features/settings/data/models/earnings_model.dart';
import 'package:pler_to_pler_app/features/settings/data/models/payment_transaction_model.dart';
import 'package:pler_to_pler_app/features/settings/data/repositories/earnings_repository.dart';

class EarningsService {
  final EarningsRepository _repository;

  EarningsService({required EarningsRepository repository})
      : _repository = repository;

  Future<EarningsModel> getEarnings() async {
    try {
      return await _repository.getEarnings();
    } on AppException {
      if (_repository.hasEarningsCache()) {
        return _repository.getCachedEarnings()!;
      }
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<List<PaymentTransactionModel>> getPayments({
    required int page,
    required int limit,
  }) async {
    try {
      return await _repository.getPayments(page: page, limit: limit);
    } on AppException {
      if (page == 1 && _repository.hasPaymentsCache()) {
        return _repository.getCachedPayments();
      }
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  bool hasEarningsCache() => _repository.hasEarningsCache();
  EarningsModel? getCachedEarnings() => _repository.getCachedEarnings();

  bool hasPaymentsCache() => _repository.hasPaymentsCache();
  List<PaymentTransactionModel> getCachedPayments() => _repository.getCachedPayments();
}
