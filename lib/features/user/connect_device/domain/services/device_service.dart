import 'package:pler_to_pler_app/features/user/connect_device/data/models/device_model.dart';
import 'package:pler_to_pler_app/features/user/connect_device/data/services/device_api_service.dart';

class DeviceService {
  DeviceService({required DeviceApiService apiService}) : _apiService = apiService;

  final DeviceApiService _apiService;

  Future<List<DeviceModel>> getUserDevices() => _apiService.getUserDevices();

  Future<DeviceModel> pairDevice({
    required String name,
    required String serialNumber,
    String? macAddress,
    String? deviceType,
  }) {
    return _apiService.pairDevice(
      name: name,
      serialNumber: serialNumber,
      macAddress: macAddress,
      deviceType: deviceType,
    );
  }

  Future<DeviceModel> updateDeviceStatus({
    required String deviceId,
    required bool isConnected,
  }) {
    return _apiService.updateDeviceStatus(
      deviceId: deviceId,
      isConnected: isConnected,
    );
  }

  Future<void> unpairDevice(String deviceId) => _apiService.unpairDevice(deviceId);

  Future<Map<String, dynamic>> syncDeviceMetrics(String deviceId) =>
      _apiService.syncDeviceMetrics(deviceId);
}
