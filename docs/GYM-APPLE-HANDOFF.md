# Claim Your Gym — Apple subscriptions

## App Store Connect products to create
Create an auto-renewable subscription group named **P2P Gym License** with these monthly products:

| Product ID (exact) | Display name | Intended US price |
| --- | --- | --- |
| p2p_gym_starter_monthly | P2P Gym Starter | $49.99/month |
| p2p_gym_pro_monthly | P2P Gym Pro | $305.99/month |

Choose available Apple price points and localized pricing in App Store Connect; the app displays Apple's returned price, never a hardcoded checkout price. Configure Pro above Starter in subscription level order, complete metadata/localizations/review screenshots, and submit with the app. Products have NOT been created in your Apple account by this code change.

## Implemented
- Removed app-to-Clover redirects from gym application submission and renewal. Website Clover implementation is unchanged.
- Submission records a pending application without charging. After an administrator verifies gym ownership, My Applications opens an Apple subscription screen.
- Uses StoreKit purchase/restore, localized product price, monthly renewal disclosure and existing terms/privacy screens. Non-iOS cannot open a web-payment fallback.
- Backend provides an opaque per-claim appAccountToken, verifies the transaction with Apple's authenticated server API, requires the correct product, unexpired transaction, matching token, current verified owner and subscription-chain binding. Unique indexes prevent a subscription chain from funding multiple claims. Payment does not bypass administrative approval.
- Native purchases are completed only after server verification. Personal-subscription listeners ignore gym product events.
- Protected enterprise access rechecks saved Apple transactions for revocation/expiry; store outages fail closed. This adds an Apple network lookup to those access paths.

## Server setup
Existing Apple keys: APPLE_IAP_ISSUER_ID, APPLE_IAP_KEY_ID, APPLE_IAP_PRIVATE_KEY, APPLE_IAP_BUNDLE_ID. Bundle ID defaults to com.p2pfittech.ai. Native StoreKit 2 must remain enabled (the installed plugin passes applicationUserName as appAccountToken). Build and deploy backend plus Flutter app together. Ensure the new unique sparse claim indexes are created before enabling purchases.

## Tests and remaining validation
Four focused policy tests cover product IDs, matching binding, mismatched tier/account/chain/expired rejection, and removal of external checkout. Backend typecheck and targeted Flutter analysis also run. These are not live Apple purchases.
Required before release: create/submit products; test purchase, cancel, pending approval, restore, reinstall, renewal, refund, expiration, account switching and wrong-gym restore in Apple's sandbox against a staging backend. Existing verifier deliberately rejects sandbox transactions for production entitlements. App Store Server Notifications V2/automatic renewal reconciliation is not implemented here: renewed transactions must be restored/reverified to advance saved expiry. Access fails closed on expired/revoked saved transactions. This limitation must be resolved/verified before declaring a seamless subscription release.
Existing severe-audit release blockers are unchanged. App Review approval is not guaranteed by removing Clover.

Apple guidance: https://developer.apple.com/app-store/review/guidelines/#in-app-purchase
