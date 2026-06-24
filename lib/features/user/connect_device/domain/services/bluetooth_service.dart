import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pler_to_pler_app/features/user/connect_device/data/models/device_model.dart';

class BluetoothService {
  BluetoothService._();

  static final BluetoothService instance = BluetoothService._();

  static const Duration _connectTimeout = Duration(seconds: 30);
  static const Duration _disconnectSettleDelay = Duration(milliseconds: 500);

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
      throw Exception(
        'Bluetooth and location permissions are required to scan for devices',
      );
    }

    if (await FlutterBluePlus.isSupported == false) {
      throw Exception('Bluetooth is not supported on this device');
    }

    await _ensureAdapterOn();

    if (FlutterBluePlus.isScanningNow) {
      await stopScan();
    }

    await FlutterBluePlus.startScan(timeout: timeout);
  }

  Future<void> _ensureAdapterOn() async {
    final currentState = await FlutterBluePlus.adapterState.first;

    if (currentState == BluetoothAdapterState.on) return;

    if (currentState == BluetoothAdapterState.off && Platform.isAndroid) {
      try {
        await FlutterBluePlus.turnOn();
      } catch (e) {
        if (kDebugMode) debugPrint('Bluetooth turnOn failed: $e');
      }
    }

    try {
      await FlutterBluePlus.adapterState
          .where((state) => state == BluetoothAdapterState.on)
          .first
          .timeout(const Duration(seconds: 12));
    } on TimeoutException {
      throw Exception('Please turn on Bluetooth and try again');
    }
  }

  Future<void> stopScan() async {
    try {
      if (FlutterBluePlus.isScanningNow) {
        await FlutterBluePlus.stopScan();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('BluetoothService.stopScan: $e');
    }
  }

  Future<void> disconnectAll() async {
    try {
      final connected = FlutterBluePlus.connectedDevices;
      for (final device in connected) {
        try {
          await device.disconnect();
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Bluetooth disconnect ${device.remoteId.str}: $e');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('BluetoothService.disconnectAll: $e');
    }
  }

  Future<void> connect(String deviceId) async {
    await disconnectAll();
    await Future<void>.delayed(_disconnectSettleDelay);

    final device = BluetoothDevice.fromId(deviceId);

    if (device.isConnected) {
      try {
        await device.disconnect();
        await Future<void>.delayed(_disconnectSettleDelay);
      } catch (e) {
        if (kDebugMode) debugPrint('Pre-connect disconnect failed: $e');
      }
    }

    await device.connect(
      license: License.nonprofit,
      timeout: _connectTimeout,
      autoConnect: false,
    );
  }

  Future<void> disconnect(String deviceId) async {
    final device = BluetoothDevice.fromId(deviceId);
    if (device.isConnected) {
      await device.disconnect();
    }
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
      final name = result.device.platformName.trim();
      unique[id] = BluetoothScanResultModel(
        id: id,
        name: name.isNotEmpty ? name : 'Unknown Device',
        macAddress: id,
      );
    }

    return unique.values.toList();
  }

  Future<void> dispose() async {
    await stopScan();
    await disconnectAll();
  }
}
