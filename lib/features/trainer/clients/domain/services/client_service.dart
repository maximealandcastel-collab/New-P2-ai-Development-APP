import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/features/trainer/clients/data/models/client_invoice_model.dart';
import 'package:pler_to_pler_app/features/trainer/clients/data/repositories/client_repository.dart';

class ClientService {
  ClientService({required ClientRepository repository})
      : _repository = repository;

  final ClientRepository _repository;

  String _status = 'paid';
  String? _search;

  String get status => _status;

  void updateFilters({required String status, String? search}) {
    _status = status;
    _search = search;
  }

  Future<void> fetchInvoices(int page, int limit) async {
    try {
      await _repository.getInvoices(
        page,
        limit,
        status: _status,
        search: _search,
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
      search: _search,
    );
  }

  List<ClientInvoiceModel> getCachedInvoices() =>
      _repository.getCachedInvoices(_status);

  bool hasCache() => _repository.hasCache(_status);
}
