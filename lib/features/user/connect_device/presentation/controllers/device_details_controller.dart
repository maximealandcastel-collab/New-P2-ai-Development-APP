import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/services/connectivity_service.dart';
import 'package:pler_to_pler_app/features/user/connect_device/data/models/device_metrics_model.dart';
import 'package:pler_to_pler_app/features/user/connect_device/data/models/device_model.dart';
import 'package:pler_to_pler_app/features/user/connect_device/domain/constants/supported_watch_type.dart';
import 'package:pler_to_pler_app/features/user/connect_device/domain/services/apple_watch_service.dart';
import 'package:pler_to_pler_app/features/user/connect_device/domain/services/device_service.dart';
import 'package:pler_to_pler_app/features/user/connect_device/presentation/controllers/device_pairing_controller.dart';

class DeviceDetailsController extends GetxController {
  DeviceDetailsController({
    required String deviceId,
    required DeviceModel initialDevice,
    required DeviceService deviceService,
    required DevicePairingController pairingController,
    required AppleWatchService appleWatchService,
    required ConnectivityService connectivityService,
  })  : _deviceId = deviceId,
        _initialDevice = initialDevice,
        _deviceService = deviceService,
        _pairingController = pairingController,
        _appleWatchService = appleWatchService,
        _connectivityService = connectivityService;

  final String _deviceId;
  final DeviceModel _initialDevice;
  final DeviceService _deviceService;
  final DevicePairingController _pairingController;
  final AppleWatchService _appleWatchService;
  final ConnectivityService _connectivityService;

  final Rx<LoadingState> loadingState = LoadingState.initial.obs;
  final Rx<DeviceMetricsModel?> metrics = Rx<DeviceMetricsModel?>(null);
  final RxBool isSyncing = false.obs;
  final RxBool isConnecting = false.obs;
  final RxBool healthPermissionGranted = false.obs;
  final RxBool isCheckingPermissions = false.obs;

  DeviceModel get device {
    return _pairingController.pairedDevices.firstWhere(
      (item) => item.id == _deviceId,
      orElse: () => _initialDevice,
    );
  }

  bool get isAppleWatch =>
      SupportedWatchType.isAppleWatchType(device.deviceType);

  @override
  void onInit() {
    super.onInit();
    _loadMetrics();
    _checkHealthPermissions();
  }

  Future<void> reloadDetails() async {
    await _loadMetrics();
    await _checkHealthPermissions();
  }

  Future<void> _loadMetrics() async {
    try {
      loadingState.value = LoadingState.loading;

      if (!_connectivityService.isConnected.value) {
        loadingState.value = LoadingState.offline;
        return;
      }

      final response = await _deviceService.syncDeviceMetrics(_deviceId);
      metrics.value = DeviceMetricsModel.fromResponse(response);
      loadingState.value = LoadingState.loaded;
    } on AppException catch (e) {
      loadingState.value = LoadingState.error;
      if (kDebugMode) debugPrint('loadMetrics error: $e');
    } catch (e) {
      loadingState.value = LoadingState.error;
      if (kDebugMode) debugPrint('loadMetrics error: $e');
    }
  }

  Future<void> syncMetrics() async {
    if (isSyncing.value) return;

    isSyncing.value = true;
    try {
      if (isAppleWatch) {
        final granted = await _ensureHealthPermissions();
        if (!granted) {
          ToastMessageHelper.show(
            'Allow Health access to sync Apple Watch data',
          );
          return;
        }
      }

      await _pairingController.syncDeviceMetrics(device);
      await _loadMetrics();
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> connectDevice() async {
    if (device.isConnected || isConnecting.value) return;

    isConnecting.value = true;
    try {
      if (isAppleWatch) {
        final granted = await _ensureHealthPermissions();
        if (!granted) {
          ToastMessageHelper.show(
            'Allow Health access to connect Apple Watch',
          );
          return;
        }
      }

      await _pairingController.switchToDevice(device);
    } finally {
      isConnecting.value = false;
    }
  }

  Future<void> requestHealthPermissions() async {
    if (!isAppleWatch) return;

    isCheckingPermissions.value = true;
    try {
      final granted = await _appleWatchService.requestAuthorization();
      healthPermissionGranted.value = granted;
      if (!granted) {
        ToastMessageHelper.show('Health permission was not granted');
      }
    } finally {
      isCheckingPermissions.value = false;
    }
  }

  Future<void> _checkHealthPermissions() async {
    if (!isAppleWatch || !_appleWatchService.isAvailable) {
      healthPermissionGranted.value = false;
      return;
    }

    isCheckingPermissions.value = true;
    try {
      healthPermissionGranted.value = await _appleWatchService.hasPermissions();
    } finally {
      isCheckingPermissions.value = false;
    }
  }

  Future<bool> _ensureHealthPermissions() async {
    if (!isAppleWatch) return true;

    if (await _appleWatchService.hasPermissions()) {
      healthPermissionGranted.value = true;
      return true;
    }

    final granted = await _appleWatchService.requestAuthorization();
    healthPermissionGranted.value = granted;
    return granted;
  }
}
