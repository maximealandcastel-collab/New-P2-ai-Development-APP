import 'package:get/get.dart';

/// Tracks whether the affiliate (partner) promo code has been activated.
/// Registered on first successful promo code entry; persists until app restart.
class AffiliateModeService extends GetxController {
  static AffiliateModeService get to => Get.find();

  final _isAffiliate = false.obs;
  bool get isAffiliate => _isAffiliate.value;

  String _activeCode = '';
  String get activeCode => _activeCode;

  void activate(String promoCode) {
    _activeCode = promoCode.toUpperCase();
    _isAffiliate.value = true;
  }
}
