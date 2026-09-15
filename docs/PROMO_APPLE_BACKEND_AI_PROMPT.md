# Promo Code + Apple IAP Backend — AI Prompt (Copy & Paste for Replit)

> **How to use:** copy the whole ` ``` ` block below into your Replit AI session that has the **real** backend repo open. It already has your User/Trainer/Subscription models and the existing `/promo` and `/iap` routes — paste this with that context.

This fixes the live security holes in the current promo-code system, wires promo codes to real Apple purchases so the discount Apple charges is the actual approved price (not just a number shown in the app), stops reusing the admin-bypass secret for an unrelated internal call, and makes redemption resilient to a mid-write crash.

---

## COPY FROM HERE ↓

```
Harden and finish the promo-code + Apple IAP integration for "P2P Fit Tech AI".

## Context
- iOS bundle id: com.p2pfittech.ai
- API prefix: /api/v1
- Existing routes: POST /api/v1/promo/validate (public), POST /api/v1/promo/redeem (auth), POST /api/v1/iap/verify (auth)
- Existing files: src/modules/promoCode/promoCode.service.ts, promoCode.route.ts (scan for promoCode.model.ts / promoCode.interface.ts / promoCode.controller.ts — if any are missing, create them following this project's existing module pattern, e.g. workoutGoal or subscription modules)
- The mobile app already calls /promo/validate before checkout, /iap/verify after an Apple purchase, and /promo/redeem to consume the code. Do not change these three route paths or the mobile app breaks.

## PART 1 — FIX TWO CRITICAL VULNERABILITIES (do this first, before anything else)

### 1a. Remove the "universal promo" any-code-accepted fallback
Current behavior: if a promo code is not found in the database, it is silently treated as valid and grants 30 days of free access (`UNIVERSAL_PROMO_ENABLED` defaults to true). This means any random string a user types is accepted as a working promo code — it is an open door to free subscriptions, not a promo system.

Fix: an unrecognized code must always be rejected with "Invalid promo code". Delete the universal-fallback branch entirely (both in validate and redeem). Do not gate it behind an env flag that defaults on — remove the feature. If there is a genuine business need for a generic "any code gives a discount" mode, it must default OFF and be a deliberate admin decision, but the current default-on behavior must not ship.

### 1b. Remove the hardcoded owner-bypass code
Current behavior: `OWNER_BYPASS_CODE` falls back to the literal string `"2391$$"` when the env var isn't set, and that string is committed in source control. Anyone who reads the repo (or reverse-engineers strings baked into the app bundle) can type that code and get 365 days of free full access.

Fix:
- Remove the hardcoded fallback string completely. If `process.env.OWNER_BYPASS_CODE` is not set, the bypass path must be disabled (fail closed) — do not fall back to any built-in constant.
- Rotate the current value: treat `"2391$$"` as burned/compromised. Set a new, long, random `OWNER_BYPASS_CODE` in the Replit secrets (not in code).
- This bypass should not be reachable from the public checkout/paywall UI at all — restrict it to an admin-only endpoint (it can still live in this service file, but it must require an authenticated admin/support role, not just "knowing the string" at the public paywall).

## PART 2 — TIE PROMO REDEMPTION TO A REAL APPLE PURCHASE

There are two kinds of promo codes and they must be handled differently:

**"website" type codes** — the customer already paid through Clover on p2pfitechai.com. Keep the existing behavior: /promo/redeem grants access directly, no Apple purchase required. Do not change this path — it is relied on by the existing website checkout + Clover redemption flow. Just make sure it still goes through the code-existence, expiry, and usage-limit checks from Part 1.

**"affiliate" / discount type codes** — these apply a discount to an Apple subscription. These must NOT grant access on their own. The current code lets /promo/redeem activate a subscription purely because the code was valid, with the Apple transaction id/product id accepted as optional, unverified, client-reported fields used only for logging. That must change:

1. Add a field to the promo-code schema: `appleProductId` (string) — the exact App Store Connect product identifier this promo code's discount maps to (e.g. a distinct lower-priced subscription product, or the base product + a Promotional Offer identifier — see Part 3). Rename/replace the existing `revenueCatProductId` field — this app does not use RevenueCat, it uses native StoreKit via the Flutter `in_app_purchase` plugin, so that field name is misleading; migrate any existing data to `appleProductId`.

2. `/promo/validate` response must include `appleProductId` alongside the existing `code`, `type`, `label`, `priceCents`, `durationDays`. The app will purchase exactly that Apple product — never a client-chosen or client-priced product.

3. `/promo/redeem` for an "affiliate" code must require proof of a real, already-verified Apple purchase before it grants anything:
   - Require the request body to include `purchaseId` (the Apple transaction id used when the client called /iap/verify).
   - Look up that `purchaseId` in whatever collection /iap/verify writes to (e.g. `iap_subscriptions` / your IAP transactions table). It must exist, belong to the authenticated user, be `status: active`, and its `productId` must match the promo's `appleProductId`.
   - If no matching verified purchase is found, reject with 402 and grant nothing. A promo code alone must never be sufficient to unlock access on the affiliate path — Apple's verified receipt is the actual authority.
   - Only after that check passes: mark the code redeemed, log the `PromoRedemption`, and do whatever extra bookkeeping this app does for the default-trainer subscription (existing `getDefaultTrainer` / `SubscriptionModel.create` logic can stay, since that's separate from payment authorization).

4. Keep everything idempotent: redeeming the same code + purchaseId pair twice must not double-grant or double-log.

## PART 3 — APP STORE CONNECT SETUP (tell me what you need, but the intended design is)

For each affiliate/discount promo tier, create either:
- a distinct subscription product at the discounted price (simplest — e.g. `p2p_standard_3m_promo999` at $9.99 vs the base `p2p_standard_3m` at $19.99), or
- a StoreKit Promotional Offer / Offer Code on the existing product, if you want to keep one product with server-signed discount offers.

Store whichever identifier the client must present as `appleProductId` on the promo-code document. The backend is the only thing that decides which Apple product/offer a given code maps to — the mobile app just purchases whatever product id `/promo/validate` returns.

## PART 4 — STOP REUSING ADMIN_BYPASS_CODE AS AN INTERNAL SERVICE SECRET

`ADMIN_BYPASS_CODE` is currently used for two unrelated things:
- `src/modules/user/admin.bypass.controller.ts` — an actual admin-login bypass.
- `src/modules/promoCode/promoCode.route.ts` (`POST /promo/issue-trial`) — a shared secret that authorizes a server-to-server call (meant to be called by the website's API server after a successful Clover payment, to mint a trial promo code).

These are two different trust boundaries with two different blast radii — one is "log in as admin," the other is "mint one trial code" — and reusing the same secret means a leak of either config value compromises both. Fix:

- Add a new env var, e.g. `APP_BACKEND_SHARED_SECRET`, dedicated to the `/promo/issue-trial` server-to-server call.
- Update the `adminKeyGuard` in `promoCode.route.ts` to check that new var instead of `ADMIN_BYPASS_CODE`. Keep the existing constant-time comparison (`timingSafeEqual`) — do not regress that.
- Leave `ADMIN_BYPASS_CODE` scoped only to actual admin-login bypass in `admin.bypass.controller.ts`.
- Do not reuse this new secret for anything else either (not user session secrets, not owner/bypass credentials) — one secret, one purpose.

## PART 5 — MAKE PROMO REDEMPTION TRANSACTIONAL

Redemption currently does several separate writes (claim the code via `findOneAndUpdate`, create the `Subscription`, update the `User`, log the `PromoRedemption`), with manual rollback (`$inc: usedCount: -1`) sprinkled in error branches if a later step throws. That's fragile — a crash between steps can consume a code without granting access, or grant access without a redemption log.

Fix: wrap the redemption sequence (claim code → create subscription → update user → log redemption) in a MongoDB transaction (`session.withTransaction(...)`), so it's all-or-nothing. If a transaction isn't feasible everywhere (e.g. no replica set locally), at minimum make the sequence resumable: write a `redemption` record in a `pending` state first, then advance it through the remaining steps idempotently, so a crash mid-sequence can be detected and retried instead of silently leaving the code consumed with no access granted.

## PART 6 — UNIFY IAP AND PROMO/WEBSITE ENTITLEMENT RECORDS

Right now "is this user subscribed" can be true for different reasons recorded in different places:
- `/iap/verify` sets `User.subscriptionTier` / `subscriptionStartDate` / `subscriptionEndDate` directly, and (per the IAP spec) writes a separate `iap_subscriptions` record.
- `/promo/redeem` (website or affiliate) creates a `Subscription` document (`userId`, `trainerId`, `status`, `startDate`, `endDate`, `source: "promo" | "owner_bypass" | "trainer_invoice"`) and *also* sets the same `User.subscriptionTier` / date fields.

Two write paths updating the same user fields, plus two different collections recording *why*, means any future check on "is this user entitled" has to know about both to be correct — easy to get wrong once, and each place that re-implements the check independently can drift.

Fix: add one function (e.g. `getEntitlement(userId)`) that is the only thing allowed to answer "is this user subscribed, until when, and why" — it should check both the `iap_subscriptions` records and the `Subscription` records, resolve expiration/revocation consistently, and return a single normalized result. Update every place that currently reads `User.subscriptionTier`/`subscriptionEndDate` directly (auth `/login`, `/auth/me`, any route-level subscription gate) to call this function instead of reading those fields ad hoc. Keep writing the same underlying records (no schema migration required) — this is about having one read path, not necessarily one write path.

## Acceptance criteria

1. Typing a random unregistered string as a promo code → always "Invalid promo code", never grants access. (Fixes 1a.)
2. `OWNER_BYPASS_CODE` unset → bypass path is disabled, not defaulted to a known string. (Fixes 1b.)
3. `/promo/validate` on an "affiliate" code returns `appleProductId`.
4. `/promo/redeem` on an "affiliate" code with no matching verified `purchaseId` → 402, user not subscribed.
5. `/promo/redeem` on an "affiliate" code with a verified purchaseId whose productId matches `appleProductId` → subscription granted, code marked redeemed.
6. `/promo/redeem` on a "website" code → unchanged, still works without any Apple purchase.
7. Redeeming the same code+purchaseId twice → no duplicate subscription/redemption record.
8. `/promo/issue-trial` requires `APP_BACKEND_SHARED_SECRET`, not `ADMIN_BYPASS_CODE`; the admin-login bypass endpoint is unaffected and still uses `ADMIN_BYPASS_CODE`.
9. Killing the process mid-redemption (simulate by throwing after the code-claim step) never leaves a code marked used with no subscription granted, and never leaves a subscription granted with the code still marked unused.
10. `/auth/login`, `/auth/me`, and any subscription-gated route all agree on whether a given user is currently entitled, regardless of whether that entitlement came from IAP, a website code, or an affiliate code — verify by checking they all call the same `getEntitlement` function rather than each re-reading `User` fields independently.

## After implementation, tell me:
1. Files created/modified
2. New/changed env vars (`OWNER_BYPASS_CODE`, `APP_BACKEND_SHARED_SECRET`, etc. — do not paste the actual secret values back, just confirm they're set)
3. Any existing promo codes in the DB that need an `appleProductId` backfilled, and what you set them to
4. Example curl for /promo/validate and /promo/redeem showing the new fields
5. Whether the website's API server (the one calling /promo/issue-trial) has been updated to send the new APP_BACKEND_SHARED_SECRET instead of ADMIN_BYPASS_CODE — that call site lives outside this repo

Start by reading the existing promoCode module (service, model, interface, controller, route) end to end, and the iap module, before changing anything.
```

## COPY UNTIL HERE ↑

---

## Reference

- Companion doc for the IAP verify endpoint itself: [IAP_BACKEND_AI_PROMPT.md](./IAP_BACKEND_AI_PROMPT.md) (that doc's "OUT OF SCOPE: Promo codes" note is superseded by this doc).
- **Current state as of this writing:** the backend still returns `revenueCatProductId` (not `appleProductId`) from `/promo/validate`, and `/promo/redeem` does not yet check `purchaseId` against a verified transaction — Part 1 and Part 2 above have not been applied yet. This doc is the spec to implement, not a description of what's already live.
- Mobile app (`lib/features/paywall/controllers/paywall_controller.dart`) reads `appleProductId` first and falls back to `revenueCatProductId` if that's missing, so it keeps working during the transition and picks up the new field automatically once you ship the rename — no mobile change needed after this is implemented.
