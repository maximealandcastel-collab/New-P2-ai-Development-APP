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

  Future<void> init() async {
    final result = await _connectivity.checkConnectivity();
    isConnected.value = _isConnectedFromResults(result);
    _startListening();
  }

  void _startListening() {
    if (_subscription != null) return;

    _subscription = _connectivity.onConnectivityChanged.listen(
          (List<ConnectivityResult> results) {
        isConnected.value = _isConnectedFromResults(results);
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
      final connected = _isConnectedFromResults(results);
      isConnected.value = connected;
      return connected;
    } catch (_) {
      isConnected.value = false;
      return false;
    }
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}