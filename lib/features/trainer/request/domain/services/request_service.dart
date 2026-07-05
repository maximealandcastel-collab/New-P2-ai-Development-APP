import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/features/subscribe/domain/services/subscribe_services.dart';
import 'package:pler_to_pler_app/features/trainer/request/data/models/trainer_request_model.dart';
import 'package:pler_to_pler_app/features/trainer/request/data/repositories/request_repository.dart';

class RequestService {
  RequestService({
    required RequestRepository repository,
    required SubscribeServices subscribeService,
  })  : _repository = repository,
        _subscribeService = subscribeService;

  final RequestRepository _repository;
  final SubscribeServices _subscribeService;

  String? _search;

  void updateFilters({String? search}) {
    _search = search;
  }

  Future<void> fetchRequests(int page, int limit) async {
    try {
      await _repository.getRequests(
        page,
        limit,
        search: _search,
      );
    } on AppException {
      if (!_repository.hasCache()) {
        rethrow;
      }
    } catch (e) {
      if (e is UnknownException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  Future<List<TrainerRequestModel>> fetchMoreRequests(
    int page,
    int limit,
  ) async {
    return _repository.fetchMoreRequests(
      page,
      limit,
      search: _search,
    );
  }

  List<TrainerRequestModel> getCachedRequests() =>
      _repository.getCachedRequests();

  bool hasCache() => _repository.hasCache();

  Future<void> acceptRequest(String requestId) =>
      _repository.acceptRequest(requestId);

  Future<void> rejectRequest(String requestId) =>
      _repository.rejectRequest(requestId);

  Future<void> sendInvoice(TrainerRequestModel request) async {
    final trainerId = request.trainerId;
    if (trainerId == null || trainerId.isEmpty) {
      throw UnknownException('Trainer id not found');
    }

    final details = await _subscribeService.trainerDetails(trainerId);
    final premium = details.subscriptionPrice?.premium ?? 29;
    final amount = premium * 100;
    final description =
        '1 Month Personal Training — ${request.clientName}';

    await _repository.createAndSendInvoice(
      requestId: request.id!,
      amount: amount,
      description: description,
    );
  }
}
