import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/constants/app_constants.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/services/api_service.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/data/models/create_exercise_draft_model.dart';
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
          approvedOnly: approvedOnly,
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

  Future<ExerciseBlockModel> generateBlock({
    required String trainerId,
    required String blockName,
    required String category,
    required int count,
    required String context,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.trainerBlocksGenerate(trainerId),
        data: {
          'blockName': blockName,
          'category': category,
          'count': count,
          'context': context,
        },
      );

      return ExerciseBlockModel.fromJson(response.data['data']);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<ExerciseBlockModel> createBlock({
    required String trainerId,
    required String blockName,
    required String description,
    required String category,
    required List<CreateExerciseDraftModel> exercises,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.trainerBlocksCreate(trainerId),
        data: {
          'name': blockName,
          'description': description,
          'category': category,
          'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
        },
      );

      final block = ExerciseBlockModel.fromJson(response.data['data']);
      final updatedCache = [block, ...getCachedBlocks()];
      await _cacheService.put(
        AppConstants.cacheExerciseBlocks,
        updatedCache.map((item) => item.toJson()).toList(),
      );
      return block;
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<ExerciseBlockModel> getBlockById({
    required String blockId,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.blockById(blockId),
      );

      return ExerciseBlockModel.fromJson(response.data['data']);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<void> deleteBlock({
    required String trainerId,
    required String blockId,
  }) async {
    try {
      await _apiService.delete(
        ApiConstants.trainerBlockById(trainerId, blockId),
      );

      final updatedCache = getCachedBlocks()
        ..removeWhere((block) => block.id == blockId);
      await _cacheService.put(
        AppConstants.cacheExerciseBlocks,
        updatedCache.map((item) => item.toJson()).toList(),
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  bool hasCache() => _cacheService.containsKey(AppConstants.cacheExerciseBlocks);
}
