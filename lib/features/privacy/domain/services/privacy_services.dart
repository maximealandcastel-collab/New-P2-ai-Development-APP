

import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/features/privacy/data/repositories/privacy_repository.dart';

class PrivacyServices {
  final PrivacyRepository _repository;

  PrivacyServices({required PrivacyRepository repository})
      : _repository = repository;

  // ─── Fetch all three in parallel ───────────────────────────────────────────
  Future<void> fetchPrivacy() async {
    try {
      await Future.wait([
        _repository.fetchOne('privacy'),
        _repository.fetchOne('about'),
        _repository.fetchOne('terms'),
      ]);
    } on AppException {
      if (!_repository.hasCache()) rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  // ─── Cache ─────────────────────────────────────────────────────────────────
  String? getCached(String key) => _repository.getCached(key);

  bool hasCache() => _repository.hasCache();

}