import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/features/trainer/contents/data/models/category_model.dart';
import 'package:pler_to_pler_app/features/trainer/contents/data/repositories/category_repository.dart';

class CategoryService {
  CategoryService({required CategoryRepository repository})
      : _repository = repository;

  final CategoryRepository _repository;

  Future<List<CategoryModel>> fetchMyCategories() async {
    try {
      return await _repository.getMyCategories();
    } on AppException {
      if (!_repository.hasCache()) {
        rethrow;
      }
      return _repository.getCachedCategories();
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  List<CategoryModel> getCachedCategories() =>
      _repository.getCachedCategories();

  Future<void> createCategory({
    required String category,
    required String description,
  }) {
    return _repository.createCategory(
      category: category,
      description: description,
    );
  }

  Future<void> updateCategory({
    required String categoryId,
    required String category,
    required String description,
  }) {
    return _repository.updateCategory(
      categoryId: categoryId,
      category: category,
      description: description,
    );
  }

  Future<void> deleteCategory(String categoryId) {
    return _repository.deleteCategory(categoryId);
  }

  bool hasCache() => _repository.hasCache();
}
