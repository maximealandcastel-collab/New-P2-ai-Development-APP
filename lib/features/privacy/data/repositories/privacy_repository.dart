
import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/services/api_service.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';

class PrivacyRepository {
  final ApiService _apiService;
  final CacheService _cacheService;

  PrivacyRepository({
    required ApiService apiService,
    required CacheService cacheService,
  })  : _apiService = apiService,
        _cacheService = cacheService;

  // ─── Key mapping ───────────────────────────────────────────────────────────
  String _endpoint(String key) {
    switch (key) {
      case 'privacy':
        return ApiConstants.privacyPolicy;
      case 'about':
        return ApiConstants.aboutUs;
      case 'terms':
        return ApiConstants.termsAndCondition;
      default:
        return '';
    }
  }

  String _cacheKey(String key) => 'cache_${_endpoint(key)}';

  // ─── Fetch ─────────────────────────────────────────────────────────────────
  Future<String> fetchOne(String key) async {
    try {
      final response = await _apiService.get(_endpoint(key));
      final data = response.data?['data']?['description'] as String? ?? '';
      await _cacheService.put(_cacheKey(key), data);
      return data;
    } on AppException {
      return getCached(key) ?? '';
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  // ─── Cache read ────────────────────────────────────────────────────────────
  String? getCached(String key) {
    return _cacheService.get<String>(_cacheKey(key));
  }

  // ─── Cache check ───────────────────────────────────────────────────────────
  bool hasCache() {
    return _cacheService.containsKey(_cacheKey('privacy')) ||
        _cacheService.containsKey(_cacheKey('about')) ||
        _cacheService.containsKey(_cacheKey('terms'));
  }
}