import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/helpers/time_format.dart';
import 'package:pler_to_pler_app/core/services/connectivity_service.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/user/connect_device/data/models/device_metrics_model.dart';
import 'package:pler_to_pler_app/features/user/connect_device/data/models/device_model.dart';
import 'package:pler_to_pler_app/features/user/connect_device/domain/constants/supported_watch_type.dart';
import 'package:pler_to_pler_app/features/user/connect_device/domain/services/apple_watch_service.dart';
import 'package:pler_to_pler_app/features/user/connect_device/domain/services/device_service.dart';
import 'package:pler_to_pler_app/features/user/connect_device/presentation/controllers/device_details_controller.dart';
import 'package:pler_to_pler_app/features/user/connect_device/presentation/controllers/device_pairing_controller.dart';
import 'package:pler_to_pler_app/features/user/connect_device/presentation/widgets/device_metric_card.dart';
import 'package:pler_to_pler_app/features/user/connect_device/presentation/widgets/device_metrics_shimmer.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class DeviceDetailsScreen extends StatefulWidget {
  const DeviceDetailsScreen({super.key, required this.device});

  final DeviceModel device;

  @override
  State<DeviceDetailsScreen> createState() => _DeviceDetailsScreenState();
}

class _DeviceDetailsScreenState extends State<DeviceDetailsScreen> {
  late final String _controllerTag;

  @override
  void initState() {
    super.initState();
    _controllerTag = 'device_details_${widget.device.id}';

    if (!Get.isRegistered<DeviceDetailsController>(tag: _controllerTag)) {
      Get.put(
        DeviceDetailsController(
          deviceId: widget.device.id,
          initialDevice: widget.device,
          deviceService: Get.find<DeviceService>(),
          pairingController: DevicePairingController.to,
          appleWatchService: Get.find<AppleWatchService>(),
          connectivityService: Get.find<ConnectivityService>(),
        ),
        tag: _controllerTag,
      );
    }
  }

  @override
  void dispose() {
    if (Get.isRegistered<DeviceDetailsController>(tag: _controllerTag)) {
      Get.delete<DeviceDetailsController>(tag: _controllerTag);
    }
    super.dispose();
  }

