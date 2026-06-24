import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/user/connect_device/presentation/controllers/device_pairing_controller.dart';
import 'package:pler_to_pler_app/features/user/connect_device/presentation/widgets/pairing/pairing_progress_view.dart';
import 'package:pler_to_pler_app/features/user/connect_device/presentation/widgets/pairing/pairing_scanning_view.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _startPairing());
  }

  Future<void> _startPairing() async {
    _controller.preparePairingUi();
    try {
      await _controller.startScanning();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(
        title: 'Add device',
        backAction: () => _controller.cancelPairing(showError: false),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Obx(() {
          final step = _controller.pairingStep.value;

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: step == PairingStep.connecting || step == PairingStep.saving
                ? PairingProgressView(
                    key: ValueKey(step),
                    controller: _controller,
                  )
                : PairingScanningView(
                    key: const ValueKey('scanning'),
                    controller: _controller,
                  ),
          );
        }),
      ),
    );
  }
}
