import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/user/connect_device/data/models/connected_device_model.dart';
import 'package:pler_to_pler_app/features/user/connect_device/presentation/connect_device_screen.dart';

class ManageDevicesController extends GetxController {
  static ManageDevicesController get to => Get.find();

  final RxList<ConnectedDeviceModel> _devices = <ConnectedDeviceModel>[].obs;

  List<ConnectedDeviceModel> get devices => _devices;

  bool get isEmpty => _devices.isEmpty;

  Future<void> openConnectDevice() async {
    final result = await Get.to(() => const ConnectDeviceScreen());
    if (result is ConnectedDeviceModel) {
      addDevice(result);
    }
  }

  void addDevice(ConnectedDeviceModel device) {
    final exists = _devices.any(
      (item) => item.serial == device.serial || item.id == device.id,
    );
    if (!exists) {
      _devices.add(device);
    }
  }
}
