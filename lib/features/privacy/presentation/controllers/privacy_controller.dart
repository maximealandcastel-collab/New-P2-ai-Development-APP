import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/services/connectivity_service.dart';
import 'package:pler_to_pler_app/features/privacy/domain/services/privacy_services.dart';

class PrivacyController extends GetxController {
  final PrivacyServices _service;
  final ConnectivityService _connectivityService;

  static PrivacyController get to => Get.find();

  PrivacyController({
    required PrivacyServices service,
    required ConnectivityService connectivityService,
  })  : _service = service,
        _connectivityService = connectivityService;

  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;

  LoadingState get loadingState => _loadingState.value;

  final RxMap<String, String> _descriptions = <String, String>{}.obs;
  final RxString _activeKey = 'privacy'.obs;

  String get description => _descriptions[_activeKey.value] ?? '';

  void setActiveKey(String key) => _activeKey.value = key;

  @override
  void onInit() {
    super.onInit();
    ever(_connectivityService.isConnected, (isConnected) {
      if (isConnected) _loadData();
    });
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final hasCache = _service.hasCache();
      final isOnline = _connectivityService.isConnected.value;

      if (hasCache) {
        _loadFromCache();
        _loadingState.value = LoadingState.loaded;
      } else {
        _loadingState.value = LoadingState.loading;
      }

      if (!isOnline) return;

      try {
        await _service.fetchPrivacy();
        _loadFromCache();
        _loadingState.value = LoadingState.loaded;
      } on AppException catch (e) {
        if (!hasCache) _loadingState.value = LoadingState.error;
        if (kDebugMode) debugPrint('Fetch error: $e');
      }
    } catch (e) {
      if (_service.hasCache()) {
        _loadFromCache();
        _loadingState.value = LoadingState.loaded;
      } else {
        _loadingState.value = LoadingState.error;
      }
      if (kDebugMode) debugPrint('Unexpected error: $e');
    }
  }

  void _loadFromCache() {
    for (final key in ['privacy', 'about', 'terms']) {
      final cached = _service.getCached(key);
      if (cached != null) _descriptions[key] = cached;
    }
  }

  @override
  Future<void> refresh() async => _loadData();
}
