import 'package:get/get.dart';
    import 'package:shared_preferences/shared_preferences.dart';
    import 'package:pler_to_pler_app/services/api_urls.dart';

    /// Lightweight HTTP helper used by the paywall/promo flow.
    /// All other features use [ApiService] (Dio) directly.
    class ApiClient {
    ApiClient._();

    static const _tokenKey = 'accessToken';

    static Future<String?> _getToken() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    }

    static Future<Response> getData(
      String path, {
      Map<String, String>? headers,
    }) async {
      final token = await _getToken();
      final connect = GetConnect();
      return connect.get(
        ApiUrls.baseUrl + path,
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          ...?headers,
        },
      );
    }

        static Future<Response> postData(
      String url,
      dynamic body, {
      Map<String, String>? headers,
    }) async {
      final token = await _getToken();
      final connect = GetConnect();
      final resolvedUrl = url.startsWith('http://') || url.startsWith('https://')
          ? url
          : '${ApiUrls.baseUrl}${url.startsWith('/') ? url : '/$url'}';
      return connect.post(
        resolvedUrl,
        body,
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          ...?headers,
        },
      );
    }
    }
    
