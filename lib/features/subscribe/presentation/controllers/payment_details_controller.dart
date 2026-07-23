import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/profile/domain/services/profile_service.dart';
import 'package:pler_to_pler_app/features/subscribe/domain/services/subscribe_services.dart';

const String kProductMonthly = 'month_1';
const String kProductAnnual = 'year_1';
const Set<String> _kProductIds = {kProductMonthly, kProductAnnual};

class PaymentDetailsController extends GetxController {
  PaymentDetailsController({
    required SubscribeServices subscribeService,
    required ProfileService profileService,
  }) : _subscribeService = subscribeService,
       _profileService = profileService;

  final SubscribeServices _subscribeService;
  final ProfileService _profileService;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  String? _lastPurchaseErrorToast;

  // ─── IAP States ───────────────────────────────────────────────────────────
  final _iapAvailable = false.obs;
  final _products = <ProductDetails>[].obs;
  final RxInt _selectedIndex = 0.obs;

  final Rx<LoadingState> _iapLoadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _purchaseLoadingState = LoadingState.initial.obs;

  bool get iapAvailable => _iapAvailable.value;

  RxList<ProductDetails> get products => _products;

  LoadingState get iapLoadingState => _iapLoadingState.value;

  LoadingState get purchaseLoadingState => _purchaseLoadingState.value;

  int get selectedIndex => _selectedIndex.value;

  bool get canPurchase =>
      !_purchaseLoadingState.value.isLoading &&
      !_iapLoadingState.value.isLoading &&
      selectedProduct != null;

  /// Returns the `ProductDetails` for the currently selected plan index.
  /// index 0 → annual, index 1 → monthly
  ProductDetails? get selectedProduct {
    final targetId = selectedIndex == 0 ? kProductAnnual : kProductMonthly;
    for (final product in _products) {
      if (product.id == targetId) return product;
    }
    return null;
  }

  void onChange(int index) {
    _selectedIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    _initIAP();
  }

  // ─── IAP: Initialise ─────────────────────────────────────────────────────
  Future<void> _initIAP() async {
    _iapLoadingState.value = LoadingState.loading;
    try {
      final available = await InAppPurchase.instance.isAvailable();
      _iapAvailable.value = available;

      if (!available) {
        _iapLoadingState.value = LoadingState.error;
        if (kDebugMode) debugPrint('IAP not available on this device.');
        return;
      }

      // Listen to purchase updates
      _purchaseSubscription ??= InAppPurchase.instance.purchaseStream.listen(
        _onPurchaseUpdate,
        onError: (e) {
          if (kDebugMode) debugPrint('Purchase stream error: $e');
        },
      );

      await _loadProducts();
    } catch (e) {
      _iapLoadingState.value = LoadingState.error;
      if (kDebugMode) debugPrint('_initIAP error: $e');
    }
  }

  Future<void> retryLoadProducts() => _loadProducts();

  Future<void> _loadProducts() async {
    if (!_iapAvailable.value) {
      final available = await InAppPurchase.instance.isAvailable();
      _iapAvailable.value = available;
      if (!available) {
        _iapLoadingState.value = LoadingState.error;
        return;
      }
    }

    _iapLoadingState.value = LoadingState.loading;
    try {
      final response = await InAppPurchase.instance.queryProductDetails(
        _kProductIds,
      );

      if (response.notFoundIDs.isNotEmpty && kDebugMode) {
        debugPrint('IAP products not found: ${response.notFoundIDs}');
      }

      if (response.productDetails.isNotEmpty) {
        // Sort: annual first, monthly second – matches selectedIndex convention
        final sorted = response.productDetails.toList()
          ..sort((a, b) {
            if (a.id == kProductAnnual) return -1;
            if (b.id == kProductAnnual) return 1;
            return 0;
          });
        _products.value = sorted;
        _syncSelectedIndexToAvailableProduct();
        _iapLoadingState.value = LoadingState.loaded;
      } else {
        _products.clear();
        _iapLoadingState.value = LoadingState.error;
        if (kDebugMode) debugPrint('No IAP products loaded.');
      }
    } catch (e) {
      _iapLoadingState.value = LoadingState.error;
      if (kDebugMode) debugPrint('_loadProducts error: $e');
    }
  }

  void _syncSelectedIndexToAvailableProduct() {
    if (selectedProduct != null) return;

    final hasAnnual = _products.any((p) => p.id == kProductAnnual);
    final hasMonthly = _products.any((p) => p.id == kProductMonthly);

    if (hasAnnual) {
      _selectedIndex.value = 0;
    } else if (hasMonthly) {
      _selectedIndex.value = 1;
    }
  }

