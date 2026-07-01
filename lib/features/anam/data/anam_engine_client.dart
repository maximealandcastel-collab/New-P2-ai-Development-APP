import 'package:dio/dio.dart';

/// Creates Anam engine sessions using a backend-issued session token.
class AnamEngineClient {
  AnamEngineClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 20),
              ),
            );

  final Dio _dio;

  Future<Map<String, dynamic>> startEngineSession({
    required String sessionToken,
    required String personaId,
    bool disableBrains = true,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'https://api.anam.ai/v1/engine/session',
      data: {
        'personaConfig': {
          'personaId': personaId,
          'disableBrains': disableBrains,
        },
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $sessionToken',
        },
      ),
    );

    final data = response.data;
    if (data == null ||
        !data.containsKey('sessionId') ||
        !data.containsKey('engineHost') ||
        !data.containsKey('signallingEndpoint')) {
      throw Exception('Invalid Anam engine session response');
    }

    return {
      ...data,
      'sessionToken': sessionToken,
    };
  }
}
