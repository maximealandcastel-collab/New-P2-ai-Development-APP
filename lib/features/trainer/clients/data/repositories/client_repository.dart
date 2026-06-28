import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/constants/app_constants.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/services/api_service.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:pler_to_pler_app/features/trainer/clients/data/models/client_invoice_model.dart';

class ClientRepository {
  ClientRepository({
    required ApiService apiService,
    required CacheService cacheService,
  })  : _apiService = apiService,
        _cacheService = cacheService;

  final ApiService _apiService;
  final CacheService _cacheService;

  String _cacheKey(String status) =>
      status == 'sent'
          ? AppConstants.cacheTrainerClientsSent
          : AppConstants.cacheTrainerClientsPaid;

  Future<List<ClientInvoiceModel>> getInvoices(
    int page,
    int limit, {
    required String status,
    String? search,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.trainerInvoices,
        queryParameters: {
          'status': status,
          'page': page,
          'limit': limit,
          if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        },
      );

      final invoices = (response.data['data'] as List)
          .map((item) => ClientInvoiceModel.fromJson(item))
          .toList();

      if (page == 1) {
        await _cacheService.put(
          _cacheKey(status),
          invoices.map((item) => item.toJson()).toList(),
        );
      }

      return invoices;
    } on AppException {
      if (page == 1) return getCachedInvoices(status);
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  List<ClientInvoiceModel> getCachedInvoices(String status) {
    try {
      final jsonList =
          _cacheService.get<List>(_cacheKey(status), defaultValue: []) ?? [];
      return jsonList
          .map((json) => ClientInvoiceModel.fromJson(json))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<ClientInvoiceModel>> fetchMoreInvoices(
    int page,
    int limit, {
    required String status,
    String? search,
  }) async {
    final response = await getInvoices(
      page,
      limit,
      status: status,
      search: search,
    );

    if (response.isNotEmpty) {
      final currentCached = getCachedInvoices(status);
      final newList = [...currentCached, ...response];
      await _cacheService.put(
        _cacheKey(status),
        newList.map((item) => item.toJson()).toList(),
      );
    }

    return response;
  }

  bool hasCache(String status) =>
      _cacheService.containsKey(_cacheKey(status));
}
