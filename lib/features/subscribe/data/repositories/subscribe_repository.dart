import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/constants/app_constants.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/services/api_service.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/find_trainer_model.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/trainer_details_model.dart';

class SubscribeRepository {
  final ApiService _apiService;
  final CacheService _cacheService;

  SubscribeRepository({
    required ApiService apiService,
    required CacheService cacheService,
  }) : _apiService = apiService,
       _cacheService = cacheService;

  Future<List<FindTrainerModel>> getTrainers(
    int page,
    int limit, {
    String? search,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.trainers(page, limit),
        queryParameters: {'search': search},
      );

      final trainers = (response.data['data'] as List)
          .map((e) => FindTrainerModel.fromJson(e))
          .toList();

      await _cacheService.put(
        AppConstants.cacheTrainers,
        trainers.map((e) => e.toJson()).toList(),
      );

      return trainers;
    } on AppException {
      return getCachedTrainers();
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  List<FindTrainerModel> getCachedTrainers() {
    try {
      final jsonList =
          _cacheService.get<List>(AppConstants.cacheTrainers, defaultValue: []) ??
          [];
      return jsonList.map((json) => FindTrainerModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<FindTrainerModel>> fetchMoreTrainer(int page, int limit) async {
    final response = await getTrainers(page, limit);
    if (response.isNotEmpty) {
      final currentCached = getCachedTrainers();
      final newList = [...currentCached, ...response];
      await _cacheService.put(
        AppConstants.cacheTrainers,
        newList.map((e) => e.toJson()).toList(),
      );
    }
    return response;
  }


  Future<TrainerDetailsModel> trainerDetails(String trainerID) async {
    try {
      final response = await _apiService.get(
        ApiConstants.trainerDetails(trainerID),
      );
      return TrainerDetailsModel.fromJson(response.data['data']);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<void> trainerRequest({
    required String trainerId,
    required String note,
  }) async {
    try {
      await _apiService.post(
        ApiConstants.trainerRequest,
        data: {
          "trainerId": trainerId,
          "note": note,
        },
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  bool hasCache() {
    return _cacheService.containsKey(AppConstants.cacheTrainers);
  }
}
