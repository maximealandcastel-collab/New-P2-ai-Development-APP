import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/services/api_urls.dart';
import 'package:pler_to_pler_app/services/network/api_client.dart';

class PaywallController extends GetxController {
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
      final response =
          await ApiClient.postData(ApiUrls.promoValidate, {"code": code});
      if (response.statusCode == 200) {
        appliedPromoCode.value = code;
        final data = response.body;
        if (data is Map && data["data"] is Map) {
          promoPlanLabel.value = (data["data"]["label"] ?? "").toString();
        }
        showPromoField.value = false;
        log("Promo code applied: $code");
      } else {
        promoError.value = (response.statusText ?? "").isNotEmpty
            ? response.statusText!
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
      final response = await ApiClient.postData(ApiUrls.checkoutDefault, body);
      if (response.statusCode == 200 && response.body is Map) {
        final data = (response.body as Map)["data"];
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
      Get.snackbar(
          "Checkout failed", "Something went wrong. Please try again.");
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
