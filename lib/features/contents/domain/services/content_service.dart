import 'dart:io';

import 'package:dio/dio.dart';
import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';
import 'package:pler_to_pler_app/features/contents/data/repositories/content_repository.dart';

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

  Future<void> createContent({
    required Map<String, dynamic> fields,
    File? video,
    File? thumbnail,
    ProgressCallback? onSendProgress,
  }) {
    return _repository.createContent(
      fields: fields,
      video: video,
      thumbnail: thumbnail,
      onSendProgress: onSendProgress,
    );
  }

  Future<void> updateContent({
    required String contentId,
    required Map<String, dynamic> fields,
    File? video,
    File? thumbnail,
    ProgressCallback? onSendProgress,
  }) {
    return _repository.updateContent(
      contentId: contentId,
      fields: fields,
      video: video,
      thumbnail: thumbnail,
      onSendProgress: onSendProgress,
    );
  }

  Future<void> deleteContent(String contentId) {
    return _repository.deleteContent(contentId);
  }
}
