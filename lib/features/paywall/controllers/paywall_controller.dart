import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:pler_to_pler_app/core/services/tenant_brand_service.dart';
import 'package:pler_to_pler_app/services/api_urls.dart';
import 'package:pler_to_pler_app/services/network/api_client.dart';

const String _standard3mId = 'p2p_standard_3m';
const String _standardAnnualId = 'p2p_standard_annual';
const String _pro3mId = 'p2p_pro_3m';
const String _proAnnualId = 'p2p_pro_annual';

// Aliases for default monthly/annual selection
const String _monthlyId = _standard3mId;
const String _annualId = _standardAnnualId;

const Set<String> _productIds = {
  _standard3mId,
  _standardAnnualId,
  _pro3mId,
  _proAnnualId,
};

class PaywallController extends GetxController {
  static PaywallController get to => Get.find<PaywallController>();

  static const String _pendingIapKey = 'pendingSignupIap';
  static const String _pendingAccessCodeKey = 'pendingSignupAccessCode';

  String _paidDestination = AppRoute.subscribeSelectScreen;
  String _selfGuidedDestination = AppRoute.bottonNavBar;
  dynamic _destinationArguments;
  bool _preSignup = false;

  bool get isPreSignup => _preSignup;

  void configureDestination(dynamic arguments) {
    _preSignup = arguments is Map && arguments['preSignup'] == true;
    if (arguments is Map) {
      final nextRoute = arguments['nextRoute'];
      if (nextRoute is String && nextRoute.isNotEmpty) {
        _paidDestination = nextRoute;
      }
      final freeRoute = arguments['freeRoute'];
      if (freeRoute is String && freeRoute.isNotEmpty) {
        _selfGuidedDestination = freeRoute;
      }
      _destinationArguments = arguments['nextArguments'];
      return;
    }
    _paidDestination = AppRoute.subscribeSelectScreen;
    _selfGuidedDestination = AppRoute.bottonNavBar;
    _destinationArguments = null;
  }

  void _openDestination(String route) {
    if (_preSignup) {
      Get.offNamed(route, arguments: _destinationArguments);
    } else {
      Get.offAllNamed(route, arguments: _destinationArguments);
    }
  }

  void continueSelfGuided() => _openDestination(_selfGuidedDestination);

  void _continueToTrainerSelection() => _openDestination(_paidDestination);

  void closePaywall() => Get.back();

