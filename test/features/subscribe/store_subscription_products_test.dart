import 'package:flutter_test/flutter_test.dart';
import 'package:pler_to_pler_app/features/subscribe/domain/store_subscription_products.dart';

void main() {
  test('the four Standard/Pro products are offered for sale', () {
    expect(StoreSubscriptionProducts.offered, {
      'p2p_standard_3m', 'p2p_standard_annual',
      'p2p_pro_3m', 'p2p_pro_annual',
    });
  });
  test('legacy subscriptions can restore but are not offered for new sales', () {
    for (final id in ['month_1', 'year_1']) {
      expect(StoreSubscriptionProducts.handles(id), isTrue);
      expect(StoreSubscriptionProducts.offered.contains(id), isFalse);
    }
  });
  test('consumer listeners ignore gym and unknown purchases', () {
    for (final id in ['p2p_gym_starter_monthly', 'p2p_gym_pro_monthly', '', 'unknown']) {
      expect(StoreSubscriptionProducts.handles(id), isFalse);
    }
    expect(StoreSubscriptionProducts.handles(
      'special_product', promotionalProductId: 'special_product',
    ), isTrue);
    expect(StoreSubscriptionProducts.handles(
      'other_product', promotionalProductId: 'special_product',
    ), isFalse);
  });
}