  DeviceDetailsController get _controller =>
      Get.find<DeviceDetailsController>(tag: _controllerTag);

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return SliverScaffold(
      appBar: CustomSliverAppBar(
        title: 'Device details',
      ),
      onRefresh: controller.reloadDetails,
      bodyList: [
        Obx(() {
          final currentDevice = controller.device;
          final watchType =
              SupportedWatchType.fromApiValue(currentDevice.deviceType);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 8.h),
              _DeviceHeaderCard(
                device: currentDevice,
                watchTypeName: watchType?.displayName,
                isConnecting: controller.isConnecting.value,
              ),
              if (controller.isAppleWatch &&
                  !controller.healthPermissionGranted.value) ...[
                SizedBox(height: 12.h),
                _HealthPermissionBanner(controller: controller),
              ],
              SizedBox(height: 16.h),
              _buildMetricsSection(controller),
              if (controller.metrics.value?.sessions.isNotEmpty ?? false) ...[
                SizedBox(height: 16.h),
                _SessionsSection(
                  sessions: controller.metrics.value!.sessions,
                ),
              ],
              SizedBox(height: 24.h),
            ],
          ).asSliverWithPadding(horizontal: 16.w);
        }),
        SizedBox(height: 120.h).asSliver,
      ],
      bottomNavigationBar: Obx(() {
        final currentDevice = controller.device;

        return Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!currentDevice.isConnected)
                CustomButton(
                  label: 'Connect device',
                  isLoading: controller.isConnecting.value,
                  isDisabled: controller.isConnecting.value,
                  onPressed: controller.connectDevice,
                ),
              if (!currentDevice.isConnected) SizedBox(height: 10.h),
              CustomButton(
                label: 'Sync metrics',
                isLoading: controller.isSyncing.value,
                isDisabled: controller.isSyncing.value,
                onPressed: controller.syncMetrics,
                backgroundColor:
                    currentDevice.isConnected ? AppColors.primary : null,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMetricsSection(DeviceDetailsController controller) {
    switch (controller.loadingState.value) {
      case LoadingState.initial:
      case LoadingState.loading:
        return const DeviceMetricsShimmer();
      case LoadingState.offline:
        return EmptyDataWidget(
          message: 'You are offline. Connect to view metrics.',
          onRefresh: controller.reloadDetails,
        );
      case LoadingState.error:
        return EmptyDataWidget(
          message: 'Could not load device metrics',
          onRefresh: controller.reloadDetails,
        );
      case LoadingState.loaded:
        final metrics = controller.metrics.value;
        if (metrics == null || metrics.isEmpty) {
          return _EmptyMetricsCard(onSync: controller.syncMetrics);
        }
        return _MetricsGrid(metrics: metrics);
    }
  }
}

class _DeviceHeaderCard extends StatelessWidget {
  const _DeviceHeaderCard({
    required this.device,
    required this.watchTypeName,
    required this.isConnecting,
  });

  final DeviceModel device;
  final String? watchTypeName;
  final bool isConnecting;

  @override
  Widget build(BuildContext context) {
    final isConnected = device.isConnected;
    final statusColor =
        isConnected ? const Color(0xFF4CAF50) : AppColors.textSecondary;

    return CustomContainer(
      radiusAll: 20.r,
      paddingAll: 16.r,
      width: double.infinity,
      color: Colors.white,
      child: Row(
        children: [
          CustomContainer(
            radiusAll: 16.r,
            paddingAll: 14.r,
            color: AppColors.primary.withValues(alpha: 0.1),
            child: Icon(
              Icons.watch_outlined,
              size: 28.sp,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: device.name,
                  fontSize: 18.sp,
                  fontWeight: AppFontWeight.section,
                  textAlign: TextAlign.start,
                ),
                if (watchTypeName != null)
                  CustomText(
                    top: 4.h,
                    text: watchTypeName!,
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                    textAlign: TextAlign.start,
                  ),
                CustomText(
                  top: 4.h,
                  text: device.serialNumber,
                  fontSize: 11.sp,
                  color: AppColors.textSecondary,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
          CustomContainer(
            paddingHorizontal: 12.w,
            paddingVertical: 6.h,
            radiusAll: 20.r,
            color: isConnecting ? AppColors.primary : statusColor,
            child: isConnecting
                ? SizedBox(
                    width: 14.r,
                    height: 14.r,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : CustomText(
                    text: isConnected ? 'Connected' : 'Offline',
                    fontSize: 11.sp,
                    fontWeight: AppFontWeight.label,
                    color: Colors.white,
                  ),
          ),
        ],
      ),
    );
  }
}

class _HealthPermissionBanner extends StatelessWidget {
  const _HealthPermissionBanner({required this.controller});

  final DeviceDetailsController controller;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      radiusAll: 14.r,
      paddingAll: 14.r,
      color: const Color(0xFFFFF4E5),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.health_and_safety_outlined,
                  color: AppColors.primary, size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: CustomText(
                  text: 'Health permission needed',
                  fontWeight: AppFontWeight.label,
                  fontSize: 14.sp,
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          CustomText(
            text:
                'Allow access to Steps and Heart Rate in Apple Health to sync your Apple Watch.',
            fontSize: 12.sp,
            color: AppColors.textSecondary,
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 12.h),
          CustomButton(
            label: 'Allow Health access',
            isLoading: controller.isCheckingPermissions.value,
            isDisabled: controller.isCheckingPermissions.value,
            onPressed: controller.requestHealthPermissions,
          ),
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.metrics});

  final DeviceMetricsModel metrics;

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.decimalPattern();
    final syncedLabel = metrics.syncedAt != null
        ? TimeFormatHelper.formatDateTime(metrics.syncedAt!)
        : 'Not synced yet';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomContainer(
          radiusAll: 14.r,
          paddingHorizontal: 14.w,
          paddingVertical: 10.h,
          color: AppColors.backgroundLight,
          width: double.infinity,
          child: Row(
            children: [
              Icon(Icons.update, size: 16.sp, color: AppColors.textSecondary),
              SizedBox(width: 8.w),
              Expanded(
                child: CustomText(
                  text: 'Last synced: $syncedLabel',
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        CustomText(
          text: 'Today\'s activity',
          fontSize: 16.sp,
          fontWeight: AppFontWeight.section,
          textAlign: TextAlign.start,
          bottom: 12.h,
        ),
        Row(
          children: [
            Expanded(
              child: DeviceMetricCard(
                icon: Icons.directions_walk_rounded,
                label: 'Steps',
                value: numberFormat.format(metrics.steps),
                unit: '',
                accentColor: AppColors.primary,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: DeviceMetricCard(
                icon: Icons.favorite_rounded,
                label: 'Heart rate',
                value: metrics.heartRate != null
                    ? metrics.heartRate!.round().toString()
                    : '--',
                unit: metrics.heartRate != null ? 'bpm' : '',
                accentColor: const Color(0xFFE91E63),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: DeviceMetricCard(
                icon: Icons.social_distance_rounded,
                label: 'Distance',
                value: _formatDistance(metrics.distanceMeters),
                unit: _distanceUnit(metrics.distanceMeters),
                accentColor: const Color(0xFF2196F3),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: DeviceMetricCard(
                icon: Icons.local_fire_department_rounded,
                label: 'Calories',
                value: metrics.calories != null && metrics.calories! > 0
                    ? numberFormat.format(metrics.calories!)
                    : '--',
                unit: metrics.calories != null && metrics.calories! > 0
                    ? 'kcal'
                    : '',
                accentColor: const Color(0xFFFF9800),
              ),
            ),
          ],
        ),
        if (metrics.activeMinutes != null && metrics.activeMinutes! > 0) ...[
          SizedBox(height: 10.h),
          DeviceMetricCard(
            icon: Icons.timer_outlined,
            label: 'Active minutes',
            value: metrics.activeMinutes!.toString(),
            unit: 'min',
            accentColor: const Color(0xFF9C27B0),
          ),
        ],
      ],
    );
  }

  String _formatDistance(double? meters) {
    if (meters == null) return '--';
    if (meters >= 1000) {
      return (meters / 1000).toStringAsFixed(1);
    }
    return meters.round().toString();
  }

  String _distanceUnit(double? meters) {
    if (meters == null) return '';
    return meters >= 1000 ? 'km' : 'm';
  }
}

class _EmptyMetricsCard extends StatelessWidget {
  const _EmptyMetricsCard({required this.onSync});

  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      radiusAll: 20.r,
      paddingAll: 24.r,
      color: Colors.white,
      width: double.infinity,
      child: Column(
        children: [
          Icon(
            Icons.insights_outlined,
            size: 40.sp,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 12.h),
          CustomText(
            text: 'No metrics yet',
            fontSize: 16.sp,
            fontWeight: AppFontWeight.label,
          ),
          SizedBox(height: 6.h),
          CustomText(
            text: 'Sync your device to load today\'s activity data.',
            textAlign: TextAlign.center,
            color: AppColors.textSecondary,
            fontSize: 13.sp,
          ),
          SizedBox(height: 16.h),
          CustomButton(label: 'Sync now', onPressed: onSync),
        ],
      ),
    );
  }
}

class _SessionsSection extends StatelessWidget {
  const _SessionsSection({required this.sessions});

  final List<DeviceMetricsSession> sessions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: 'Sessions',
          fontSize: 16.sp,
          fontWeight: AppFontWeight.section,
          textAlign: TextAlign.start,
          bottom: 12.h,
        ),
        ...sessions.map((session) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: CustomContainer(
                radiusAll: 14.r,
                paddingHorizontal: 14.w,
                paddingVertical: 12.h,
                color: Colors.white,
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: '${session.steps} steps',
                            fontWeight: AppFontWeight.label,
                            fontSize: 14.sp,
                            textAlign: TextAlign.start,
                          ),
                          if (session.deviceType != null)
                            CustomText(
                              top: 4.h,
                              text: session.deviceType!,
                              fontSize: 11.sp,
                              color: AppColors.textSecondary,
                              textAlign: TextAlign.start,
                            ),
                        ],
                      ),
                    ),
                    if (session.heartRate != null)
                      CustomText(
                        text: '${session.heartRate!.round()} bpm',
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}
