import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/default_checkout_model.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/find_trainer_model.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/trainer_details_model.dart';
import 'package:pler_to_pler_app/features/subscribe/data/repositories/subscribe_repository.dart';

class SubscribeServices {
  final SubscribeRepository _repository;

  SubscribeServices({required SubscribeRepository repository})
    : _repository = repository;

  Future<void> fetchPolls(int currentPage, int limit, {String? search}) async {
    try {
      await Future.wait([
        _repository.getTrainers(currentPage, limit, search: search),
      ]);
    } on AppException {
      if (!_repository.hasCache()) {
        rethrow;
      }
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<List<FindTrainerModel>> fetchMorePolls(int offset, int limit) async {
    return await _repository.fetchMoreTrainer(offset, limit);
  }

  List<FindTrainerModel> getCachedTrainers() {
    return _repository.getCachedTrainers();
  }

  Future<TrainerDetailsModel> trainerDetails(String trainerId) async {
    return await _repository.trainerDetails(trainerId);
  }

  Future<void> trainerRequest({
    required String trainerId,
    required String note,
  }) async {
    return await _repository.trainerRequest(trainerId: trainerId, note: note);
  }

  Future<DefaultCheckoutModel> createDefaultCheckout({
    required String tier,
    String? promoCode,
  }) async {
    return await _repository.createDefaultCheckout(
      tier: tier,
      promoCode: promoCode,
    );
  }

  bool hasCache() {
    return _repository.hasCache();
  }
}
