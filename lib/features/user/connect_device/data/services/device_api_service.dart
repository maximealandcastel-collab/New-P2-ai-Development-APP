import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/services/api_service.dart';
import 'package:pler_to_pler_app/features/user/connect_device/data/models/device_model.dart';

class DeviceApiService {
  DeviceApiService({required ApiService apiService}) : _apiService = apiService;

  final ApiService _apiService;

  Future<List<DeviceModel>> getUserDevices() async {
    try {
      final response = await _apiService.get(ApiConstants.userDevices);
      final data = response.data?['data'];

      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(DeviceModel.fromJson)
            .toList();
      }

      if (data is Map<String, dynamic>) {
        final devices = data['devices'];
        if (devices is List) {
          return devices
              .whereType<Map<String, dynamic>>()
              .map(DeviceModel.fromJson)
              .toList();
        }
      }

      return [];
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<DeviceModel> pairDevice({
    required String name,
    required String serialNumber,
    String? macAddress,
    String? deviceType,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.pairDevice,
        data: {
          'name': name,
          'serialNumber': serialNumber,
          if (macAddress != null) 'macAddress': macAddress,
          if (deviceType != null) 'deviceType': deviceType,
        },
      );

      final data = response.data?['data'];
      if (data is Map<String, dynamic>) {
        return DeviceModel.fromJson(data);
      }

      throw UnknownException('Invalid pair device response');
    } on AppException {
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  Future<DeviceModel> updateDeviceStatus({
    required String deviceId,
    required bool isConnected,
  }) async {
    try {
      final response = await _apiService.patch(
        ApiConstants.deviceStatus(deviceId),
        data: {'isConnected': isConnected},
      );

      final data = response.data?['data'];
      if (data is Map<String, dynamic>) {
        return DeviceModel.fromJson(data);
      }

      throw UnknownException('Invalid update device status response');
    } on AppException {
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  Future<void> unpairDevice(String deviceId) async {
    try {
      await _apiService.delete(ApiConstants.unpairDevice(deviceId));
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<Map<String, dynamic>> syncDeviceMetrics(String deviceId) async {
    try {
      final response = await _apiService.get(ApiConstants.deviceMetrics(deviceId));
      final data = response.data?['data'];
      if (data is Map<String, dynamic>) return data;
      return {};
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }
}
