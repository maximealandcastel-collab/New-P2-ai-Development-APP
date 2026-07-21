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

      final payload = response.data?['data'];
      final notifications = _parseNotifications(payload);
      _lastHasMore = _parseHasMore(payload, notifications.length, limit);

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

  bool? _lastHasMore;

  bool get lastHasMore => _lastHasMore ?? false;

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

      await applyAllReadLocally();
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<void> applyAllReadLocally() async {
    final cached = getCachedNotifications()
        .map((item) => item.copyWith(isRead: true, isReadable: true))
        .toList();
    await saveNotifications(cached);
  }

  Future<void> saveNotifications(List<NotificationModel> items) async {
    await _cacheService.put(
      AppConstants.cacheNotifications,
      items.map((item) => item.toJson()).toList(),
    );
  }

  bool hasCache() =>
      _cacheService.containsKey(AppConstants.cacheNotifications);

  List<NotificationModel> _parseNotifications(dynamic data) {
    if (data is Map) {
      return NotificationListPayload.fromJson(
        Map<String, dynamic>.from(data),
      ).notifications;
    }

    if (data is List) {
      return data
          .whereType<Map>()
          .map(
            (item) => NotificationModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    return const [];
  }

  int _parseUnreadCount(dynamic data) {
    if (data is num) return data.toInt();
    if (data is Map) {
      for (final key in ['unreadCount', 'count', 'total', 'totalUnread']) {
        final value = data[key];
        if (value is num) return value.toInt();
      }
    }
    return 0;
  }

  bool _parseHasMore(dynamic data, int itemCount, int limit) {
    if (data is Map) {
      final pagination = data['pagination'];
      if (pagination is Map) {
        final nextPage = pagination['nextPage'];
        if (nextPage != null) return true;
        if (nextPage == null && pagination.containsKey('nextPage')) {
          return false;
        }

        final currentPage = pagination['currentPage'];
        final totalPage = pagination['totalPage'];
        if (currentPage is num && totalPage is num) {
          return currentPage.toInt() < totalPage.toInt();
        }
      }
    }
    return itemCount >= limit;
  }
}
