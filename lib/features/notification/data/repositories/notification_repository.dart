import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/constants/app_constants.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/services/api_service.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:pler_to_pler_app/features/notification/data/models/notification_model.dart';

class NotificationRepository {
  NotificationRepository({
    required ApiService apiService,
    required CacheService cacheService,
  }) : _apiService = apiService,
       _cacheService = cacheService;

  final ApiService _apiService;
  final CacheService _cacheService;

  Future<List<NotificationModel>> getNotifications(int page, int limit) async {
    try {
      final response = await _apiService.get(
        ApiConstants.notifications,
        queryParameters: {'page': page, 'limit': limit},
      );

      final notifications = _parseNotifications(response.data?['data']);

      if (page == 1) {
        await _cacheService.put(
          AppConstants.cacheNotifications,
          notifications.map((item) => item.toJson()).toList(),
        );
      }

      return notifications;
    } on AppException {
      if (page == 1) return getCachedNotifications();
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<List<NotificationModel>> fetchMoreNotifications(
    int page,
    int limit,
  ) async {
    final response = await getNotifications(page, limit);

    if (response.isNotEmpty) {
      final currentCached = getCachedNotifications();
      final newList = [...currentCached, ...response];
      await _cacheService.put(
        AppConstants.cacheNotifications,
        newList.map((item) => item.toJson()).toList(),
      );
    }

    return response;
  }

  List<NotificationModel> getCachedNotifications() {
    try {
      final jsonList =
          _cacheService.get<List>(
            AppConstants.cacheNotifications,
            defaultValue: [],
          ) ??
          [];
      return jsonList
          .map((json) => NotificationModel.fromJson(
                Map<String, dynamic>.from(json as Map),
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _apiService.get(
        ApiConstants.notificationsUnreadCount,
      );
      return _parseUnreadCount(response.data?['data']);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _apiService.patch(ApiConstants.notificationsReadAll);

      final cached = getCachedNotifications()
          .map((item) => item.copyWith(isRead: true))
          .toList();
      await _cacheService.put(
        AppConstants.cacheNotifications,
        cached.map((item) => item.toJson()).toList(),
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  bool hasCache() =>
      _cacheService.containsKey(AppConstants.cacheNotifications);

  List<NotificationModel> _parseNotifications(dynamic data) {
    final list = _extractList(data);
    return list
        .whereType<Map>()
        .map(
          (item) => NotificationModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      for (final key in [
        'notifications',
        'items',
        'docs',
        'results',
        'data',
      ]) {
        final value = data[key];
        if (value is List) return value;
      }
    }
    return const [];
  }

  int _parseUnreadCount(dynamic data) {
    if (data is num) return data.toInt();
    if (data is Map) {
      for (final key in ['unreadCount', 'count', 'total']) {
        final value = data[key];
        if (value is num) return value.toInt();
      }
    }
    return 0;
  }
}
