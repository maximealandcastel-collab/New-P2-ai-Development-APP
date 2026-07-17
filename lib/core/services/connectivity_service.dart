import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final RxBool isConnected = false.obs;
  final RxList<ConnectivityResult> connectionTypes =
      <ConnectivityResult>[ConnectivityResult.none].obs;

  /// True when the device is on cellular data without Wi‑Fi/Ethernet.
  bool get isOnMobileData {
    final types = connectionTypes;
    final hasMobile = types.contains(ConnectivityResult.mobile);
    final hasFastLink = types.any(
      (type) =>
          type == ConnectivityResult.wifi ||
          type == ConnectivityResult.ethernet,
    );
    return hasMobile && !hasFastLink;
  }

  /// Prefer preloading the next reel before the previous one on slow links.
  bool get shouldPrioritizeNextVideoPreload => isOnMobileData;

  Future<void> init() async {
    final result = await _connectivity.checkConnectivity();
    _applyConnectivityResults(result);
    _startListening();
  }

  void _startListening() {
    if (_subscription != null) return;

    _subscription = _connectivity.onConnectivityChanged.listen(
          (List<ConnectivityResult> results) {
        _applyConnectivityResults(results);
      },
      onError: (_) {
        isConnected.value = false;
      },
    );
  }

  bool _isConnectedFromResults(List<ConnectivityResult> results) {
    return results.any(
          (result) =>
      result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet,
    );
  }

  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _applyConnectivityResults(results);
      return isConnected.value;
    } catch (_) {
      isConnected.value = false;
      connectionTypes.assignAll([ConnectivityResult.none]);
      return false;
    }
  }

  void _applyConnectivityResults(List<ConnectivityResult> results) {
    isConnected.value = _isConnectedFromResults(results);
    connectionTypes.assignAll(results);
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}