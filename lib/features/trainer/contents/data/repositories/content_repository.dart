import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
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
          'categoryId': ?categoryId,
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

  Future<void> createContent({
    required Map<String, dynamic> fields,
    File? video,
    File? thumbnail,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = await _buildContentFormData(
        fields: fields,
        video: video,
        thumbnail: thumbnail,
      );

      await _apiService.postFormData(
        ApiConstants.content,
        formData: formData,
        onSendProgress: onSendProgress,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<void> updateContent({
    required String contentId,
    required Map<String, dynamic> fields,
    File? video,
    File? thumbnail,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = await _buildContentFormData(
        fields: fields,
        video: video,
        thumbnail: thumbnail,
      );

      await _apiService.putFormData(
        ApiConstants.contentById(contentId),
        formData: formData,
        onSendProgress: onSendProgress,
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

  Future<FormData> _buildContentFormData({
    required Map<String, dynamic> fields,
    File? video,
    File? thumbnail,
  }) async {
    final map = <String, dynamic>{};

    for (final entry in fields.entries) {
      final value = entry.value;
      if (value == null) continue;

      if (value is List) {
        map[entry.key] = jsonEncode(value);
      } else {
        map[entry.key] = value;
      }
    }

    if (video != null) {
      map['video'] = await MultipartFile.fromFile(
        video.path,
        filename: _fileName(video.path),
      );
    }

    if (thumbnail != null) {
      map['thumbnail'] = await MultipartFile.fromFile(
        thumbnail.path,
        filename: _fileName(thumbnail.path),
      );
    }

    return FormData.fromMap(map);
  }

  String _fileName(String path) {
    final segments = path.split('/');
    return segments.isNotEmpty ? segments.last : 'file';
  }
}
