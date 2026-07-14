import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';

const String kProductMonthly = 'month_1';
const String kProductAnnual = 'year_1';
const Set<String> _kProductIds = {kProductMonthly, kProductAnnual};

class PaymentDetailsController extends GetxController {
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  // ─── IAP States ───────────────────────────────────────────────────────────
  final _iapAvailable = false.obs;
  final _products = <ProductDetails>[].obs;
  final _isPurchasing = false.obs;
  final _iapLoadingState = LoadingState.initial.obs;
  final RxInt _selectedIndex = 0.obs;

  bool get iapAvailable => _iapAvailable.value;
  List<ProductDetails> get products => _products;
  bool get isPurchasing => _isPurchasing.value;
  LoadingState get iapLoadingState => _iapLoadingState.value;
  int get selectedIndex => _selectedIndex.value;

  /// Returns the `ProductDetails` for the currently selected plan index.
  /// index 0 → annual, index 1 → monthly
  ProductDetails? get selectedProduct {
    final targetId = selectedIndex == 0 ? kProductAnnual : kProductMonthly;
    try {
      return _products.firstWhere((p) => p.id == targetId);
    } catch (_) {
      return null;
    }
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
      _purchaseSubscription = InAppPurchase.instance.purchaseStream.listen(
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

  Future<void> _loadProducts() async {
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
        _iapLoadingState.value = LoadingState.loaded;
      } else {
        _iapLoadingState.value = LoadingState.error;
        if (kDebugMode) debugPrint('No IAP products loaded.');
      }
    } catch (e) {
      _iapLoadingState.value = LoadingState.error;
      if (kDebugMode) debugPrint('_loadProducts error: $e');
    }
  }

  // ─── IAP: Buy ─────────────────────────────────────────────────────────────
  /// Call this from the "Upgrade Now" button.
  Future<void> buySelectedPlan() async {
    if (_isPurchasing.value) return;

    final product = selectedProduct;
    if (product == null) {
      ToastMessageHelper.show('Product not available. Please try again.');
      return;
    }

    try {
      _isPurchasing.value = true;
      final param = PurchaseParam(productDetails: product);

      // Both plans are non-consumable subscriptions
      await InAppPurchase.instance.buyNonConsumable(purchaseParam: param);
    } catch (e) {
      _isPurchasing.value = false;
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
          await _handleSuccessfulPurchase(purchase);
          break;

        case PurchaseStatus.error:
          _isPurchasing.value = false;
          final errMsg =
              purchase.error?.message ?? 'Purchase failed. Please try again.';
          ToastMessageHelper.show(errMsg);
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
          _isPurchasing.value = false;
          if (kDebugMode) debugPrint('Purchase cancelled: ${purchase.productID}');
          break;
      }
    }
  }

  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchase) async {
    try {
      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }

      _isPurchasing.value = false;
      ToastMessageHelper.show('Subscription activated! Enjoy your plan 🎉');
      if (kDebugMode) {
        debugPrint('Purchase complete: ${purchase.productID}');
      }

      // Navigate away after successful purchase
      Get.offAllNamed(AppRoute.bottonNavBar);
    } catch (e) {
      _isPurchasing.value = false;
      ToastMessageHelper.show('Verification failed. Please contact support.');
      if (kDebugMode) debugPrint('_handleSuccessfulPurchase error: $e');
    }
  }

  @override
  void onClose() {
    _purchaseSubscription?.cancel();
    super.onClose();
  }
}
