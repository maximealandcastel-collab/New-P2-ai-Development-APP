/// Store-owned prices/offers are queried at runtime. Never calculate a trial
/// or discount locally. Legacy IDs are restore-only, not offered for new sales.
abstract final class StoreSubscriptionProducts {
  static const standardQuarterly = 'p2p_standard_3m';
  static const standardAnnual = 'p2p_standard_annual';
  static const proQuarterly = 'p2p_pro_3m';
  static const proAnnual = 'p2p_pro_annual';

  static const offered = {
    standardQuarterly, standardAnnual, proQuarterly, proAnnual,
  };
  static const restorable = {...offered, 'month_1', 'year_1'};

  static bool handles(String productId, {String? promotionalProductId}) =>
      restorable.contains(productId) ||
      (promotionalProductId != null &&
          promotionalProductId.isNotEmpty &&
          productId == promotionalProductId);
}