  // ─── IAP: Buy ─────────────────────────────────────────────────────────────
  /// Call this from the "Upgrade Now" button.
  Future<void> buySelectedPlan() async {
    if (_purchaseLoadingState.value.isLoading) return;

    if (_iapLoadingState.value.isLoading) {
      return;
    }

    var product = selectedProduct;
    if (product == null) {
      // First query can fail (StoreKit not ready) — retry silently once.
      await _loadProducts();
      product = selectedProduct;
    }

    if (product == null) {
      // Do not toast-spam: UI already shows error + retry.
      if (kDebugMode) {
        debugPrint(
          'buySelectedPlan: product unavailable '
          '(iapAvailable=$_iapAvailable, products=${_products.length})',
        );
      }
      return;
    }

    try {
      _purchaseLoadingState.value = LoadingState.loading;
      final param = PurchaseParam(productDetails: product);

      // Auto-renewable subscriptions use buyNonConsumable on both stores.
      await InAppPurchase.instance.buyNonConsumable(purchaseParam: param);
    } catch (e) {
      _purchaseLoadingState.value = LoadingState.error;
      ToastMessageHelper.show('Purchase failed. Please try again.');
      if (kDebugMode) debugPrint('buySelectedPlan error: $e');
    }
  }

  // ─── IAP: Purchase Stream Handler ─────────────────────────────────────────
  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          if (kDebugMode) debugPrint('Purchase pending: ${purchase.productID}');
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _lastPurchaseErrorToast = null;
          await _handleSuccessfulPurchase(purchase);
          break;

        case PurchaseStatus.error:
          _purchaseLoadingState.value = LoadingState.error;
          final errMsg =
              purchase.error?.message ?? 'Purchase failed. Please try again.';
          // Unfinished store transactions can re-emit on every listen —
          // only toast each distinct error once per session.
          if (_lastPurchaseErrorToast != errMsg) {
            _lastPurchaseErrorToast = errMsg;
            ToastMessageHelper.show(errMsg);
          }
          if (kDebugMode) {
            debugPrint(
              'Purchase error [${purchase.productID}]: ${purchase.error}',
            );
          }
          if (purchase.pendingCompletePurchase) {
            await InAppPurchase.instance.completePurchase(purchase);
          }
          break;

        case PurchaseStatus.canceled:
          _purchaseLoadingState.value = LoadingState.initial;
          if (kDebugMode) {
            debugPrint('Purchase cancelled: ${purchase.productID}');
          }
          break;
      }
    }
  }

  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchase) async {
    try {
      final purchaseId = purchase.purchaseID;
      final verificationData = purchase.verificationData.serverVerificationData;

      if (purchaseId == null ||
          purchaseId.isEmpty ||
          verificationData.isEmpty) {
        throw UnknownException('Missing purchase verification data');
      }

      // Unlock only after backend verifies with Apple / Google.
      await _subscribeService.verifyIap(
        platform: Platform.isIOS ? 'ios' : 'android',
        productId: purchase.productID,
        purchaseId: purchaseId,
        verificationData: verificationData,
      );

      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }

      try {
        await _profileService.fetchUserProfile();
      } catch (_) {
        // Navigation still proceeds; profile refresh is best-effort.
      }

      _purchaseLoadingState.value = LoadingState.loaded;
      ToastMessageHelper.show('Subscription activated! Enjoy your plan 🎉');
      if (kDebugMode) {
        debugPrint('Purchase verified: ${purchase.productID}');
      }

      if (Get.isRegistered<PaymentDetailsController>()) {
        Get.delete<PaymentDetailsController>();
      }
      Get.offAllNamed(AppRoute.bottonNavBar);
    } on AppException catch (e) {
      _purchaseLoadingState.value = LoadingState.error;
      ToastMessageHelper.show(e.message);
      if (kDebugMode) debugPrint('_handleSuccessfulPurchase error: $e');
    } catch (e) {
      _purchaseLoadingState.value = LoadingState.error;
      ToastMessageHelper.show('Verification failed. Please contact support.');
      if (kDebugMode) debugPrint('_handleSuccessfulPurchase error: $e');
    }
  }

  @override
  void onClose() {
    _purchaseSubscription?.cancel();
    _purchaseSubscription = null;
    super.onClose();
  }
}
