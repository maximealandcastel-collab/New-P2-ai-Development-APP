import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/constants/app_constants.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/services/api_service.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/data/models/exercise_block_model.dart';

class ExerciseBlockRepository {
  ExerciseBlockRepository({
    required ApiService apiService,
    required CacheService cacheService,
  })  : _apiService = apiService,
        _cacheService = cacheService;

  final ApiService _apiService;
  final CacheService _cacheService;

  Future<List<ExerciseBlockModel>> getBlocks(
    String trainerId,
    int page,
    int limit, {
    bool approvedOnly = true,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.trainerBlocks(
          trainerId,
          page,
          limit,
        ),
      );

      final blocks = (response.data['data'] as List)
          .map((item) => ExerciseBlockModel.fromJson(item))
          .toList();

      if (page == 1) {
        await _cacheService.put(
          AppConstants.cacheExerciseBlocks,
          blocks.map((item) => item.toJson()).toList(),
        );
      }

      return blocks;
    } on AppException {
      if (page == 1) return getCachedBlocks();
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  List<ExerciseBlockModel> getCachedBlocks() {
    try {
      final jsonList = _cacheService.get<List>(
            AppConstants.cacheExerciseBlocks,
            defaultValue: [],
          ) ??
          [];
      return jsonList
          .map((json) => ExerciseBlockModel.fromJson(json))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<ExerciseBlockModel>> fetchMoreBlocks(
    String trainerId,
    int page,
    int limit, {
    bool approvedOnly = true,
  }) async {
    final response =
        await getBlocks(trainerId, page, limit, approvedOnly: approvedOnly);
    if (response.isNotEmpty) {
      final currentCached = getCachedBlocks();
      final newList = [...currentCached, ...response];
      await _cacheService.put(
        AppConstants.cacheExerciseBlocks,
        newList.map((item) => item.toJson()).toList(),
      );
    }
    return response;
  }

  bool hasCache() => _cacheService.containsKey(AppConstants.cacheExerciseBlocks);
}
