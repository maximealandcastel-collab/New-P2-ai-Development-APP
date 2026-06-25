import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/constants/app_constants.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/helpers/slug_helper.dart';
import 'package:pler_to_pler_app/core/services/api_service.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:pler_to_pler_app/features/contents/data/models/category_model.dart';

class CategoryRepository {
  CategoryRepository({
    required ApiService apiService,
    required CacheService cacheService,
  })  : _apiService = apiService,
        _cacheService = cacheService;

  final ApiService _apiService;
  final CacheService _cacheService;

  Future<List<CategoryModel>> getMyCategories() async {
    try {
      final response = await _apiService.get(ApiConstants.categoryMy);
      final categories = (response.data['data'] as List)
          .map((item) => CategoryModel.fromJson(item))
          .toList();

      await _cacheService.put(
        AppConstants.cacheCategories,
        categories.map((item) => item.toJson()).toList(),
      );

      return categories;
    } on AppException {
      return getCachedCategories();
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  List<CategoryModel> getCachedCategories() {
    try {
      final jsonList =
          _cacheService.get<List>(AppConstants.cacheCategories, defaultValue: []) ??
              [];
      return jsonList.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> createCategory({
    required String category,
    required String description,
  }) async {
    try {
      await _apiService.post(
        ApiConstants.categoryCreate,
        data: {
          'category': category,
          'slug': SlugHelper.fromName(category),
          'description': description,
        },
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<void> updateCategory({
    required String categoryId,
    required String category,
    required String description,
  }) async {
    try {
      await _apiService.put(
        ApiConstants.categoryById(categoryId),
        data: {
          'category': category,
          'slug': SlugHelper.fromName(category),
          'description': description,
        },
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _apiService.delete(ApiConstants.categoryById(categoryId));
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  bool hasCache() => _cacheService.containsKey(AppConstants.cacheCategories);
}
