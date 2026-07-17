import 'dart:io';

import 'package:dio/dio.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
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
    required String feedKey,
  }) async {
    try {
      final result = await _repository.getMyContent(
        categoryId: categoryId,
        page: page,
        limit: limit,
      );
      await _persistFeedPage(feedKey, page, result);
      return result;
    } on AppException {
      if (page == 1) return _repository.getCachedFeed(feedKey);
      rethrow;
    }
  }

  Future<List<ContentModel>> fetchDefaultContent({
    String? search,
    required int page,
    required int limit,
    String? feedKey,
    bool cacheResults = true,
  }) async {
    try {
      final result = await _repository.getDefaultContent(
        search: search,
        page: page,
        limit: limit,
      );
      if (cacheResults && feedKey != null) {
        await _persistFeedPage(feedKey, page, result);
      }
      return result;
    } on AppException {
      if (page == 1 && feedKey != null) {
        return _repository.getCachedFeed(feedKey);
      }
      rethrow;
    }
  }

  List<ContentModel> getCachedFeed(String feedKey) =>
      _repository.getCachedFeed(feedKey);

  bool hasFeedCache(String feedKey) => _repository.hasFeedCache(feedKey);

  Future<void> cacheFeed(String feedKey, List<ContentModel> items) =>
      _repository.cacheFeed(feedKey, items);

  Future<void> invalidateFeedCache(String feedKey) =>
      _repository.invalidateFeedCache(feedKey);

  Future<ContentModel> getDefaultContentById(String contentId) {
    return _repository.getDefaultContentById(contentId);
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

  Future<void> _persistFeedPage(
    String feedKey,
    int page,
    List<ContentModel> items,
  ) async {
    if (page == 1) {
      await _repository.cacheFeed(feedKey, items);
      return;
    }

    await _repository.appendFeedCache(feedKey, items);
  }
}
