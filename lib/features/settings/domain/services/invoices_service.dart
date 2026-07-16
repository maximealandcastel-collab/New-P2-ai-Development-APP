import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/features/trainer/clients/data/models/client_invoice_model.dart';
import 'package:pler_to_pler_app/features/trainer/clients/data/repositories/client_repository.dart';

class InvoicesService {
  InvoicesService({required ClientRepository repository})
      : _repository = repository;

  final ClientRepository _repository;

  String? _status;

  String? get status => _status;

  void updateFilters({String? status}) {
    _status = status;
  }

  Future<void> fetchInvoices(int page, int limit) async {
    try {
      await _repository.getInvoices(
        page,
        limit,
        status: _status,
      );
    } on AppException {
      if (!_repository.hasCache(_status)) {
        rethrow;
      }
    } catch (e) {
      if (e is UnknownException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  Future<List<ClientInvoiceModel>> fetchMoreInvoices(
    int page,
    int limit,
  ) async {
    return _repository.fetchMoreInvoices(
      page,
      limit,
      status: _status,
    );
  }

  List<ClientInvoiceModel> getCachedInvoices() =>
      _repository.getCachedInvoices(_status);

  bool hasCache() => _repository.hasCache(_status);
}
