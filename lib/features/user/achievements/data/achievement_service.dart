import 'package:pler_to_pler_app/features/user/achievements/data/achievement_unlock.dart';
import 'package:pler_to_pler_app/services/api_urls.dart';
import 'package:pler_to_pler_app/services/network/api_client.dart';

class AchievementService {
  const AchievementService._();

  static List<AchievementUnlock> parseUnlocks(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => AchievementUnlock.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .where((unlock) => unlock.achievementId.isNotEmpty)
        .toList();
  }

  static Future<List<AchievementUnlock>> getPending() async {
    final response = await ApiClient.getData(ApiUrls.pendingAchievements);
    if (response.statusCode != 200 || response.body is! Map) return const [];
    return parseUnlocks((response.body as Map)['data']);
  }

  static Future<void> markPresented(String achievementId) async {
    await ApiClient.patch(
      ApiUrls.achievementPresented(achievementId),
      const <String, dynamic>{},
    );
  }

  static Future<void> markShared(String achievementId) async {
    await ApiClient.patch(
      ApiUrls.achievementShared(achievementId),
      const <String, dynamic>{},
    );
  }
}