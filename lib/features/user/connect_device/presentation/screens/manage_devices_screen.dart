import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/user/connect_device/presentation/controllers/device_pairing_controller.dart';
import 'package:pler_to_pler_app/features/user/connect_device/presentation/widgets/connected_device_tile.dart';
import 'package:pler_to_pler_app/features/user/connect_device/presentation/widgets/device_shimmer.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ManageDevicesScreen extends StatelessWidget {
  const ManageDevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = DevicePairingController.to;

    return SliverScaffold(
      appBar: CustomSliverAppBar(
        title: 'Manage devices',
      ),
      onRefresh: controller.fetchPairedDevices,
      bodyList: [
        Obx(() {
          switch (controller.loadingState) {
            case LoadingState.initial:
            case LoadingState.loading:
              return const DeviceShimmer().asSliver;
            case LoadingState.offline:
            case LoadingState.error:
              return EmptyDataWidget(
                message: 'Failed to load devices',
                onRefresh: controller.fetchPairedDevices,
              ).asSliver;
            case LoadingState.loaded:
              if (controller.isEmpty) {
                return _buildEmptySliver(controller);
              }
              return _buildDeviceSliver(controller);
          }
        }),
        SizedBox(height: 120.h).asSliver,
      ],
      bottomNavigationBar: Obx(() {
        if (controller.loadingState != LoadingState.loaded || controller.isEmpty) {
          return const SizedBox.shrink();
        }

        return CustomButton(
          label: 'Add a new device',
          onPressed: () => Get.toNamed(AppRoute.addDeviceScreen),
        );
      }),
    );
  }

  Widget _buildEmptySliver(DevicePairingController controller) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomText(
              text: 'No Devices Connected',
              fontSize: 20.sp,
              fontWeight: AppFontWeight.label,
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
              onPressed: () => Get.toNamed(AppRoute.addDeviceScreen),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceSliver(DevicePairingController controller) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      sliver: SliverList.separated(
        itemCount: controller.pairedDevices.length,
        separatorBuilder: (_, _) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final device = controller.pairedDevices[index];
          return Obx(
            () => ConnectedDeviceTile(
              device: device,
              isConnecting: controller.connectingDeviceId.value == device.id,
              onTap: () => Get.toNamed(
                AppRoute.deviceDetailsScreen,
                arguments: device,
              ),
              onRemove: () => controller.unpairDevice(device),
              onSync: () => controller.syncDeviceMetrics(device),
            ),
          );
        },
      ),
    );
  }
}
