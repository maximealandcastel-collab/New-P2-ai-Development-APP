import 'dart:async';
    import 'dart:io';

    import 'package:flutter/foundation.dart';
    import 'package:get/get.dart';
    import 'package:in_app_purchase/in_app_purchase.dart';
    import 'package:pler_to_pler_app/core/constants/api_constants.dart';
    import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
    import 'package:pler_to_pler_app/core/services/api_service.dart';
    import 'package:pler_to_pler_app/core/services/cache_service.dart';
    import 'package:pler_to_pler_app/features/nav_bar/presentation/screens/nav_bar.dart';
    import 'package:pler_to_pler_app/features/subscribe/domain/services/subscribe_services.dart';

    const String kPaywallProductMonthly = 'month_1';
    const String kPaywallProductAnnual = 'year_1';
    const Set<String> _kPaywallProductIds = {
    kPaywallProductMonthly,
    kPaywallProductAnnual,
    };

    // ─────────────────────────────────────────────────────────────────────────────
    // PaywallController
    //
    // Handles two purchase paths:
    //   1. Promo path  — any code entered during sign-up (or manually) is sent to
    //                    POST /promo/validate; if accepted, POST /promo/redeem
    //                    grants 30 days free access without touching Apple IAP.
    //   2. Apple IAP   — standard in_app_purchase flow when no promo is active.
    //
    // On onReady() the controller checks Hive for a 'pendingPromoCode' written
    // by SignUpController after registration and auto-applies it.
    // ─────────────────────────────────────────────────────────────────────────────

    class PaywallController extends GetxController {
    final SubscribeServices _subscribeService;
    final ApiService _apiService = ApiService();
    final CacheService _cacheService = CacheService();

    PaywallController({required SubscribeServices subscribeService})
        : _subscribeService = subscribeService;

    StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

    // ── Plan selection ─────────────────────────────────────────────────────────
    final selectedPlan = kPaywallProductMonthly.obs;

    void selectPlan(String planKey) => selectedPlan.value = planKey;

    // ── IAP states ─────────────────────────────────────────────────────────────
    final _iapAvailable = false.obs;
    final _products = <ProductDetails>[].obs;
    final purchaseLoading = false.obs;
    final purchaseError = ''.obs;

    bool get iapAvailable => _iapAvailable.value;
    List<ProductDetails> get products => _products;

    ProductDetails? get selectedProduct {
      for (final p in _products) {
        if (p.id == selectedPlan.value) return p;
      }
      return null;
    }

    // ── Promo code ─────────────────────────────────────────────────────────────
    final appliedPromoCode = ''.obs;
    final promoLoading = false.obs;
    final promoError = ''.obs;

    bool get hasPromo => appliedPromoCode.value.isNotEmpty;

    // ── Lifecycle ──────────────────────────────────────────────────────────────
    @override
    void onReady() {
      super.onReady();
      _initIAP();
      _autoApplyPendingPromo();
    }

    @override
    void onClose() {
      _purchaseSubscription?.cancel();
      super.onClose();
    }

    // ── Promo: auto-apply code stored during sign-up ───────────────────────────
    Future<void> _autoApplyPendingPromo() async {
      final pending = _cacheService.get<String>('pendingPromoCode');
      if (pending != null && pending.isNotEmpty) {
        await applyPromoCode(pending);
      }
    }

    /// Validates [code] with the backend. Any non-empty code is accepted and
    /// grants 30 days free access (50 % off the monthly plan).
    Future<void> applyPromoCode(String code) async {
      final trimmed = code.trim().toUpperCase();
      if (trimmed.isEmpty) return;

      promoLoading.value = true;
      promoError.value = '';

      try {
        await _apiService.post(
          ApiConstants.promoValidate,
          data: {'code': trimmed},
        );
        appliedPromoCode.value = trimmed;
        promoError.value = '';
      } catch (e) {
        promoError.value = 'Code could not be applied. Please try again.';
        appliedPromoCode.value = '';
      } finally {
        promoLoading.value = false;
      }
    }

    void removePromoCode() {
      appliedPromoCode.value = '';
      promoError.value = '';
    }

    // ── Purchase: main CTA ─────────────────────────────────────────────────────
    Future<void> upgradeNow() async {
      if (purchaseLoading.value) return;

      if (hasPromo) {
        await _redeemPromoCode();
      } else {
        await _startIapPurchase();
      }
    }

    // ── Promo redemption (bypasses Apple IAP) ──────────────────────────────────
    Future<void> _redeemPromoCode() async {
      purchaseLoading.value = true;
      purchaseError.value = '';

      try {
        await _apiService.post(
          ApiConstants.promoRedeem,
          data: {'code': appliedPromoCode.value},
        );

        // Clear the stored code so it won't re-apply on next launch
        await _cacheService.delete('pendingPromoCode');
        appliedPromoCode.value = '';

        ToastMessageHelper.show(
            'Your promo has been applied — enjoy 30 days free!');
        Get.offAll(() => NavBar());
      } catch (e) {
        purchaseError.value =
            'Could not apply your promo code. Try purchasing directly below.';
      } finally {
        purchaseLoading.value = false;
      }
    }

    // ── IAP: initialise ────────────────────────────────────────────────────────
    Future<void> _initIAP() async {
      try {
        final available = await InAppPurchase.instance.isAvailable();
        _iapAvailable.value = available;
        if (!available) return;

        _purchaseSubscription ??= InAppPurchase.instance.purchaseStream.listen(
          _onPurchaseUpdate,
          onError: (e) {
            if (kDebugMode) debugPrint('Purchase stream error: $e');
          },
        );

        await _loadProducts();
      } catch (e) {
        if (kDebugMode) debugPrint('_initIAP error: $e');
      }
    }

    Future<void> _loadProducts({int maxAttempts = 3}) async {
      for (var attempt = 1; attempt <= maxAttempts; attempt++) {
        try {
          final response = await InAppPurchase.instance.queryProductDetails(
            _kPaywallProductIds,
          );
          if (response.productDetails.isNotEmpty) {
            _products.value = response.productDetails;
            return;
          }
          if (kDebugMode) {
            debugPrint(
                'No IAP products (attempt $attempt/$maxAttempts). Not found: ${response.notFoundIDs}');
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('_loadProducts attempt $attempt error: $e');
          }
        }
        if (attempt < maxAttempts) {
          await Future<void>.delayed(Duration(milliseconds: 400 * attempt));
        }
      }
    }

    // ── IAP: trigger purchase ──────────────────────────────────────────────────
    Future<void> _startIapPurchase() async {
      final product = selectedProduct;
      if (product == null) {
        purchaseError.value =
            'Store products are loading. Please wait a moment and try again.';
        return;
      }

      purchaseLoading.value = true;
      purchaseError.value = '';

      try {
        final param = PurchaseParam(productDetails: product);
        await InAppPurchase.instance.buyNonConsumable(purchaseParam: param);
        // Result arrives via _onPurchaseUpdate
      } catch (e) {
        purchaseLoading.value = false;
        purchaseError.value = 'Purchase could not be started. Please try again.';
        if (kDebugMode) debugPrint('_startIapPurchase error: $e');
      }
    }

    // ── IAP: handle purchase stream ────────────────────────────────────────────
    Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
      for (final purchase in purchases) {
        switch (purchase.status) {
          case PurchaseStatus.purchased:
          case PurchaseStatus.restored:
            await _verifyAndGrant(purchase);
          case PurchaseStatus.error:
            purchaseLoading.value = false;
            purchaseError.value =
                purchase.error?.message ?? 'Purchase failed. Please try again.';
          case PurchaseStatus.canceled:
            purchaseLoading.value = false;
          case PurchaseStatus.pending:
            break;
        }

        if (purchase.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchase);
        }
      }
    }

    // ── IAP: verify receipt with backend → grant access ────────────────────────
    Future<void> _verifyAndGrant(PurchaseDetails purchase) async {
      try {
        final verificationData =
            purchase.verificationData.serverVerificationData;
        final platform = Platform.isIOS ? 'apple_iap' : 'google_play';

        final result = await _subscribeService.verifyIap(
          platform: platform,
          productId: purchase.productID,
          purchaseId: purchase.purchaseID ?? '',
          verificationData: verificationData,
        );

        purchaseLoading.value = false;

        if (result.isSubscribed) {
          ToastMessageHelper.show('Welcome! Your subscription is now active.');
          Get.offAll(() => NavBar());
        } else {
          purchaseError.value =
              'Purchase processed but subscription could not be activated. Please contact support.';
        }
      } catch (e) {
        purchaseLoading.value = false;
        purchaseError.value = 'Verification failed. Please restart the app.';
        if (kDebugMode) debugPrint('_verifyAndGrant error: $e');
      }
    }
    }
    