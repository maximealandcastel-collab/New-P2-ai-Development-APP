import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/services/connectivity_service.dart';
import 'package:pler_to_pler_app/features/user/connect_device/data/models/device_model.dart';
import 'package:pler_to_pler_app/features/user/connect_device/domain/constants/supported_watch_type.dart';
import 'package:pler_to_pler_app/features/user/connect_device/domain/services/apple_watch_service.dart';
import 'package:pler_to_pler_app/features/user/connect_device/domain/services/bluetooth_service.dart';
import 'package:pler_to_pler_app/features/user/connect_device/domain/services/device_service.dart';

enum PairingStep {
  idle,
  selectingWatch,
  scanning,
  connecting,
  saving,
}

class DevicePairingController extends GetxController {
  DevicePairingController({
    required DeviceService deviceService,
    required BluetoothService bluetoothService,
    required AppleWatchService appleWatchService,
    required ConnectivityService connectivityService,
  })  : _deviceService = deviceService,
        _bluetoothService = bluetoothService,
        _appleWatchService = appleWatchService,
        _connectivityService = connectivityService;

  final DeviceService _deviceService;
  final BluetoothService _bluetoothService;
  final AppleWatchService _appleWatchService;
  final ConnectivityService _connectivityService;

  static DevicePairingController get to => Get.find();

  final RxList<DeviceModel> pairedDevices = <DeviceModel>[].obs;
  final RxList<BluetoothScanResultModel> discoveredDevices =
      <BluetoothScanResultModel>[].obs;

  final RxBool isPairing = false.obs;
  final Rx<PairingStep> pairingStep = PairingStep.idle.obs;
  final RxDouble pairingProgress = 0.0.obs;
  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;
  final RxString pairingError = ''.obs;
  final RxnString connectingDeviceId = RxnString();
  final Rxn<SupportedWatchType> selectedWatchType = Rxn<SupportedWatchType>();

  StreamSubscription<List<BluetoothScanResultModel>>? _scanSubscription;

  LoadingState get loadingState => _loadingState.value;
  bool get isEmpty => pairedDevices.isEmpty;

  @override
  void onInit() {
    super.onInit();
    ever(_connectivityService.isConnected, (isConnected) {
      if (isConnected) fetchPairedDevices();
    });
    fetchPairedDevices();
  }

  @override
  void onClose() {
    _scanSubscription?.cancel();
    super.onClose();
  }

  Future<void> fetchPairedDevices() async {
    try {
      final hasCache = _deviceService.hasCache();
      final isOnline = _connectivityService.isConnected.value;

      if (hasCache) {
        pairedDevices.assignAll(_deviceService.getCachedDevices());
        _loadingState.value = LoadingState.loaded;
      } else {
        _loadingState.value = LoadingState.loading;
      }

      if (!isOnline) {
        if (!hasCache) _loadingState.value = LoadingState.offline;
        return;
      }

      final devices = await _deviceService.fetchUserDevices();
      pairedDevices.assignAll(devices);
      _loadingState.value = LoadingState.loaded;
    } on AppException catch (e) {
      if (_deviceService.hasCache()) {
        pairedDevices.assignAll(_deviceService.getCachedDevices());
        _loadingState.value = LoadingState.loaded;
      } else {
        _loadingState.value = LoadingState.error;
      }
      if (kDebugMode) debugPrint('fetchPairedDevices error: $e');
    } catch (e) {
      if (_deviceService.hasCache()) {
        pairedDevices.assignAll(_deviceService.getCachedDevices());
        _loadingState.value = LoadingState.loaded;
      } else {
        _loadingState.value = LoadingState.error;
      }
      if (kDebugMode) debugPrint('fetchPairedDevices error: $e');
    }
  }

  void preparePairingUi() {
    pairingError.value = '';
    isPairing.value = true;
    pairingStep.value = PairingStep.selectingWatch;
    pairingProgress.value = 0.0;
    selectedWatchType.value = null;
    discoveredDevices.clear();
  }

  Future<void> selectWatchType(SupportedWatchType watchType) async {
    selectedWatchType.value = watchType;
    pairingError.value = '';

    if (watchType.usesHealthKit) {
      await pairAppleWatch();
      return;
    }

    pairingStep.value = PairingStep.scanning;
    pairingProgress.value = 0.1;
    discoveredDevices.clear();
    try {
      await startScanning();
    } catch (_) {}
  }

