import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/find_trainer_model.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/iap_verify_result_model.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/trainer_details_model.dart';
import 'package:pler_to_pler_app/features/subscribe/data/repositories/subscribe_repository.dart';

class SubscribeServices {
  final SubscribeRepository _repository;

  SubscribeServices({required SubscribeRepository repository})
    : _repository = repository;

  Future<void> fetchPolls(
    int currentPage,
    int limit, {
    String? search,
    String? specialty,
    String? gender,
  }) async {
    try {
      await _repository.getTrainers(
        currentPage,
        limit,
        search: search,
        specialty: specialty,
        gender: gender,
      );
    } on AppException {
      if (!_repository.hasCache()) rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<List<FindTrainerModel>> fetchMorePolls(
    int offset,
    int limit, {
    String? specialty,
    String? gender,
  }) async {
    return await _repository.fetchMoreTrainer(offset, limit, specialty: specialty, gender: gender);
  }

  List<FindTrainerModel> getCachedTrainers() => _repository.getCachedTrainers();

  Future<TrainerDetailsModel> trainerDetails(String trainerId) async {
    return await _repository.trainerDetails(trainerId);
  }

  Future<void> trainerRequest({
    required String trainerId,
    required String note,
  }) async {
    return await _repository.trainerRequest(trainerId: trainerId, note: note);
  }

  Future<IapVerifyResultModel> verifyIap({
    required String platform,
    required String productId,
    required String purchaseId,
    required String verificationData,
  }) {
    return _repository.verifyIap(
      platform: platform,
      productId: productId,
      purchaseId: purchaseId,
      verificationData: verificationData,
    );
  }

  bool hasCache() => _repository.hasCache();
}
