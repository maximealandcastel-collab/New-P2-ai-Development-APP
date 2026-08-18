import 'package:pler_to_pler_app/core/utils/helpers/hive_cache_helper.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/data/data_sources/schedule_local_data_source.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/data/models/session_model.dart';

/// Implementation of ScheduleLocalDataSource using HiveCacheHelper
class ScheduleLocalDataSourceImpl implements ScheduleLocalDataSource {
  static const String _sessionsKey = 'schedule_sessions';
  static const String _lastSyncKey = 'schedule_last_sync';
  static const String _boxName = 'schedule_cache';

  @override
  Future<void> cacheSessions(List<SessionModel> sessions) async {
    await HiveCacheHelper.save(
      key: _sessionsKey,
      value: sessions.map((s) => s.toJson()).toList(),
      boxName: _boxName,
    );
  }

  @override
  Future<List<SessionModel>?> getCachedSessions(DateTime date) async {
    final cached = await HiveCacheHelper.get<List>(
      key: _sessionsKey,
      boxName: _boxName,
    );

    if (cached == null) return null;

    try {
      return cached
          .map((json) => SessionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearCachedSessions() async {
    await HiveCacheHelper.delete(
      key: _sessionsKey,
      boxName: _boxName,
    );
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    final timestamp = await HiveCacheHelper.get<String>(
      key: _lastSyncKey,
      boxName: _boxName,
    );
    if (timestamp == null) return null;
    return DateTime.tryParse(timestamp);
  }

  @override
  Future<void> updateLastSyncTime(DateTime time) async {
    await HiveCacheHelper.save(
      key: _lastSyncKey,
      value: time.toIso8601String(),
      boxName: _boxName,
    );
  }
}
