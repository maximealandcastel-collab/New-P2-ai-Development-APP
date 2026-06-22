import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/services/api_service.dart';
import 'package:pler_to_pler_app/features/trainer/contents/data/models/content_model.dart';

class ContentRepository {
  ContentRepository({required ApiService apiService}) : _apiService = apiService;

  final ApiService _apiService;

  Future<List<ContentModel>> getMyContent({
    String? categoryId,
    required int page,
    required int limit,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.myContent,
        queryParameters: {
          'categoryId': categoryId ?? '',
          'page': page,
          'limit': limit,
        },
      );

      return (response.data['data'] as List)
          .map((item) => ContentModel.fromJson(item))
          .toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<void> createContent(Map<String, dynamic> data) async {
    try {
      await _apiService.post(ApiConstants.content, data: data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<void> updateContent({
    required String contentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _apiService.put(
        ApiConstants.contentById(contentId),
        data: data,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<void> deleteContent(String contentId) async {
    try {
      await _apiService.delete(ApiConstants.contentById(contentId));
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }
}
