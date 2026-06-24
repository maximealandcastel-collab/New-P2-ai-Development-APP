import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/features/user/connect_device/data/models/device_model.dart';
import 'package:pler_to_pler_app/features/user/connect_device/domain/services/bluetooth_service.dart';
import 'package:pler_to_pler_app/features/user/connect_device/domain/services/device_service.dart';

enum PairingStep { idle, scanning, connecting, saving }

class DevicePairingController extends GetxController {
  DevicePairingController({
    required DeviceService deviceService,
    required BluetoothService bluetoothService,
  })  : _deviceService = deviceService,
        _bluetoothService = bluetoothService;

  final DeviceService _deviceService;
  final BluetoothService _bluetoothService;

  static DevicePairingController get to => Get.find();

  final RxList<DeviceModel> pairedDevices = <DeviceModel>[].obs;
  final RxList<BluetoothScanResultModel> discoveredDevices =
      <BluetoothScanResultModel>[].obs;

  final RxBool isPairing = false.obs;
  final Rx<PairingStep> pairingStep = PairingStep.idle.obs;
  final RxDouble pairingProgress = 0.0.obs;
  final RxBool isLoadingDevices = false.obs;
  final RxString pairingError = ''.obs;
  final RxnString connectingDeviceId = RxnString();

  StreamSubscription<List<BluetoothScanResultModel>>? _scanSubscription;

  bool get isEmpty => pairedDevices.isEmpty;

  @override
  void onInit() {
    super.onInit();
    loadPairedDevices();
  }

  @override
  void onClose() {
    _scanSubscription?.cancel();
    super.onClose();
  }

  Future<void> loadPairedDevices() async {
    isLoadingDevices.value = true;
    try {
      pairedDevices.assignAll(await _deviceService.getUserDevices());
    } catch (e) {
      if (kDebugMode) debugPrint('Load devices error: $e');
    } finally {
      isLoadingDevices.value = false;
    }
  }

  void preparePairingUi() {
    pairingError.value = '';
    isPairing.value = true;
    pairingStep.value = PairingStep.scanning;
    pairingProgress.value = 0.1;
    discoveredDevices.clear();
  }

  Future<void> startScanning() async {
    try {
      await _scanSubscription?.cancel();
      _scanSubscription = _bluetoothService.scanResults.listen((results) {
        discoveredDevices.assignAll(results);
      });

      await _bluetoothService.startScan();
      pairingProgress.value = 0.25;
    } catch (e) {
      if (kDebugMode) debugPrint('Start scanning error: $e');
      pairingError.value = e.errorMessage;
      ToastMessageHelper.show(e.errorMessage);
      await _resetPairingState(stopScan: true);
      _popPairingScreen();
      rethrow;
    }
  }

  Future<void> selectAndConnectDevice(BluetoothScanResultModel device) async {
    try {
      pairingError.value = '';
      pairingStep.value = PairingStep.connecting;
      pairingProgress.value = 0.45;
      await _bluetoothService.stopScan();

      await _releaseActiveConnection();
      await _bluetoothService.connect(device.id);
      pairingProgress.value = 0.65;

      pairingStep.value = PairingStep.saving;
      final info = await _bluetoothService.getDeviceInfo(device.id);

      final pairedDevice = await _deviceService.pairDevice(
        name: info['name'] ?? device.name,
        serialNumber: info['serialNumber'] ?? device.id,
        macAddress: info['macAddress'] ?? device.macAddress,
        deviceType: info['deviceType'] ?? 'watch',
      );

      pairingProgress.value = 1.0;
      _markOnlyDeviceConnected(
        pairedDevice.id,
        serverDevice: pairedDevice,
      );
      ToastMessageHelper.show('Device paired successfully');
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

    final address = device.macAddress?.trim();
    if (address == null || address.isEmpty) {
      ToastMessageHelper.show('Device Bluetooth address not found');
      return;
    }

    connectingDeviceId.value = device.id;
    try {
      await _releaseActiveConnection();
      await _bluetoothService.connect(address);

      final updated = await _deviceService.updateDeviceStatus(
        deviceId: device.id,
        isConnected: true,
      );
      _markOnlyDeviceConnected(device.id, serverDevice: updated);
      ToastMessageHelper.show('Connected to ${device.name}');
    } catch (e) {
      if (kDebugMode) debugPrint('Switch device error: $e');
      ToastMessageHelper.show(e.errorMessage);
    } finally {
      connectingDeviceId.value = null;
    }
  }

  Future<void> cancelPairing({bool showError = true}) async {
    await _resetPairingState(stopScan: true);
    _popPairingScreen();

    if (showError) {
      ToastMessageHelper.show('Pairing cancelled');
    }
  }

  Future<void> unpairDevice(DeviceModel device) async {
    try {
      if (device.isConnected &&
          device.macAddress != null &&
          device.macAddress!.isNotEmpty) {
        await _bluetoothService.disconnect(device.macAddress!);
      }
      await _deviceService.unpairDevice(device.id);
      pairedDevices.removeWhere((item) => item.id == device.id);
      ToastMessageHelper.show('Device removed');
    } catch (e) {
      if (kDebugMode) debugPrint('Unpair device error: $e');
      ToastMessageHelper.show(e.errorMessage);
    }
  }

  Future<void> syncDeviceMetrics(DeviceModel device) async {
    try {
      await _deviceService.syncDeviceMetrics(device.id);
      ToastMessageHelper.show('Device metrics synced');
    } catch (e) {
      ToastMessageHelper.show(e.errorMessage);
    }
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
        pairedDevices[index] = pairedDevices[index].copyWith(isConnected: true);
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
    discoveredDevices.clear();
    pairingError.value = '';
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