  Future<void> pairAppleWatch() async {
    try {
      pairingStep.value = PairingStep.connecting;
      pairingProgress.value = 0.3;

      if (!_appleWatchService.isAvailable) {
        throw Exception('Apple Watch sync is only available on iPhone');
      }

      final authorized = await _appleWatchService.requestAuthorization();
      if (!authorized) {
        throw Exception(
          'Health permission is required to sync Apple Watch data',
        );
      }

      pairingProgress.value = 0.5;
      await _prepareExclusivePairing();

      pairingStep.value = PairingStep.saving;
      pairingProgress.value = 0.7;

      final watchType = SupportedWatchType.appleWatchS3;
      final pairedDevice = await _deviceService.pairDevice(
        name: watchType.displayName,
        serialNumber: _appleWatchService.getDeviceSerial(),
        deviceType: watchType.apiValue,
      );

      pairingProgress.value = 0.9;
      try {
        final metrics = await _appleWatchService.fetchTodayMetrics();
        await _deviceService.postDeviceMetrics(
          pairedDevice.id,
          metrics.toJson(),
        );
      } catch (e) {
        if (kDebugMode) debugPrint('Initial Apple Watch metrics sync: $e');
      }

      pairingProgress.value = 1.0;
      await fetchPairedDevices();
      await _finishPairing();
    } catch (e) {
      if (kDebugMode) debugPrint('Pair Apple Watch error: $e');
      pairingError.value = e.errorMessage;
      ToastMessageHelper.show(e.errorMessage);
      pairingStep.value = PairingStep.selectingWatch;
      pairingProgress.value = 0.0;
      selectedWatchType.value = null;
    }
  }

  Future<void> startScanning() async {
    final watchType = selectedWatchType.value;
    if (watchType == null || watchType.usesHealthKit) return;

    try {
      await _scanSubscription?.cancel();
      _scanSubscription = _bluetoothService.scanResults.listen((results) {
        final filtered = results
            .where((device) => watchType.matchesBleName(device.name))
            .toList();
        discoveredDevices.assignAll(filtered);
      });

      await _bluetoothService.startScan();
      pairingProgress.value = 0.25;
    } catch (e) {
      if (kDebugMode) debugPrint('Start scanning error: $e');
      pairingError.value = e.errorMessage;
      ToastMessageHelper.show(e.errorMessage);
      pairingStep.value = PairingStep.scanning;
      isPairing.value = true;
      pairingProgress.value = 0.1;
    }
  }

  Future<void> retryScanning() async {
    final watchType = selectedWatchType.value;
    if (watchType == null) {
      pairingStep.value = PairingStep.selectingWatch;
      return;
    }

    if (watchType.usesHealthKit) {
      await pairAppleWatch();
      return;
    }

    pairingError.value = '';
    pairingStep.value = PairingStep.scanning;
    isPairing.value = true;
    pairingProgress.value = 0.1;
    discoveredDevices.clear();
    try {
      await startScanning();
    } catch (_) {}
  }

  Future<void> selectAndConnectDevice(BluetoothScanResultModel device) async {
    final watchType = selectedWatchType.value;
    if (watchType == null) return;

    try {
      pairingError.value = '';
      pairingStep.value = PairingStep.connecting;
      pairingProgress.value = 0.45;
      await _bluetoothService.stopScan();

      await _prepareExclusivePairing();
      await _bluetoothService.connect(device.id);
      pairingProgress.value = 0.65;

      pairingStep.value = PairingStep.saving;
      final info = await _bluetoothService.getDeviceInfo(device.id);

      await _deviceService.pairDevice(
        name: info['name'] ?? device.name,
        serialNumber: info['serialNumber'] ?? device.id,
        macAddress: info['macAddress'] ?? device.macAddress,
        deviceType: watchType.apiValue,
      );

      pairingProgress.value = 1.0;
      await fetchPairedDevices();
      await _finishPairing();
    } catch (e) {
      if (kDebugMode) debugPrint('Connect/pair device error: $e');
      pairingError.value = e.errorMessage;
      ToastMessageHelper.show(e.errorMessage);
      pairingStep.value = PairingStep.scanning;
      pairingProgress.value = 0.25;
      try {
        await _bluetoothService.startScan();
      } catch (scanError) {
        if (kDebugMode) debugPrint('Resume scan error: $scanError');
      }
    }
  }