  void openTrainerSignup() {
    _paidDestination = AppRoute.signUpScreen;
    _selfGuidedDestination = AppRoute.signUpScreen;
    _destinationArguments = {
      'trainerEntry': true,
      'role': 'Trainer',
    };
    Get.snackbar(
      'Trainer signup selected',
      'Choose a plan or enter your website access code to continue.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

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
  final selectedPlan = "monthly".obs;
  void selectPlan(String plan) => selectedPlan.value = plan;

  // ─── Promo code — applied via the access-code field below ───
  final appliedPromoCode = "".obs;
  final promoPlanLabel = "".obs;
  // Apple product id the backend says this promo maps to. Apple charges
  // whatever this product is priced at in App Store Connect — the app
  // never computes or shows a discount that Apple isn't actually charging.
  final appliedPromoProductId = "".obs;
  final promoProductPriceStr = "".obs;

  // ─── Access code (bottom bar — website purchase codes) ──────
  final accessCodeController = TextEditingController();
  final accessCodeLoading = false.obs;
  final accessCodeError = "".obs;

  bool get hasPromo => appliedPromoCode.value.isNotEmpty;

  /// Displayed price when a promo is applied — always the real App Store
  /// price of the product the backend mapped the code to. Never computed
  /// client-side, since Apple is the one that actually charges it.
  String get promoDisplayPriceStr => promoProductPriceStr.value;

  // ─── Lifecycle ──────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    configureDestination(Get.arguments);
    _initIAP();
  }

  Future<void> _initIAP() async {
    try {
      final available = await _iap.isAvailable();
      iapAvailable.value = available;
      if (!available) {
        purchaseError.value =
            "In-app purchases are not available on this device.";
        return;
      }

      _purchaseSub ??= _iap.purchaseStream.listen(
        _onPurchaseUpdate,
        onError: (Object e) {
          purchaseLoading.value = false;
          purchaseError.value = "Purchase stream error. Please try again.";
        },
      );

      final ProductDetailsResponse response =
          await _iap.queryProductDetails(_productIds);
      if (response.error != null) {
        throw Exception(response.error!.message);
      }
      products.assignAll(response.productDetails);
      for (final p in response.productDetails) {
        if (p.id == _annualId) annualPriceStr.value = p.price;
        if (p.id == _monthlyId) monthlyPriceStr.value = p.price;
      }
      if (response.notFoundIDs.isNotEmpty || products.isEmpty) {
        purchaseError.value =
            "Subscription details are temporarily unavailable. Please retry.";
      }
    } catch (_) {
      iapAvailable.value = false;
      purchaseLoading.value = false;
      purchaseError.value =
          "Could not connect to the App Store. Please try again.";
    }
  }

  // ─── Purchase ───────────────────────────────────────────────
  Future<void> startFreeTrial() async {
    selectedPlan.value = 'monthly';
    await upgradeNow();
  }

  Future<void> upgradeNow() async {
    purchaseError.value = "";

    if (!iapAvailable.value) {
      purchaseError.value =
          "In-app purchases are not available on this device.";
      return;
    }

    // A promo maps to a specific Apple product — Apple charges whatever
    // that product is priced at in App Store Connect, so purchasing it
    // is the only way the discount is ever actually applied.
    final selectedId = hasPromo && appliedPromoProductId.value.isNotEmpty
        ? appliedPromoProductId.value
        : (selectedPlan.value == "annual" ? _annualId : _monthlyId);
    final ProductDetails? product =
        products.firstWhereOrNull((p) => p.id == selectedId);

    if (product == null) {
      purchaseError.value =
          "Could not load subscription details. Please try again.";
      return;
    }

    purchaseLoading.value = true;
    try {
      final PurchaseParam param = PurchaseParam(productDetails: product);
      final accepted = await _iap.buyNonConsumable(purchaseParam: param);
      if (!accepted) {
        purchaseLoading.value = false;
        purchaseError.value =
            "The purchase could not be started. Please try again.";
      }
    } catch (_) {
      purchaseLoading.value = false;
      purchaseError.value =
          "The purchase could not be started. Please try again.";
    }
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

      if (_preSignup) {
        await CacheService().box.put(_pendingIapKey, body);
        purchaseLoading.value = false;
        _continueToTrainerSelection();
        return;
      }

      final response = await ApiClient.postData(ApiUrls.iapVerify, body);

      if (response.statusCode == 200) {
        purchaseLoading.value = false;
        // If a promo code was applied, redeem it server-side now. The
        // backend only honors this if purchaseId matches a verified Apple
        // transaction for the promo's product — the code alone never
        // unlocked anything until this point.
        if (hasPromo) {
          await _redeemPromo(purchaseId: body["purchaseId"] as String?);
        }
        Get.snackbar(
          "You're subscribed!",
          "Welcome to ${TenantBrandService.to.displayName}. Full access unlocked.",
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
        _continueToTrainerSelection();
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

  Future<void> _redeemPromo({String? purchaseId}) async {
    try {
      await ApiClient.postData(ApiUrls.promoRedeem, {
        "code": appliedPromoCode.value,
        if (purchaseId != null) "purchaseId": purchaseId,
      });
    } catch (_) {
      // Non-fatal: subscription is active regardless
    }
  }

  /// Applies a validated discount code that maps to an Apple purchase.
  /// This never grants access by itself — it only records which Apple
  /// product to buy and, if available, its real App Store price. The
  /// backend redeems the code (via _redeemPromo) only after that exact
  /// product has been purchased and verified.
  Future<void> _applyIapPromo(String code, Map codeData) async {
    appliedPromoCode.value = code;
    promoPlanLabel.value = (codeData["label"] ?? "").toString();
    // The backend is being migrated from "revenueCatProductId" (legacy —
    // this app never used RevenueCat) to "appleProductId". Read either
    // until the backend rename ships, so this keeps working during that
    // transition instead of silently falling back to the base product.
    final productId = (codeData["appleProductId"] ??
            codeData["revenueCatProductId"] ??
            "")
        .toString();
    appliedPromoProductId.value = productId;
    promoProductPriceStr.value = "";
    if (productId.isEmpty) return;

    var product = products.firstWhereOrNull((p) => p.id == productId);
    if (product == null) {
      try {
        final resp = await _iap.queryProductDetails({productId});
        if (resp.productDetails.isNotEmpty) {
          product = resp.productDetails.first;
          products.add(product);
        }
      } catch (_) {
        // Price display will just be unavailable; purchase still targets
        // the correct product id.
      }
    }
    if (product != null) promoProductPriceStr.value = product.price;
  }

  void removePromoCode() {
    appliedPromoCode.value = "";
    promoPlanLabel.value = "";
    appliedPromoProductId.value = "";
    promoProductPriceStr.value = "";
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
      final codeType = (codeData["type"] ?? "").toString();
      final label = (codeData["label"] ?? "").toString();

      // Only "website" codes (already paid via Clover on p2pfitechai.com)
      // skip Apple checkout. Every other type is tied to an Apple purchase
      // — entering the code here must never unlock access on its own, so
      // hand it off to the same purchase flow the promo card uses instead
      // of redeeming it directly.
      if (codeType != "website") {
        await _applyIapPromo(code, codeData);
        accessCodeController.clear();
        if (_preSignup) {
          await CacheService().box.put(_pendingAccessCodeKey, code);
        }
        Get.snackbar(
          "Code applied",
          label.isNotEmpty
              ? "$label — choose a plan below to complete your purchase."
              : "Choose a plan below to complete your purchase.",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Step 2 — pre-signup codes are activated after OTP creates the JWT.
      if (_preSignup) {
        await CacheService().box.put(_pendingAccessCodeKey, code);
        _continueToTrainerSelection();
        return;
      }
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
        _continueToTrainerSelection();
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

  Future<bool> activatePendingEntitlement() async {
    final cache = CacheService();
    final pendingIap = cache.get<Map<String, dynamic>>(_pendingIapKey);
    final pendingCode = cache.get<String>(_pendingAccessCodeKey);

    try {
      if (pendingIap != null) {
        final response = await ApiClient.postData(ApiUrls.iapVerify, pendingIap);
        if (response.statusCode != 200) return false;
        await cache.delete(_pendingIapKey);
      }
      if (pendingCode != null && pendingCode.isNotEmpty) {
        final response = await ApiClient.postData(
          ApiUrls.promoRedeem,
          {
            'code': pendingCode,
            if (pendingIap != null) 'purchaseId': pendingIap['purchaseId'],
          },
        );
        if (response.statusCode != 200 && response.statusCode != 201) {
          return false;
        }
        await cache.delete(_pendingAccessCodeKey);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void onClose() {
    _purchaseSub?.cancel();
    accessCodeController.dispose();
    super.onClose();
  }
}
