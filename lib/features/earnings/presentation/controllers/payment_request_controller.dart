import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/constants/app_constants.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/earnings/domain/services/withdrawal_service.dart';

class PaymentRequestController extends GetxController {
  PaymentRequestController({required WithdrawalService service}) : _service = service;

  final WithdrawalService _service;

  static PaymentRequestController get to => Get.find();

  // State variables (all .obs)
  final accountName = ''.obs;
  final accountEmail = ''.obs;
  final selectedMethod = 'stripe'.obs; // 'stripe' or 'paypal'
  final paymentIdentifier = ''.obs; // email OR stripeAccountId depending on method
  final amount = ''.obs;
  final note = ''.obs;
  final isLoading = false.obs;

  // TextEditingControllers for forms
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final identifierController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Synchronize text controllers with obs variables
    nameController.addListener(() => accountName.value = nameController.text);
    emailController.addListener(() => accountEmail.value = emailController.text);
    identifierController.addListener(() => paymentIdentifier.value = identifierController.text);
    amountController.addListener(() => amount.value = amountController.text);
    noteController.addListener(() => note.value = noteController.text);
  }

  void selectMethod(String method) {
    if (selectedMethod.value == method) return;
    selectedMethod.value = method;
    identifierController.clear();
    paymentIdentifier.value = '';
  }

  bool _validateFields() {
    if (accountName.value.trim().isEmpty) {
      _showValidationError('Account Name is required');
      return false;
    }
    
    final email = accountEmail.value.trim();
    if (email.isEmpty) {
      _showValidationError('Account Email is required');
      return false;
    }
    if (!AppConstants.emailValidate.hasMatch(email)) {
      _showValidationError('Please enter a valid Account Email');
      return false;
    }

    final identifier = paymentIdentifier.value.trim();
    if (identifier.isEmpty) {
      final label = selectedMethod.value == 'stripe' ? 'Stripe Account ID' : 'Payment Email';
      _showValidationError('$label is required');
      return false;
    }
    if (selectedMethod.value == 'paypal' && !AppConstants.emailValidate.hasMatch(identifier)) {
      _showValidationError('Please enter a valid PayPal Payment Email');
      return false;
    }

    final amtStr = amount.value.trim();
    if (amtStr.isEmpty) {
      _showValidationError('Amount is required');
      return false;
    }
    
    final parsedAmt = double.tryParse(amtStr);
    if (parsedAmt == null || parsedAmt <= 0) {
      _showValidationError('Amount must be a valid positive number');
      return false;
    }

    return true;
  }

  void _showValidationError(String message) {
    Get.snackbar(
      'Validation Error',
      message,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  Future<void> submitWithdrawal() async {
    if (isLoading.value) return;
    if (!_validateFields()) return;

    isLoading.value = true;

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

      Get.snackbar(
        'Success',
        'Payment request submitted successfully!',
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );

      // Go back after a brief delay to allow user to see the success message
      Future.delayed(const Duration(milliseconds: 1500), () {
        Get.back();
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
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