  Future<void> switchToDevice(DeviceModel device) async {
    if (device.isConnected) return;

    connectingDeviceId.value = device.id;
    try {
      await _prepareExclusivePairing();

      if (SupportedWatchType.isAppleWatchType(device.deviceType)) {
        if (!_appleWatchService.isAvailable) {
          throw Exception('Apple Watch sync is only available on iPhone');
        }

        final authorized = await _appleWatchService.requestAuthorization();
        if (!authorized) {
          throw Exception('Health permission is required');
        }

        final updated = await _deviceService.updateDeviceStatus(
          deviceId: device.id,
          isConnected: true,
        );
        _markOnlyDeviceConnected(device.id, serverDevice: updated);
        await _syncDeviceCache();
        ToastMessageHelper.show('Connected to ${device.name}');
        return;
      }

      final address = device.macAddress?.trim();
      if (address == null || address.isEmpty) {
        throw Exception('Device address not found');
      }

      await _bluetoothService.connect(address);

      final updated = await _deviceService.updateDeviceStatus(
        deviceId: device.id,
        isConnected: true,
      );
      _markOnlyDeviceConnected(device.id, serverDevice: updated);
      await _syncDeviceCache();
      ToastMessageHelper.show('Connected to ${device.name}');
    } catch (e) {
      if (kDebugMode) debugPrint('Switch device error: $e');
      ToastMessageHelper.show(e.errorMessage);
    } finally {
      connectingDeviceId.value = null;
    }
  }

  Future<void> cancelPairing() async {
    if (pairingStep.value == PairingStep.scanning) {
      await _bluetoothService.stopScan();
      pairingStep.value = PairingStep.selectingWatch;
      selectedWatchType.value = null;
      discoveredDevices.clear();
      pairingError.value = '';
      pairingProgress.value = 0.0;
      return;
    }

    await _resetPairingState(stopScan: true);
    _popPairingScreen();
  }

  Future<void> unpairDevice(DeviceModel device) async {
    try {
      if (device.isConnected &&
          !SupportedWatchType.isAppleWatchType(device.deviceType) &&
          device.macAddress != null &&
          device.macAddress!.isNotEmpty) {
        await _bluetoothService.disconnect(device.macAddress!);
      }
      await _deviceService.unpairDevice(device.id);
      pairedDevices.removeWhere((item) => item.id == device.id);
      await _syncDeviceCache();
    } catch (e) {
      if (kDebugMode) debugPrint('Unpair device error: $e');
      ToastMessageHelper.show(e.errorMessage);
    }
  }

  Future<void> syncDeviceMetrics(DeviceModel device) async {
    try {
      if (SupportedWatchType.isAppleWatchType(device.deviceType)) {
        final metrics = await _appleWatchService.fetchTodayMetrics();
        await _deviceService.postDeviceMetrics(device.id, metrics.toJson());
      } else {
        await _deviceService.syncDeviceMetrics(device.id);
      }
      ToastMessageHelper.show('Device metrics synced');
    } catch (e) {
      ToastMessageHelper.show(e.errorMessage);
    }
  }

  Future<void> _prepareExclusivePairing() async {
    await _releaseActiveConnection();
  }

  Future<void> _releaseActiveConnection() async {
    await _bluetoothService.disconnectAll();

    for (final device in pairedDevices.where((d) => d.isConnected)) {
      try {
        final updated = await _deviceService.updateDeviceStatus(
          deviceId: device.id,
          isConnected: false,
        );
        _upsertDevice(updated);
      } catch (e) {
        if (kDebugMode) debugPrint('Mark device disconnected: $e');
        _upsertDevice(device.copyWith(isConnected: false));
      }
    }
  }

  void _markOnlyDeviceConnected(String activeId, {DeviceModel? serverDevice}) {
    for (var i = 0; i < pairedDevices.length; i++) {
      final item = pairedDevices[i];
      final shouldConnect = item.id == activeId;
      if (item.isConnected != shouldConnect) {
        pairedDevices[i] = item.copyWith(isConnected: shouldConnect);
      }
    }

    if (serverDevice != null) {
      _upsertDevice(serverDevice.copyWith(isConnected: true));
    } else {
      final index = pairedDevices.indexWhere((item) => item.id == activeId);
      if (index >= 0) {
        pairedDevices[index] =
            pairedDevices[index].copyWith(isConnected: true);
      }
    }
  }

  Future<void> _finishPairing() async {
    await _resetPairingState(stopScan: false);
    _popPairingScreen();
  }

  Future<void> _resetPairingState({required bool stopScan}) async {
    if (stopScan) {
      await _bluetoothService.stopScan();
    }

    isPairing.value = false;
    pairingStep.value = PairingStep.idle;
    pairingProgress.value = 0.0;
    selectedWatchType.value = null;
    discoveredDevices.clear();
    pairingError.value = '';
  }

  Future<void> _syncDeviceCache() async {
    await _deviceService.saveCachedDevices(pairedDevices.toList());
  }

  void _popPairingScreen() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    }
  }

  void _upsertDevice(DeviceModel device) {
    final index = pairedDevices.indexWhere((item) => item.id == device.id);
    if (index >= 0) {
      pairedDevices[index] = device;
    } else {
      pairedDevices.add(device);
    }
  }
}
