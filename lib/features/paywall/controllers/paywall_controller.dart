import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pler_to_pler_app/features/nav_bar/presentation/screens/nav_bar.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/services/api_urls.dart';
import 'package:pler_to_pler_app/services/network/api_client.dart';

const String _monthlyId = 'month_1';
const String _annualId = 'year_1';
const Set<String> _productIds = {_monthlyId, _annualId};

class PaywallController extends GetxController {
  // ─── IAP ────────────────────────────────────────────────────
  final _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  final products = <ProductDetails>[].obs;
  final iapAvailable = false.obs;
  final purchaseLoading = false.obs;
  final purchaseError = "".obs;

  // App Store price strings (populated once products load)
  final annualPriceStr = r'$50.00'.obs;
  final monthlyPriceStr = r'$19.99'.obs;

  // ─── Plan selection ─────────────────────────────────────────
  final selectedPlan = "annual".obs;
  void selectPlan(String plan) => selectedPlan.value = plan;

  // ─── Promo code (inside card — affiliate/discount codes) ────
  final promoController = TextEditingController();
  final showPromoField = false.obs;
  final promoLoading = false.obs;
  final appliedPromoCode = "".obs;
  final promoError = "".obs;
  final promoPlanLabel = "".obs;

  // ─── Access code (bottom bar — website purchase codes) ──────
  final accessCodeController = TextEditingController();
  final accessCodeLoading = false.obs;
  final accessCodeError = "".obs;

  void togglePromoField() {
    showPromoField.value = !showPromoField.value;
    promoError.value = "";
  }

  bool get hasPromo => appliedPromoCode.value.isNotEmpty;

  /// Fallback display prices (used if App Store products haven't loaded yet)
  double get annualPrice => hasPromo ? 25.00 : 50.00;
  double get monthlyPrice => hasPromo ? 9.99 : 19.99;

