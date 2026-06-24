import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pler_to_pler_app/features/user/connect_device/data/models/device_model.dart';

class BluetoothService {
  BluetoothService._();

  static final BluetoothService instance = BluetoothService._();

  StreamSubscription<List<ScanResult>>? _scanSubscription;

  Stream<List<BluetoothScanResultModel>> get scanResults =>
      FlutterBluePlus.scanResults.map(_mapScanResults);

  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;

    if (Platform.isAndroid) {
      final permissions = <Permission>[
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ];

      final statuses = await permissions.request();
      return statuses.values.every((status) => status.isGranted);
    }

    if (Platform.isIOS) {
      final status = await Permission.bluetooth.request();
      return status.isGranted;
    }

    return true;
  }

  Future<void> startScan({Duration timeout = const Duration(seconds: 15)}) async {
    final granted = await requestPermissions();
    if (!granted) {
      throw Exception('Bluetooth permissions not granted');
    }

    if (await FlutterBluePlus.isSupported == false) {
      throw Exception('Bluetooth is not supported on this device');
    }

    await FlutterBluePlus.adapterState
        .where((state) => state == BluetoothAdapterState.on)
        .first
        .timeout(const Duration(seconds: 8));

    await FlutterBluePlus.startScan(timeout: timeout);
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  Future<void> connect(String deviceId) async {
    final device = BluetoothDevice.fromId(deviceId);
    await device.connect(
      license: License.nonprofit,
      timeout: const Duration(seconds: 15),
    );
  }

  Future<void> disconnect(String deviceId) async {
    final device = BluetoothDevice.fromId(deviceId);
    await device.disconnect();
  }

  Future<Map<String, String>> getDeviceInfo(String deviceId) async {
    final device = BluetoothDevice.fromId(deviceId);
    final name = device.platformName.isNotEmpty
        ? device.platformName
        : 'Fitness Device';

    return {
      'name': name,
      'macAddress': device.remoteId.str,
      'serialNumber': device.remoteId.str,
      'deviceType': 'watch',
    };
  }

  List<BluetoothScanResultModel> _mapScanResults(List<ScanResult> results) {
    final unique = <String, BluetoothScanResultModel>{};

    for (final result in results) {
      final id = result.device.remoteId.str;
      unique[id] = BluetoothScanResultModel(
        id: id,
        name: result.device.platformName.isNotEmpty
            ? result.device.platformName
            : 'Unknown Device',
        macAddress: id,
      );
    }

    return unique.values.toList();
  }

  Future<void> dispose() async {
    await stopScan();
  }
}
