import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/features/earnings/domain/services/withdrawal_service.dart';

class PaymentRequestController extends GetxController {
  PaymentRequestController({required WithdrawalService service})
    : _service = service;

  final WithdrawalService _service;

  static PaymentRequestController get to => Get.find();

  // ─── State ───────────────────────────────
  final _requestState = LoadingState.initial.obs;

  LoadingState get requestState => _requestState.value;

  final formKey = GlobalKey<FormState>();
  final selectedMethod = 'stripe'.obs; // 'stripe' or 'paypal'

  // TextEditingControllers for forms
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final identifierController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  void selectMethod(String method) {
    if (selectedMethod.value == method) return;
    selectedMethod.value = method;
    identifierController.clear();
  }

  Future<void> submitWithdrawal() async {
    if (_requestState.value == LoadingState.loading) return;

    _requestState.value = LoadingState.loading;

    try {
      final parsedAmount = double.parse(amountController.text.trim());
      final requestedAmountCents = (parsedAmount * 100).toInt();

      final Map<String, dynamic> body = {
        'requestedAmountCents': requestedAmountCents,
        'withdrawalMethod': selectedMethod.value,
        'additionalNote': noteController.text.trim(),
        'paymentEmail': identifierController.text.trim(),
      };

      await _service.submitWithdrawal(body);

      _requestState.value = LoadingState.loaded;
      Get.back(canPop: true);
      Get.back(canPop: true);
      nameController.clear();
      emailController.clear();
      identifierController.clear();
      amountController.clear();
      noteController.clear();
    } catch (e) {
      _requestState.value = LoadingState.error;
      Get.back();
      ToastMessageHelper.show(e.errorMessage);
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    identifierController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.onClose();
  }
}
