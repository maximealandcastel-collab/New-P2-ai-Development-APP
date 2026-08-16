import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

/// Singleton that owns the [StreamChatClient].
///
/// Call [initFromBackend] once after the user logs in.
/// Call [disconnect] when the user logs out.
class StreamChatService {
  StreamChatService._();
  static final StreamChatService instance = StreamChatService._();

  StreamChatClient? _client;

  /// Returns the connected client.  Throws if [initFromBackend] was not called.
  StreamChatClient get client {
    assert(_client != null, 'Call StreamChatService.instance.initFromBackend() after login');
    return _client!;
  }

  bool get isConnected =>
      _client != null && _client!.state.currentUser != null;

  static const _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://fit-tech-ai.replit.app/api/v1',
  );

  // ── Retrieve stored JWT from SharedPreferences ─────────────────────────
  static Future<String> _getJwt() async {
    final prefs = await SharedPreferences.getInstance();
    // Try the most common token keys used across the codebase
    return prefs.getString('token') ??
        prefs.getString('authToken') ??
        prefs.getString('accessToken') ??
        prefs.getString('jwt') ??
        '';
  }

  // ── Connect this device to Stream after login ──────────────────────────
  Future<void> initFromBackend() async {
    try {
      final jwt = await _getJwt();
      if (jwt.isEmpty) {
        debugPrint('[StreamChat] No JWT found — skipping init');
        return;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/stream/token'),
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        debugPrint('[StreamChat] Token fetch failed: ${response.statusCode}');
        return;
      }

      final data = (json.decode(response.body) as Map)["data"] as Map;
      final apiKey      = data["apiKey"]  as String;
      final userId      = data["userId"]  as String;
      final streamToken = data["token"]   as String;
      final name        = (data["name"]   as String?) ?? 'User';
      final image       = data["image"]   as String?;

      // Dispose previous client if any (e.g. re-login)
      await _client?.disconnectUser();
      _client = StreamChatClient(apiKey, logLevel: Level.WARNING);

      await _client!.connectUser(
        User(id: userId, name: name, image: image),
        streamToken,
      );
      debugPrint('[StreamChat] Connected as $name ($userId)');
    } catch (e, st) {
      debugPrint('[StreamChat] initFromBackend error: $e\n$st');
    }
  }

  // ── Ask the backend to create/get the channel, return its ID ──────────
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
      final data = (json.decode(response.body) as Map)["data"] as Map;
      return data["channelId"] as String?;
    } catch (e) {
      debugPrint('[StreamChat] ensureChannel error: $e');
      return null;
    }
  }

  // ── Share a workout / meal plan into the trainer↔subscriber channel ───
  Future<void> sharePlan({
    required String subscriberId,
    required String planType, // "workout" | "meal"
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
          'planType':     planType,
          'planTitle':    planTitle,
          'planContent':  planContent,
        }),
      );
    } catch (e) {
      debugPrint('[StreamChat] sharePlan error: $e');
    }
  }

  // ── Return a watched Channel object ready for StreamBuilder ───────────
  Channel? getChannel(String channelId, {String type = 'messaging'}) {
    if (!isConnected) return null;
    return _client!.channel(type, id: channelId);
  }

  // ── Clean up on logout ────────────────────────────────────────────────
  Future<void> disconnect() async {
    try {
      await _client?.disconnectUser();
      _client = null;
      debugPrint('[StreamChat] Disconnected');
    } catch (_) {}
  }
}