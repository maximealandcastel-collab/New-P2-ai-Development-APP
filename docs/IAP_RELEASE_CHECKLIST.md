# Native app subscriptions — release checklist

This branch uses Flutter `in_app_purchase` directly with Apple/Google verification.
It does not migrate billing providers or change web Clover checkout.

## Catalog

| Product ID | Billing period | Server access |
| --- | --- | --- |
| `p2p_standard_3m` | 3 months | paid |
| `p2p_standard_annual` | 1 year | paid |
| `p2p_pro_3m` | 3 months | premium |
| `p2p_pro_annual` | 1 year | premium |

`month_1` and `year_1` remain supported for existing customers restoring purchases.
Do not create duplicate subscriptions to work around missing products. Confirm
the exact catalog in App Store Connect and Play Console. Store products determine
localized prices and eligible introductory offers; no price or free trial is
created by this code. The existing `monthly` UI selection key means **3 months**.

## Implemented flow

- Both consumer purchase controllers share a product catalog and ignore gym
  transactions. The paywall may additionally handle a server-mapped promo product.
- Both user and trainer accounts may call authenticated `POST /api/v1/iap/verify`.
- Signup stores purchase proof until OTP establishes identity. Both roles attempt
  activation; proof is retained across restart until a store transaction is finished.
- Unlock requires an active, unexpired server response matching the purchased product.
- Server validates purchases with Apple/Google; client receipts never grant access alone.
- Restore rechecks store state. Failed verification leaves transactions unfinished
  for retry; successful store completion happens before leaving the paywall.

## Required before launch — not confirmed by a code commit

1. Confirm store products, subscription grouping, prices, tax/banking agreements,
   review metadata, and introductory offer eligibility.
2. Configure backend Apple issuer/key/private key and Google Play service account
   through deployment secrets. Signing CI credentials do not configure the backend.
3. Deploy the backend changes from this branch separately from the Flutter binary.
   Pushing Flutter to Codemagic does **not** deploy the Node backend.
4. Use a separate sandbox backend for TestFlight. Existing production verification
   rejects Apple Sandbox transactions and Google test purchases. Do not disable
   that protection globally to test purchases against live customer accounts.
5. Complete authenticated renewal/refund notification processing and reconciliation
   for consumer subscriptions before claiming automatic lifecycle handling. Initial
   verification/restore alone does not provide prompt refund or renewal updates.
6. On a real sandbox device test both tiers and periods; canceled/failed/pending
   purchases; signup + OTP for both roles; restart before OTP; restore after reinstall;
   a purchase already linked to another account; expiry and refund. Verify server
   profile expiry and access after relaunch, not just a success banner.
7. Run Flutter analysis/tests and a signed iOS build on the configured Mac runner.
   Linux source checks are not proof of StoreKit or TestFlight success.

## Checks

The Node suite requires Node 24 (native TypeScript support) and the backend's
development dependencies, including TypeScript. Flutter checks require the
project's Flutter SDK.

```
node --test scripts/tests/app_subscription.test.mjs
flutter test test/features/subscribe/iap_entitlement_test.dart \
  test/features/subscribe/store_subscription_products_test.dart
flutter analyze
```

`codemagic.yaml` currently watches pushes to `elijah-stabilization`. A local
commit does not trigger it; a push does. Do not change its trigger for this work.
