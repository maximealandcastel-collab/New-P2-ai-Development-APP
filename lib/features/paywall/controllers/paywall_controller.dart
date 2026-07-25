import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p2p_fitness/core/services/network_caller.dart';
import 'package:p2p_fitness/core/utils/constants/app_urls.dart';

class PaywallController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();

  /// "annual" or "monthly"
  final selectedPlan = "annual".obs;
  void selectPlan(String plan) {
    selectedPlan.value = plan;
  }

  // ---------------- Promo code ----------------
  final promoController = TextEditingController();
  final showPromoField = false.obs;
  final promoLoading = false.obs;
  final appliedPromoCode = "".obs;
  final promoError = "".obs;
  final promoPlanLabel = "".obs;

  void togglePromoField() {
    showPromoField.value = !showPromoField.value;
    promoError.value = "";
  }

  bool get hasPromo => appliedPromoCode.value.isNotEmpty;

  /// Prices in dollars. 50% off when a promo code is applied.
  double get annualPrice => hasPromo ? 25.00 : 50.00;
  double get monthlyPrice => hasPromo ? 9.99 : 19.99;

  Future<void> applyPromoCode() async {
    final code = promoController.text.trim().toUpperCase();
    if (code.isEmpty) {
      promoError.value = "Please enter a promo code";
      return;
    }
    promoLoading.value = true;
    promoError.value = "";
    try {
      final response = await _networkCaller.postRequest(
        AppUrls.promoValidate,
        body: {"code": code},
      );
      if (response.isSuccess) {
        appliedPromoCode.value = code;
        final data = response.responseData;
        if (data is Map && data["data"] is Map) {
          promoPlanLabel.value =
              (data["data"]["label"] ?? "").toString();
        }
        showPromoField.value = false;
        log("Promo code applied: $code");
      } else {
        promoError.value =
            response.errorMessage.isNotEmpty == true
                ? response.errorMessage
                : "This code is invalid or has already been used";
      }
    } catch (e) {
      promoError.value = "Could not verify the code. Please try again.";
    } finally {
      promoLoading.value = false;
    }
  }

  void removePromoCode() {
    appliedPromoCode.value = "";
    promoPlanLabel.value = "";
    promoController.clear();
    promoError.value = "";
  }

  // ---------------- Checkout ----------------
  final checkoutLoading = false.obs;

  /// Creates the Stripe checkout session and returns the payment URL,
  /// or null on failure (an error snackbar is shown).
  Future<String?> upgradeNow() async {
    checkoutLoading.value = true;
    try {
      final body = <String, dynamic>{
        "tier": selectedPlan.value == "annual" ? "yearly" : "monthly",
      };
      if (hasPromo) {
        body["promoCode"] = appliedPromoCode.value;
      }
      final response = await _networkCaller.postRequest(
        AppUrls.checkoutDefault,
        body: body,
      );
      if (response.isSuccess && response.responseData is Map) {
        final data = (response.responseData as Map)["data"];
        final url = data is Map ? data["paymentUrl"]?.toString() : null;
        if (url != null && url.isNotEmpty) {
          return url;
        }
      }
      Get.snackbar(
        "Checkout failed",
        "Could not start checkout. Please try again.",
      );
      return null;
    } catch (e) {
      Get.snackbar("Checkout failed", "Something went wrong. Please try again.");
      return null;
    } finally {
      checkoutLoading.value = false;
    }
  }

  @override
  void onClose() {
    promoController.dispose();
    super.onClose();
  }
}
