import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/user/connect_device/presentation/controllers/manage_devices_controller.dart';
import 'package:pler_to_pler_app/features/user/connect_device/presentation/widgets/connected_device_tile.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ManageDevicesScreen extends StatelessWidget {
  const ManageDevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ManageDevicesController.to;

    return CustomScaffold(
      paddingSide: 0,
      appBar: CustomAppBar(title: 'Manage devices'),
      body: Obx(() {
        if (controller.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Center(
              child: CustomButton(
                label: 'Add a new device',
                onPressed: controller.openConnectDevice,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
          itemCount: controller.devices.length,
          separatorBuilder: (_, _) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            return ConnectedDeviceTile(device: controller.devices[index]);
          },
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.isEmpty) return const SizedBox.shrink();

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
            child: CustomButton(
              label: 'Add a new device',
              onPressed: controller.openConnectDevice,
            ),
          ),
        );
      }),
    );
  }
}
