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

const String kProductStandard3m = 'p2p_standard_3m';
const String kProductStandardAnnual = 'p2p_standard_annual';
const String kProductPro3m = 'p2p_pro_3m';
const String kProductProAnnual = 'p2p_pro_annual';

// Aliases for standard user flow
const String kProductMonthly = kProductStandard3m;
const String kProductAnnual = kProductStandardAnnual;

const Set<String> _kProductIds = {
  kProductStandard3m,
  kProductStandardAnnual,
  kProductPro3m,
  kProductProAnnual,
};

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

      // Listen early — unfinished store transactions can block product queries.
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

  /// Pull-to-refresh entry point.
  Future<void> refreshProducts() => _loadProducts();

  /// StoreKit / Play Billing often return empty on the first query (store not
  /// ready yet). Retry with short backoff before surfacing an error.
  Future<void> _loadProducts({int maxAttempts = 3}) async {
    if (!_iapAvailable.value) {
      final available = await InAppPurchase.instance.isAvailable();
      _iapAvailable.value = available;
      if (!available) {
        _iapLoadingState.value = LoadingState.error;
        return;
      }
    }

    _iapLoadingState.value = LoadingState.loading;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await InAppPurchase.instance.queryProductDetails(
          _kProductIds,
        );

        if (response.notFoundIDs.isNotEmpty && kDebugMode) {
          debugPrint(
            'IAP products not found (attempt $attempt): ${response.notFoundIDs}',
          );
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
          return;
        }

        if (kDebugMode) {
          debugPrint('No IAP products loaded (attempt $attempt/$maxAttempts).');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('_loadProducts error (attempt $attempt/$maxAttempts): $e');
        }
      }

      if (attempt < maxAttempts) {
        await Future<void>.delayed(Duration(milliseconds: 400 * attempt));
      }
    }

    _products.clear();
    _iapLoadingState.value = LoadingState.error;
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
      // Do not toast-spam: UI already shows error + pull-to-refresh.
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
      final started = await InAppPurchase.instance.buyNonConsumable(purchaseParam: param);
      if (!started) throw UnknownException('The store did not start the purchase.');
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

  /// Purchase IDs already sent to /iap/verify in this session.
  ///
  /// StoreKit replays unfinished transactions on every launch and to every new
  /// stream listener, so without this the same purchase is verified repeatedly.
  /// The backend should also treat purchaseId as an idempotency key — this
  /// guard only covers the client side.
  final Set<String> _verifyingPurchaseIds = <String>{};
  final Set<String> _verifiedPurchaseIds = <String>{};

  /// Asks the store to re-deliver past purchases.
  ///
  /// App Store Review Guideline 3.1.1 requires a restore mechanism for
  /// auto-renewable subscriptions; the app previously had none anywhere, which
  /// also stranded anyone who reinstalled or changed device. Restored purchases
  /// arrive through the same purchaseStream as new ones.
  Future<void> restorePurchases() async {
    try {
      _purchaseLoadingState.value = LoadingState.loading;
      await InAppPurchase.instance.restorePurchases();
      _purchaseLoadingState.value = LoadingState.initial;
      ToastMessageHelper.show(
        'Checking for previous purchases…',
      );
    } catch (e) {
      _purchaseLoadingState.value = LoadingState.error;
      ToastMessageHelper.show('Could not restore purchases. Please try again.');
      if (kDebugMode) debugPrint('restorePurchases error: $e');
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

      if (_verifiedPurchaseIds.contains(purchaseId)) {
        if (purchase.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchase);
        }
        return;
      }
      if (!_verifyingPurchaseIds.add(purchaseId)) return;

      // Unlock only after backend verifies with Apple / Google.
      final entitlement = await _subscribeService.verifyIap(
        platform: Platform.isIOS ? 'ios' : 'android',
        productId: purchase.productID,
        purchaseId: purchaseId,
        verificationData: verificationData,
      );

      if (!entitlement.isActiveAt(DateTime.now())) {
        throw UnknownException('No active subscription was verified.');
      }

      _verifiedPurchaseIds.add(purchaseId);
      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }

      try {
        await _profileService.fetchUserProfile();
      } catch (_) {
        // Navigation still proceeds; profile refresh is best-effort.
      }

      _verifyingPurchaseIds.remove(purchaseId);
      _purchaseLoadingState.value = LoadingState.loaded;
      ToastMessageHelper.show('Subscription activated! Enjoy your plan 🎉');
      if (kDebugMode) {
        debugPrint('Purchase verified: ${purchase.productID}');
      }

      if (Get.isRegistered<PaymentDetailsController>()) {
        Get.delete<PaymentDetailsController>();
      }
      Get.offAllNamed(AppRoute.trainerMatchScreen);
    } on AppException catch (e) {
      // Drop the id so a retry (or the store's next replay) can verify again.
      _verifiedPurchaseIds.remove(purchase.purchaseID);
      _verifyingPurchaseIds.remove(purchase.purchaseID);
      _purchaseLoadingState.value = LoadingState.error;
      ToastMessageHelper.show(e.message);
      if (kDebugMode) debugPrint('_handleSuccessfulPurchase error: $e');
    } catch (e) {
      _verifiedPurchaseIds.remove(purchase.purchaseID);
      _verifyingPurchaseIds.remove(purchase.purchaseID);
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
