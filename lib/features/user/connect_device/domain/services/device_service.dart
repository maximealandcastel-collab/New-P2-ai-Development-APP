import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/features/user/connect_device/data/models/device_model.dart';
import 'package:pler_to_pler_app/features/user/connect_device/data/repositories/device_repository.dart';

class DeviceService {
  DeviceService({required DeviceRepository repository}) : _repository = repository;

  final DeviceRepository _repository;

  Future<List<DeviceModel>> fetchUserDevices() async {
    try {
      return await _repository.getUserDevices();
    } on AppException {
      if (!_repository.hasCache()) {
        rethrow;
      }
      return _repository.getCachedDevices();
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  List<DeviceModel> getCachedDevices() => _repository.getCachedDevices();

  Future<void> saveCachedDevices(List<DeviceModel> devices) =>
      _repository.saveCachedDevices(devices);

  bool hasCache() => _repository.hasCache();

  Future<DeviceModel> pairDevice({
    required String name,
    required String serialNumber,
    String? macAddress,
    String? deviceType,
  }) {
    return _repository.pairDevice(
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
    return _repository.updateDeviceStatus(
      deviceId: deviceId,
      isConnected: isConnected,
    );
  }

  Future<void> unpairDevice(String deviceId) => _repository.unpairDevice(deviceId);

  Future<Map<String, dynamic>> syncDeviceMetrics(String deviceId) =>
      _repository.syncDeviceMetrics(deviceId);
}
