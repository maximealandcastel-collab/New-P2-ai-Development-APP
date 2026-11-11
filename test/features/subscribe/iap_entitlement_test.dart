import 'package:flutter_test/flutter_test.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/iap_verify_result_model.dart';

void main() {
  final now = DateTime.utc(2026, 9, 15);
  Map<String, dynamic> response({String? status = 'active', bool subscribed = true, String? end = '2026-10-01T00:00:00Z'}) => {
    'success': true, 'data': {'isSubscribed': subscribed, 'status': status, 'subscriptionEndDate': end},
  };
  test('only explicit active and unexpired verified entitlement grants access', () {
    expect(IapVerifyResultModel.responseGrantsAccess(response(), now: now), isTrue);
    for (final status in [null, 'pending', 'expired', 'refunded', 'revoked', 'unknown']) {
      expect(IapVerifyResultModel.responseGrantsAccess(response(status: status), now: now), isFalse);
    }
    expect(IapVerifyResultModel.responseGrantsAccess(response(subscribed: false), now: now), isFalse);
    for (final end in [null, 'invalid', '2026-09-15T00:00:00Z', '2025-01-01']) {
      expect(IapVerifyResultModel.responseGrantsAccess(response(end: end), now: now), isFalse);
    }
    expect(IapVerifyResultModel.responseGrantsAccess({'success': true}, now: now), isFalse);
    expect(IapVerifyResultModel.responseGrantsAccess({...response(), 'success': false}, now: now), isFalse);
  });
  test('a verified response must match the purchased product', () {
    final body = response();
    (body['data'] as Map)['productId'] = 'p2p_standard_3m';
    expect(IapVerifyResultModel.responseGrantsAccess(
      body, now: now, expectedProductId: 'p2p_standard_3m',
    ), isTrue);
    expect(IapVerifyResultModel.responseGrantsAccess(
      body, now: now, expectedProductId: 'p2p_pro_annual',
    ), isFalse);
    (body['data'] as Map).remove('productId');
    expect(IapVerifyResultModel.responseGrantsAccess(
      body, now: now, expectedProductId: 'p2p_standard_3m',
    ), isFalse);
  });
}
