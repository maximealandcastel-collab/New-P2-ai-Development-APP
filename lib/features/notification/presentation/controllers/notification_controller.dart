import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/services/connectivity_service.dart';
import 'package:pler_to_pler_app/core/services/paginated_list.dart';
import 'package:pler_to_pler_app/core/services/paginated_loader_ui.dart';
import 'package:pler_to_pler_app/features/notification/data/models/notification_model.dart';
import 'package:pler_to_pler_app/features/notification/domain/services/notification_service.dart';

class NotificationController extends GetxController with PaginatedLoaderUi {
  NotificationController({
    required NotificationService service,
    required ConnectivityService connectivityService,
  }) : _service = service,
       _connectivityService = connectivityService;

  final NotificationService _service;
  final ConnectivityService _connectivityService;

  static NotificationController get to => Get.find();

  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;
  final RxInt _unreadCount = 0.obs;

  late final PaginatedList<NotificationModel> notificationsList;

  bool _listLoadStarted = false;

  LoadingState get loadingState => _loadingState.value;
  int get unreadCount => _unreadCount.value;
  bool get hasUnread =>
      _unreadCount.value > 0 ||
      notificationsList.items.any((item) => !item.isRead);
  List<NotificationModel> get notifications => notificationsList.items;
  ScrollController? get scrollController => notificationsList.scrollController;

  @override
  LoadingState get paginationContentState => loadingState;

  @override
  PaginatedList<dynamic> get paginatedList => notificationsList;

  @override
  void onInit() {
    super.onInit();
    notificationsList = PaginatedList<NotificationModel>(
      limit: 10,
      fetchPage: _fetchNotificationsPage,
    );
    notificationsList.initScroll();
    ever(_connectivityService.isConnected, (isConnected) {
      if (!isConnected) return;
      fetchUnreadCount();
      if (_listLoadStarted) {
        _loadData(showFullLoader: false);
      }
    });
    fetchUnreadCount();
  }

  /// Safe to call from build — loads the list only once until disposed.
  Future<void> ensureListLoaded() async {
    if (_listLoadStarted) return;
    _listLoadStarted = true;
    await _loadData();
  }

  Future<List<NotificationModel>> _fetchNotificationsPage(
    int page,
    int limit,
  ) async {
    List<NotificationModel> result;
    if (page == 1) {
      await _service.fetchNotifications(page, limit);
      result = _service.getCachedNotifications();
    } else {
      result = await _service.fetchMoreNotifications(page, limit);
    }
    notificationsList.hasMore.value = _service.lastHasMore;
    return result;
  }

  Future<void> _loadData({bool showFullLoader = true}) async {
    try {
      final cached = _service.getCachedNotifications();
      final hasUsableCache = cached.isNotEmpty;
      final isOnline = _connectivityService.isConnected.value;

      if (showFullLoader) {
        if (hasUsableCache) {
          notificationsList.items.value = cached;
          _loadingState.value = LoadingState.loaded;
        } else {
          notificationsList.items.clear();
          _loadingState.value = LoadingState.loading;
        }
      }

      if (!isOnline) {
        if (!hasUsableCache) _loadingState.value = LoadingState.offline;
        return;
      }

      try {
        await notificationsList.loadFirst();
        _loadingState.value = LoadingState.loaded;
        await fetchUnreadCount();
      } on AppException catch (e) {
        if (!hasUsableCache) _loadingState.value = LoadingState.error;
        if (kDebugMode) debugPrint('Fetch notifications error: $e');
      }
    } catch (e) {
      final cached = _service.getCachedNotifications();
      if (cached.isNotEmpty) {
        notificationsList.items.value = cached;
        _loadingState.value = LoadingState.loaded;
      } else {
        _loadingState.value = LoadingState.error;
      }
      if (kDebugMode) debugPrint('Unexpected notifications error: $e');
    }
  }

  Future<void> fetchUnreadCount() async {
    if (!_connectivityService.isConnected.value) return;
    try {
      _unreadCount.value = await _service.getUnreadCount();
    } catch (e) {
      if (kDebugMode) debugPrint('fetchUnreadCount error: $e');
    }
  }

  void markAllAsRead() {
    if (!hasUnread) return;

    final previousItems = List<NotificationModel>.from(notificationsList.items);
    final previousCount = _unreadCount.value;

    notificationsList.items.value = previousItems
        .map((item) => item.copyWith(isRead: true, isReadable: true))
        .toList();
    _unreadCount.value = 0;

    unawaited(_service.restoreNotifications(notificationsList.items));

    unawaited(
      _service.syncMarkAllAsRead().catchError((Object e) {
        notificationsList.items.value = previousItems;
        _unreadCount.value = previousCount;
        unawaited(_service.restoreNotifications(previousItems));
        ToastMessageHelper.show(e.errorMessage);
        if (kDebugMode) debugPrint('markAllAsRead error: $e');
      }),
    );
  }

  @override
  Future<void> refresh() async {
    _listLoadStarted = true;
    await Future.wait([
      notificationsList.refreshWith(() => _loadData(showFullLoader: false)),
      fetchUnreadCount(),
    ]);
  }

  @override
  void onClose() {
    notificationsList.dispose();
    super.onClose();
  }
}
