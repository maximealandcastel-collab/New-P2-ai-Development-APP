import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/constants/app_constants.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/services/api_service.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:pler_to_pler_app/features/trainer/request/data/models/trainer_request_model.dart';

class RequestRepository {
  RequestRepository({
    required ApiService apiService,
    required CacheService cacheService,
  })  : _apiService = apiService,
        _cacheService = cacheService;

  final ApiService _apiService;
  final CacheService _cacheService;

  Future<List<TrainerRequestModel>> getRequests(
    int page,
    int limit, {
    String? search,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.trainerRequestAll,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null && search.trim().isNotEmpty)
            'search': search.trim(),
        },
      );

      final requests = (response.data['data'] as List)
          .map((item) => TrainerRequestModel.fromJson(item))
          .toList();

      if (page == 1) {
        await _cacheService.put(
          AppConstants.cacheTrainerRequests,
          requests.map((item) => item.toJson()).toList(),
        );
      }

      return requests;
    } on AppException {
      if (page == 1) return getCachedRequests();
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  List<TrainerRequestModel> getCachedRequests() {
    try {
      final jsonList = _cacheService.get<List>(
            AppConstants.cacheTrainerRequests,
            defaultValue: [],
          ) ??
          [];
      return jsonList
          .map((json) => TrainerRequestModel.fromJson(json))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<TrainerRequestModel>> fetchMoreRequests(
    int page,
    int limit, {
    String? search,
  }) async {
    final response = await getRequests(
      page,
      limit,
      search: search,
    );

    if (response.isNotEmpty) {
      final currentCached = getCachedRequests();
      final newList = [...currentCached, ...response];
      await _cacheService.put(
        AppConstants.cacheTrainerRequests,
        newList.map((item) => item.toJson()).toList(),
      );
    }

    return response;
  }

  Future<void> acceptRequest(String requestId) async {
    try {
      await _apiService.patch(ApiConstants.acceptTrainerRequest(requestId));
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<void> rejectRequest(String requestId) async {
    try {
      await _apiService.patch(ApiConstants.rejectTrainerRequest(requestId));
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<void> createAndSendInvoice({
    required String requestId,
    required int amount,
    required String description,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.invoice,
        data: {
          'requestId': requestId,
          'amount': amount,
          'description': description,
        },
      );

      final invoiceData = response.data['data'];
      final invoiceId = invoiceData is Map<String, dynamic>
          ? invoiceData['_id'] as String?
          : null;

      if (invoiceId == null || invoiceId.isEmpty) {
        throw UnknownException('Invoice id not found in response');
      }

      await _apiService.patch(ApiConstants.sendInvoice(invoiceId));
    } on AppException {
      rethrow;
    } catch (e) {
      if (e is UnknownException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  bool hasCache() => _cacheService.containsKey(AppConstants.cacheTrainerRequests);
}
