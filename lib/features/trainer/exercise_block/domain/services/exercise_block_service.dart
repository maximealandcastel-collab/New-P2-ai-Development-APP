import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/features/profile/domain/services/profile_service.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/data/models/exercise_block_model.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/data/repositories/exercise_block_repository.dart';

class ExerciseBlockService {
  ExerciseBlockService({
    required ExerciseBlockRepository repository,
    required ProfileService profileService,
  })  : _repository = repository,
        _profileService = profileService;

  final ExerciseBlockRepository _repository;
  final ProfileService _profileService;

  Future<String?> resolveTrainerId() async {
    final cachedId = _profileService.getCachedUserData()?.sId;
    if (cachedId != null && cachedId.isNotEmpty) return cachedId;

    await _profileService.fetchUserProfile();
    return _profileService.getCachedUserData()?.sId;
  }

  Future<void> fetchBlocks(
    int page,
    int limit) async {
    try {
      final trainerId = await resolveTrainerId();
      if (trainerId == null || trainerId.isEmpty) {
        throw UnknownException('User ID not found');
      }

      await _repository.getBlocks(
        trainerId,
        page,
        limit,
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

  Future<List<ExerciseBlockModel>> fetchMoreBlocks(
    int page,
    int limit) async {
    final trainerId = await resolveTrainerId();
    if (trainerId == null || trainerId.isEmpty) {
      throw UnknownException('User ID not found');
    }

    return _repository.fetchMoreBlocks(
      trainerId,
      page,
      limit,
    );
  }

  List<ExerciseBlockModel> getCachedBlocks() =>
      _repository.getCachedBlocks();

  bool hasCache() => _repository.hasCache();
}
