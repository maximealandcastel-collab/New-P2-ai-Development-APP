import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/user/connect_device/presentation/controllers/device_pairing_controller.dart';
import 'package:pler_to_pler_app/features/user/connect_device/presentation/widgets/pairing_progress_view.dart';
import 'package:pler_to_pler_app/features/user/connect_device/presentation/widgets/pairing_scanning_view.dart';
import 'package:pler_to_pler_app/features/user/connect_device/presentation/widgets/select_watch_view.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final DevicePairingController _controller = DevicePairingController.to;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.preparePairingUi();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final step = _controller.pairingStep.value;
      final isProgress =
          step == PairingStep.connecting || step == PairingStep.saving;

      Widget content;
      if (isProgress) {
        content = PairingProgressView(
          key: ValueKey(step),
          controller: _controller,
        );
      } else if (step == PairingStep.selectingWatch) {
        content = SelectWatchView(
          key: const ValueKey('select_watch'),
          controller: _controller,
        );
      } else {
        content = PairingScanningView(
          key: const ValueKey('scanning'),
          controller: _controller,
        );
      }

      return SliverScaffold(
        appBar: CustomSliverAppBar(
          title: 'Add device',
          backAction: () => _controller.cancelPairing(),
        ),
        slivers: (context) => [
          SizedBox(height: 8.h).asSliver,
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: content,
          ).asSliverWithPadding(horizontal: 16.w),
          SizedBox(height: 24.h).asSliver,
        ],
      );
    });
  }
}
