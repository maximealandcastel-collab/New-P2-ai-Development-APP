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

  Future<void> openPairingFlow() async {
    await startPairing();
  }

  Future<void> startPairing() async {
    try {
      isPairing.value = true;
      pairingStep.value = PairingStep.scanning;
      pairingProgress.value = 0.1;
      discoveredDevices.clear();

      await _scanSubscription?.cancel();
      _scanSubscription = _bluetoothService.scanResults.listen((results) {
        discoveredDevices.assignAll(results);
      });

      await _bluetoothService.startScan();
      pairingProgress.value = 0.25;
    } catch (e) {
      await cancelPairing(showError: false);
      ToastMessageHelper.show(e.errorMessage);
    }
  }

  Future<void> selectAndConnectDevice(BluetoothScanResultModel device) async {
    try {
      pairingStep.value = PairingStep.connecting;
      pairingProgress.value = 0.45;
      await _bluetoothService.stopScan();

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
      _upsertDevice(pairedDevice.copyWith(isConnected: true));
      ToastMessageHelper.show('Device paired successfully');
      await _finishPairing(closeDialog: true);
    } catch (e) {
      ToastMessageHelper.show(e.errorMessage);
      await cancelPairing(showError: false);
    }
  }

  Future<void> cancelPairing({bool showError = true}) async {
    await _bluetoothService.stopScan();
    isPairing.value = false;
    pairingStep.value = PairingStep.idle;
    pairingProgress.value = 0.0;
    discoveredDevices.clear();

    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    if (showError) {
      ToastMessageHelper.show('Pairing cancelled');
    }
  }

  Future<void> unpairDevice(DeviceModel device) async {
    try {
      await _deviceService.unpairDevice(device.id);
      if (device.macAddress != null && device.macAddress!.isNotEmpty) {
        await _bluetoothService.disconnect(device.macAddress!);
      }
      pairedDevices.removeWhere((item) => item.id == device.id);
      ToastMessageHelper.show('Device removed');
    } catch (e) {
      ToastMessageHelper.show(e.errorMessage);
    }
  }

  Future<void> setPrimaryDevice(DeviceModel device) async {
    try {
      final updated = await _deviceService.setPrimaryDevice(
        device.id,
        pairedDevices.toList(),
      );
      pairedDevices.assignAll(updated);
      ToastMessageHelper.show('Primary device updated');
    } catch (e) {
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

  Future<void> _finishPairing({required bool closeDialog}) async {
    isPairing.value = false;
    pairingStep.value = PairingStep.idle;
    pairingProgress.value = 0.0;
    discoveredDevices.clear();

    if (closeDialog && (Get.isDialogOpen ?? false)) {
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
