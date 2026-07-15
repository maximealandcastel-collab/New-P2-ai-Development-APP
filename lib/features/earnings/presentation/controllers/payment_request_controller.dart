import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/earnings/domain/services/withdrawal_service.dart';

class PaymentRequestController extends GetxController {
  PaymentRequestController({required WithdrawalService service}) : _service = service;

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

  @override
  void onInit() {
    super.onInit();
  }

  void selectMethod(String method) {
    if (selectedMethod.value == method) return;
    selectedMethod.value = method;
    identifierController.clear();
    paymentIdentifier.value = '';
  }

  Future<void> submitWithdrawal() async {
    if (_requestState.value == LoadingState.loading) return;

    _requestState.value = LoadingState.loading;

    try {
      final parsedAmount = double.parse(amount.value.trim());
      final requestedAmountCents = (parsedAmount * 100).toInt();

      final Map<String, dynamic> body = {
        'requestedAmountCents': requestedAmountCents,
        'withdrawalMethod': selectedMethod.value,
        'additionalNote': note.value.trim(),
      };

      if (selectedMethod.value == 'paypal') {
        body['paymentEmail'] = paymentIdentifier.value.trim();
      } else {
        body['stripeAccountId'] = paymentIdentifier.value.trim();
      }

      await _service.submitWithdrawal(body);

      _requestState.value = LoadingState.loaded;

      // Close the confirmation dialog
      Get.back();

      // Show success toast/snackbar
      Get.snackbar(
        'Success',
        'Payment request submitted successfully!',
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );

      // Go back from the payment screen after a brief delay
      Future.delayed(const Duration(milliseconds: 1500), () {
        Get.back();
      });
    } catch (e) {
      _requestState.value = LoadingState.error;
      
      // Close the confirmation dialog to allow correction
      Get.back();

      // Show error snackbar
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
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
