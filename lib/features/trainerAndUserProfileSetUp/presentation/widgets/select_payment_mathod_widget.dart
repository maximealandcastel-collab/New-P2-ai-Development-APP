import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p2p_fitness/core/common/widgets/custom_text.dart';
import 'package:p2p_fitness/features/trainerAndUserProfileSetUp/controller/trainer_tax_info_and_paymnet_controller.dart';

class SelectPaymentMathodWidget extends StatelessWidget {
  const SelectPaymentMathodWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TrainerTaxInfoAndPaymnetController>();
    return SafeArea(child: CustomText(text: ""));
  }
}