  // ─── Lifecycle ──────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _initIAP();
  }

  Future<void> _initIAP() async {
    final available = await _iap.isAvailable();
    iapAvailable.value = available;
    if (!available) return;

    // Listen to purchase updates from the store
    _purchaseSub = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (Object e) {
        purchaseLoading.value = false;
        purchaseError.value = "Purchase stream error. Please try again.";
      },
    );

    // Load product details from App Store / Google Play
    final ProductDetailsResponse response =
        await _iap.queryProductDetails(_productIds);
    if (response.productDetails.isNotEmpty) {
      products.assignAll(response.productDetails);
      for (final p in response.productDetails) {
        if (p.id == _annualId) annualPriceStr.value = p.price;
        if (p.id == _monthlyId) monthlyPriceStr.value = p.price;
      }
    }
  }

  // ─── Purchase ───────────────────────────────────────────────
  Future<void> upgradeNow() async {
    purchaseError.value = "";

    if (!iapAvailable.value) {
      purchaseError.value =
          "In-app purchases are not available on this device.";
      return;
    }

    final selectedId =
        selectedPlan.value == "annual" ? _annualId : _monthlyId;
    final ProductDetails? product =
        products.firstWhereOrNull((p) => p.id == selectedId);

    if (product == null) {
      purchaseError.value =
          "Could not load subscription details. Please try again.";
      return;
    }

    purchaseLoading.value = true;
    final PurchaseParam param = PurchaseParam(productDetails: product);
    // buyNonConsumable handles auto-renewable subscriptions on iOS & Android
    await _iap.buyNonConsumable(purchaseParam: param);
    // purchaseLoading is cleared inside _onPurchaseUpdate
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          purchaseLoading.value = true;
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _verifyWithBackend(purchase);
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          break;

        case PurchaseStatus.error:
          purchaseLoading.value = false;
          purchaseError.value =
              purchase.error?.message ?? "Purchase failed. Please try again.";
          break;

        case PurchaseStatus.canceled:
          purchaseLoading.value = false;
          break;
      }
    }
  }

  Future<void> _verifyWithBackend(PurchaseDetails purchase) async {
    try {
      final body = <String, dynamic>{
        "platform": Platform.isIOS ? "ios" : "android",
        "productId": purchase.productID,
        "purchaseId": purchase.purchaseID ?? purchase.productID,
        "verificationData":
            purchase.verificationData.serverVerificationData,
      };

      final response = await ApiClient.postData(ApiUrls.iapVerify, body);

      if (response.statusCode == 200) {
        purchaseLoading.value = false;
        // If a promo code was applied, redeem it server-side now
        if (hasPromo) await _redeemPromo();
        Get.snackbar(
          "You're subscribed!",
          "Welcome to P2P FitTech AI. Full access unlocked.",
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
        // Navigate to signup so the new subscriber creates their account
        Get.offAllNamed(AppRoute.signUpScreen);
      } else {
        purchaseLoading.value = false;
        purchaseError.value =
            "Purchase verified by Apple but our server could not activate your plan. "
            "Please contact support — you will not be charged twice.";
      }
    } catch (_) {
      purchaseLoading.value = false;
      purchaseError.value =
          "Could not reach our server to activate your plan. "
          "Please contact support if you were charged.";
    }
  }

  Future<void> _redeemPromo() async {
    try {
      await ApiClient.postData(
          ApiUrls.promoRedeem, {"code": appliedPromoCode.value});
    } catch (_) {
      // Non-fatal: subscription is active regardless
    }
  }

  // ─── Promo code ─────────────────────────────────────────────
  Future<void> applyPromoCode() async {
    final code = promoController.text.trim().toUpperCase();
    if (code.isEmpty) {
      promoError.value = "Please enter a promo code";
      return;
    }
    promoLoading.value = true;
    promoError.value = "";
    try {
      // 1. Validate the code
      final response =
          await ApiClient.postData(ApiUrls.promoValidate, {"code": code});
      if (response.statusCode != 200) {
        promoError.value = (response.statusText ?? "").isNotEmpty
            ? response.statusText!
            : "This code is invalid or has already been used";
        return;
      }

      final data = response.body;
      final codeData = (data is Map && data["data"] is Map)
          ? data["data"] as Map
          : <String, dynamic>{};
      final codeType = (codeData["type"] ?? "").toString();
      promoPlanLabel.value = (codeData["label"] ?? "").toString();
      appliedPromoCode.value = code;

      // 2. Website codes (purchased on p2pfitechai.com) — redeem directly,
      //    no IAP needed since the customer already paid on the website.
      if (codeType == "website") {
        final redeemResp =
            await ApiClient.postData(ApiUrls.promoRedeem, {"code": code});
        if (redeemResp.statusCode == 200 || redeemResp.statusCode == 201) {
          Get.snackbar(
            "Access Unlocked! 🎉",
            promoPlanLabel.value.isNotEmpty
                ? "${promoPlanLabel.value} is now active."
                : "Your access is now active. Welcome!",
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 4),
          );
          Get.offAllNamed(AppRoute.signUpScreen);
        } else {
          final msg = (redeemResp.body is Map)
              ? (redeemResp.body["message"] ?? "Could not redeem code. It may already be used.")
              : "Could not redeem code. Please try again.";
          promoError.value = msg.toString();
          appliedPromoCode.value = "";
        }
        return;
      }

      // 3. Affiliate / other codes — apply discount to IAP price as before
      showPromoField.value = false;
    } catch (_) {
      promoError.value = "Could not verify the code. Please try again.";
      appliedPromoCode.value = "";
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

  // ─── Access code redemption (bottom bar) ────────────────────
  // Called when the user taps "Continue" in the "Already a member?" section.
  // Validates the code (no auth needed) then redeems it (requires JWT).
  // Website trial codes skip IAP entirely — the customer already paid online.
  Future<void> redeemAccessCode() async {
    final code = accessCodeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      accessCodeError.value = "Please enter your access code";
      return;
    }
    accessCodeLoading.value = true;
    accessCodeError.value = "";
    try {
      // Step 1 — validate (public, no auth required)
      final validateResp =
          await ApiClient.postData(ApiUrls.promoValidate, {"code": code});
      if (validateResp.statusCode != 200) {
        accessCodeError.value =
            (validateResp.statusText ?? "").isNotEmpty
                ? validateResp.statusText!
                : "Invalid or expired access code";
        return;
      }

      final data = validateResp.body;
      final codeData = (data is Map && data["data"] is Map)
          ? data["data"] as Map
          : <String, dynamic>{};
      final label = (codeData["label"] ?? "").toString();

      // Step 2 — redeem (requires user JWT; user must be logged in)
      final redeemResp =
          await ApiClient.postData(ApiUrls.promoRedeem, {"code": code});
      if (redeemResp.statusCode == 200 || redeemResp.statusCode == 201) {
        Get.snackbar(
          "Access Unlocked! 🎉",
          label.isNotEmpty
              ? "$label is now active."
              : "Welcome! Your access is now active.",
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
        Get.offAllNamed(AppRoute.signUpScreen);
      } else {
        final msg = (redeemResp.body is Map)
            ? (redeemResp.body["message"] ??
                "Code may already be used or is not valid for your account.")
            : "Could not redeem code. Please try again.";
        accessCodeError.value = msg.toString();
      }
    } catch (_) {
      accessCodeError.value = "Could not verify the code. Please try again.";
    } finally {
      accessCodeLoading.value = false;
    }
  }

  @override
  void onClose() {
    _purchaseSub?.cancel();
    promoController.dispose();
    accessCodeController.dispose();
    super.onClose();
  }
}
