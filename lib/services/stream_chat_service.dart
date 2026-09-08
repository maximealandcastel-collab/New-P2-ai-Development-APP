import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pler_to_pler_app/services/api_urls.dart';

/// Stub — Stream Chat integration pending (messaging task).
/// Keeps the same public interface so callers compile.
class StreamChatService {
  StreamChatService._();
  static final StreamChatService instance = StreamChatService._();

  bool get isConnected => false;

  static const _baseUrl = ApiUrls.baseUrl;

  static Future<String> _getJwt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ??
        prefs.getString('authToken') ??
        prefs.getString('accessToken') ??
        prefs.getString('jwt') ??
        '';
  }

  Future<void> initFromBackend() async {
    debugPrint('[StreamChat] stub — messaging not yet integrated');
  }

  Future<String?> ensureChannel({required String subscriberId}) async {
    try {
      final jwt = await _getJwt();
      final response = await http.post(
        Uri.parse('$_baseUrl/stream/channel'),
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
        body: json.encode({'subscriberId': subscriberId}),
      );
      if (response.statusCode != 200) return null;
      final data = (json.decode(response.body) as Map)['data'] as Map;
      return data['channelId'] as String?;
    } catch (e) {
      debugPrint('[StreamChat] ensureChannel error: $e');
      return null;
    }
  }

  Future<void> sharePlan({
    required String subscriberId,
    required String planType,
    required String planTitle,
    required String planContent,
  }) async {
    try {
      final jwt = await _getJwt();
      await http.post(
        Uri.parse('$_baseUrl/stream/share-plan'),
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'subscriberId': subscriberId,
          'planType': planType,
          'planTitle': planTitle,
          'planContent': planContent,
        }),
      );
    } catch (e) {
      debugPrint('[StreamChat] sharePlan error: $e');
    }
  }

  Future<void> disconnect() async {
    debugPrint('[StreamChat] disconnect stub');
  }
}
