import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/user/connect_device/presentation/controllers/device_pairing_controller.dart';
import 'package:pler_to_pler_app/features/user/connect_device/presentation/widgets/connected_device_tile.dart';
import 'package:pler_to_pler_app/features/user/connect_device/presentation/widgets/device_pairing_dialog.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ManageDevicesScreen extends StatelessWidget {
  const ManageDevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = DevicePairingController.to;

    return Obx(
      () => SliverScaffold(
        appBarTitle: 'Manage devices',
        slivers: (context) {
          if (controller.isLoadingDevices.value) {
            return [
              SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ];
          }

          return controller.isEmpty
              ? _buildEmptySlivers(controller)
              : _buildDeviceSlivers(controller);
        },
        bottomNavigationBar: controller.isEmpty
            ? null
            : CustomButton(
                label: 'Add a new device',
                onPressed: () => _openPairingDialog(controller),
              ),
      ),
    );
  }

  Future<void> _openPairingDialog(DevicePairingController controller) async {
    await controller.openPairingFlow();
    if (!controller.isPairing.value) return;

    await Get.dialog(
      const DevicePairingDialog(),
      barrierDismissible: false,
    );
  }

  List<Widget> _buildEmptySlivers(DevicePairingController controller) {
    return [
      SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomText(
                text: 'No Devices Connected',
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 8.h),
              CustomText(
                text:
                    'You haven’t connected any devices yet. Connect a device to start tracking your fitness data and activity.',
                textAlign: TextAlign.center,
                color: Colors.grey,
              ),
              SizedBox(height: 24.h),
              CustomButton(
                label: 'Add a New Device',
                onPressed: () => _openPairingDialog(controller),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildDeviceSlivers(DevicePairingController controller) {
    return [
      SizedBox(height: 16.h).asSliver,
      SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        sliver: SliverList.separated(
          itemCount: controller.pairedDevices.length,
          separatorBuilder: (_, _) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final device = controller.pairedDevices[index];
            return ConnectedDeviceTile(
              device: device,
              onSetPrimary: () => controller.setPrimaryDevice(device),
              onRemove: () => controller.unpairDevice(device),
              onSync: () => controller.syncDeviceMetrics(device),
            );
          },
        ),
      ),
    ];
  }
}
