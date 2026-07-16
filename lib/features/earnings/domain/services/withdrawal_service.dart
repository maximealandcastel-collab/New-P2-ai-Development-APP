import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/features/earnings/data/repositories/withdrawal_repository.dart';

class WithdrawalService {
  final WithdrawalRepository _repository;

  WithdrawalService({required WithdrawalRepository repository})
      : _repository = repository;

  Future<void> submitWithdrawal(Map<String, dynamic> body) async {
    try {
      await _repository.submitWithdrawal(body);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }
}
