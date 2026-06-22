import 'package:pler_to_pler_app/features/trainer/contents/data/models/content_model.dart';
import 'package:pler_to_pler_app/features/trainer/contents/data/repositories/content_repository.dart';

class ContentService {
  ContentService({required ContentRepository repository})
      : _repository = repository;

  final ContentRepository _repository;

  Future<List<ContentModel>> fetchMyContent({
    String? categoryId,
    required int page,
    required int limit,
  }) {
    return _repository.getMyContent(
      categoryId: categoryId,
      page: page,
      limit: limit,
    );
  }

  Future<void> createContent(Map<String, dynamic> data) {
    return _repository.createContent(data);
  }

  Future<void> updateContent({
    required String contentId,
    required Map<String, dynamic> data,
  }) {
    return _repository.updateContent(contentId: contentId, data: data);
  }

  Future<void> deleteContent(String contentId) {
    return _repository.deleteContent(contentId);
  }
}
