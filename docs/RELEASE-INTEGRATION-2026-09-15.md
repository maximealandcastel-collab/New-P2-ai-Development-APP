# Payment and enterprise integration — local implementation

## Delivery status

These changes follow local commit `1e71a9b` and have not been pushed or deployed. They are not a declaration that the twelve-area production audit is complete. The Git checkout is a partial backend export; full-server validation used the downloaded Replit source plus the local changes.

## Implemented in this update

- Clover checkout persists an attempt before charging, uses a stable UUID idempotency key, binds retries to email/plan/application, takes prices from the server catalog, and keeps failed backend delivery retryable.
- Direct Ecommerce REST webhook authentication checks `X-Clover-Auth`, merchant and app identity. Webhooks trigger authenticated provider reads; event payloads cannot supply entitlement amounts. Refund state is monotonic and duplicate delivery does not duplicate access. Hosted Checkout HMAC utility is tested but is NOT a registered Hosted Checkout endpoint.
- A background reconciliation loop runs every minute; an authenticated `/api/clover/reconcile` endpoint supports operational recovery. Failed rows move behind other rows to avoid starving the queue.
- `/api/clover/migrate-legacy` re-verifies up to 100 legacy consumer charges per call before importing them. Enterprise legacy payments require manual claim association and are intentionally excluded.
- Web purchase delivery is idempotent in Mongo and bound to purchaser email. Redemption uses a transaction, exact paid expiry, and rejects refunded purchases. Founder promo bypass requires a current global administrator; it does not promote accounts.
- Gym applications stay pending until a verified owner account, recorded ownership review, current verified license payment, and global-admin approval exist. Approval creates a tenant and facility transactionally and adds only tenant-scoped authority. Refund/revoke disables access.
- Facility endpoints authorize current membership. Inventory updates require scoped admin access. Workout creation and split/program context load current inventory server-side; the mobile flow can select an authorized facility.
- Withdrawal creation serializes balance checks per trainer in a transaction. Amounts must be positive integer cents. Administrative state changes are conditional updates; recording payment requires approval and a payout reference. Financial-provider transfers are not performed by this code.
- Account deletion replaces the personal user document, deletes configured personal-data collections, disables the trainer profile, removes OTPs, and prevents future authentication. Financial records remain. External media is recorded in `AccountDeletionCleanup` for storage cleanup; **a remote-storage cleanup worker is still required**. The UI no longer promises all remote data is immediately erased.
- Release configuration rejects divergent client origins and development hosts; Codemagic pins Flutter 3.41.4 and emits a commit/origin/build manifest.

## Required deployment configuration

API-server: `CLOVER_API_KEY`, `CLOVER_MERCHANT_ID`, `CLOVER_PUBLISHABLE_KEY`, `CLOVER_APP_ID`, `CLOVER_WEBHOOK_AUTH`, `CLOVER_ENV`, `APP_BACKEND_URL`, `APP_BACKEND_SHARED_SECRET`, `DATABASE_URL`.

P2P backend: `SESSION_SECRET`, `APP_BACKEND_SHARED_SECRET`, and a replica-set Mongo connection (`MONGO_URI`/`MONGO_URL`). Existing native-store and Firebase configuration is still required.

Use different databases, keys, and backend URLs for sandbox and production. Production rejects sandbox payment deliveries. Clover environment is determined by the configured provider endpoint; a contradictory `livemode:false` response is rejected. Clover charge creation timestamps are milliseconds, as documented by Clover.

Do not expose secret values in logs or handoffs. Ensure `/api/v1/enterprise/*` reaches the P2P backend and `/api/clover/*` reaches API-server. Confirm the actual production routing: both services have V1 routes. Verify the website checkout domain and API origin before deployment.

## Founder/gym endpoints (P2P authentication)

- `POST /api/v1/enterprise/gym-applications`: public pending intake.
- `GET /api/v1/enterprise/admin/gym-applications`: global P2P administrator.
- `POST .../admin/gym-applications/:id/verify-ownership`: `{ownerUserId,evidence}`; matching verified owner email is required.
- `POST .../admin/gym-applications/:id/approve`.
- `POST .../admin/gym-applications/:id/reject` and `/revoke`: `{reason}`.
- `GET /api/v1/enterprise/facilities`.
- `GET /api/v1/enterprise/facilities/:id/inventory`.
- `PUT /api/v1/enterprise/facilities/:id/inventory`: `{equipment:[...]}`; scoped administrator only.

Use P2P JWTs for these endpoints, not the SQL API-server Founder Console token. Existing website Founder Console controls are not automatically wired to these new P2P endpoints; that UI integration remains to be done. The legacy SQL gym-owner approval route remains separate from Mongo claim provisioning and must not be represented as the same workflow.

## Test evidence

- Full P2P backend TypeScript compilation passed against the downloaded complete source with local overlays.
- Clover module and database adapter type-check passed; a complete API-server monorepo build is still required because workspace packages were not included in the source snapshot.
- 27 Node policy/helper tests passed.
- 3 real ephemeral Mongo replica-set integration tests passed: provisioning/refund/replay/tenant access, purchaser binding/idempotency/environment rejection, and personal-data deletion/session revocation.
- 2 embedded PostgreSQL integration tests with simulated Clover/backend transport passed: duplicate payment/refund and backend-delivery recovery. These do not prove a real Clover charge or production concurrency behavior.
- 90 existing Flutter tests passed, 4 skipped; 2 additional release-origin/entitlement tests passed separately.
- Flutter analysis found no errors (548 warnings/info).
- 2 Python release-configuration tests passed.

No real charges, production account deletions, real notifications, or deployments were performed.

## Remaining release blockers

1. Real Clover setup and end-to-end test payments/refunds; webhook permission/subscription configuration; verified production migration and backups; concurrent withdrawal tests against production-equivalent databases; chargeback handling and affiliate settlement reconciliation.
2. Complete Founder Console UI integration and broader tenant/staff/member onboarding/module coverage; verify real owner/member roles across both services. Expired tenants deny new facility access; production renewal/reapproval policy still needs end-to-end validation.
3. Apple/Google renewal/refund server-notification lifecycle, account/device restoration tests, and a safe TestFlight sandbox arrangement. Current native verification edits alone do not complete this lifecycle.
4. Storage deletion worker, published retention-policy alignment, external processors, backups, and database collection-coverage review. Retained financial/audit records may contain personal information; this is not proof of complete privacy compliance.
5. Physical-device FCM/APNs configuration, token/logout races and notification destinations; trainer/customer messaging and plan delivery verification.
6. Production media durability, range requests, Mux inventory and migration verification.
7. Permanent deployment routing, secrets availability, restarts/autoscaling, and the exact signed TestFlight build/reviewer journeys.

## Provider references

- Clover direct-charge idempotency: https://docs.clover.com/dev/docs/using-the-clover-hosted-iframe
- REST webhook authentication and payload: https://docs.clover.com/dev/docs/webhooks
- Charge verification endpoint: https://docs.clover.com/dev/reference/getchargescharge
- Millisecond charge timestamps: https://docs.clover.com/dev/docs/get-charges
- Hosted Checkout signatures (different webhook protocol): https://docs.clover.com/dev/docs/ecomm-hosted-checkout-webhook
