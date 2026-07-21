import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/features/notification/data/models/notification_model.dart';
import 'package:pler_to_pler_app/features/notification/data/repositories/notification_repository.dart';

class NotificationService {
  NotificationService({required NotificationRepository repository})
    : _repository = repository;

  final NotificationRepository _repository;

  Future<void> fetchNotifications(int page, int limit) async {
    try {
      await _repository.getNotifications(page, limit);
    } on AppException {
      if (!_repository.hasCache()) rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<List<NotificationModel>> fetchMoreNotifications(
    int page,
    int limit,
  ) {
    return _repository.fetchMoreNotifications(page, limit);
  }

  List<NotificationModel> getCachedNotifications() =>
      _repository.getCachedNotifications();

  bool hasCache() => _repository.hasCache();

  Future<int> getUnreadCount() => _repository.getUnreadCount();

  Future<void> markAllAsRead() => _repository.markAllAsRead();
}
