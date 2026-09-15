# IAP Backend — AI Prompt (Copy & Paste)

> **কীভাবে use করবেন:** নিচের ` ``` ` block টা **পুরো copy** করে backend repo-তে Cursor / ChatGPT / Claude-এ paste করুন।  
> Existing backend code, User model, auth middleware — সব context সহ paste করলে ভালো result পাবেন।

---

## COPY FROM HERE ↓

```
Implement In-App Purchase (IAP) verification for our mobile app "P2P Fit Tech AI".

## Goal
Flutter app থেকে Apple App Store / Google Play subscription purchase proof আসবে।
Backend server-side verify করবে, user-কে subscribed mark করবে, response দেবে।
Client-side purchase proof বিশ্বাস করবেন না — Apple/Google API দিয়ে verify করতে হবে।

## App info
- iOS bundle id: com.p2pfittech.ai
- Android package: com.p2pfittech.ai
- Apple App Apple ID: 6757503524
- API prefix: /api/v1
- Auth: Authorization: Bearer <jwt> (existing user auth middleware use করুন)

## Subscription products (auto-renewable)
| productId (store) | subscriptionTier (DB) |
|-------------------|----------------------|
| month_1           | monthly              |
| year_1            | annual               |

Personal trainer invoice flow আলাদা — এ IAP শুধু default AI trainer plan-এর জন্য।

---

## TASK — implement exactly this

### 1) New endpoint: POST /api/v1/iap/verify

**Auth required** — logged-in user (role: user)

**Request body:**
{
  "platform": "ios",           // "ios" | "android"
  "productId": "year_1",       // "month_1" | "year_1"
  "purchaseId": "1000000123456789",
  "verificationData": "<string>"
}

**Field notes:**
- verificationData on iOS = StoreKit 2 signed transaction JWS (from Flutter purchase.verificationData.serverVerificationData)
- verificationData on Android = Google Play purchase token (same Flutter field)
- purchaseId = store transaction id — use for idempotency

**Success response HTTP 200:**
{
  "success": true,
  "message": "Subscription activated",
  "data": {
    "isSubscribed": true,
    "subscriptionTier": "annual",
    "subscriptionStartDate": "2026-07-21T00:00:00.000Z",
    "subscriptionEndDate": "2027-07-21T00:00:00.000Z",
    "status": "active",
    "platform": "ios",
    "productId": "year_1"
  }
}

**Error responses:**
- 400 — invalid body / unknown productId
- 401 — no/invalid JWT
- 402 — purchase invalid or expired
- 409 — this purchase already linked to another user account
- 500 — store API error

Error shape:
{ "success": false, "message": "Invalid purchase" }

---

### 2) Verify with store (server-side)

**iOS:**
- Verify JWS in verificationData using Apple App Store Server API / Apple's library
- Confirm bundle id = com.p2pfittech.ai
- Confirm productId is month_1 or year_1
- Read expiry date from Apple response
- Env vars: APPLE_IAP_KEY_ID, APPLE_IAP_ISSUER_ID, APPLE_IAP_PRIVATE_KEY (.p8 contents)

**Android:**
- Call Google Play Developer API:
  GET .../applications/com.p2pfittech.ai/purchases/subscriptionsv2/tokens/{verificationData}
- Confirm subscription is ACTIVE and read expiryTime
- Env var: GOOGLE_PLAY_SERVICE_ACCOUNT_JSON

---

### 3) Update User document after successful verify

Update the authenticated user:
- subscriptionTier: "monthly" | "annual"  (from productId map)
- subscriptionStartDate: ISO UTC (from store)
- subscriptionEndDate: ISO UTC (from store expiry)
- subscribedTrainer: null  (default trainer IAP — personal trainer null থাকবে)

Also ensure login endpoint (POST /api/v1/auth/login) returns:
- isSubscribed: true  when subscriptionEndDate > now AND status active

And GET /api/v1/auth/me already returns subscriptionTier, subscriptionStartDate, subscriptionEndDate — keep in sync.

---

### 4) Save subscription record (new collection recommended: iap_subscriptions)

Minimum fields:
- userId
- platform (ios | android)
- productId
- subscriptionTier
- purchaseId (unique index)
- originalTransactionId (unique index — iOS)
- purchaseToken (Android)
- status: active | expired | refunded
- startDate, endDate
- createdAt, updatedAt

**Rules:**
- Idempotent: same purchaseId same user → return existing success (don't duplicate)
- If purchaseId/originalTransactionId belongs to different userId → 409
- Invalid/expired store response → 402, do NOT update user

Optional: save to iap_transactions for audit (gateway: apple_iap | google_iap)

---

### 5) Wire into existing codebase

- Follow existing route/controller/service/repository pattern in this project
- Follow existing response format { success, message?, data? }
- Reuse existing JWT auth middleware
- Add env vars to .env.example
- Do NOT break existing Stripe/trainer-invoice payment flows

---

## OUT OF SCOPE (do not implement now)
- Apple/Google webhooks (phase 2)
- Promo codes — see [PROMO_APPLE_BACKEND_AI_PROMPT.md](./PROMO_APPLE_BACKEND_AI_PROMPT.md) for that spec (it depends on this endpoint's transaction records)
- Restore purchases endpoint (phase 2)

---

## Acceptance criteria (must pass)

1. Valid iOS sandbox purchase → user gets isSubscribed true on login
2. productId year_1 → subscriptionTier = annual, correct endDate ~1 year
3. productId month_1 → subscriptionTier = monthly, correct endDate ~1 month
4. Same purchaseId sent twice for same user → idempotent success, no duplicate DB row
5. Fake verificationData → 402, user NOT subscribed
6. Purchase linked to user A, verify as user B → 409
7. GET /api/v1/auth/me shows updated subscription fields after verify

---

## After implementation, tell me:
1. Files created/modified
2. New env vars needed
3. Example curl to test POST /api/v1/iap/verify
4. Any assumptions made about existing User model

Start by scanning the codebase for User model, auth middleware, and payment-related code, then implement.
```

## COPY UNTIL HERE ↑

---

## Optional: এক line short prompt

যদি আগে থেকে backend project open থাকে, শুধু এটা paste করলেও চলে:

```
Read docs/IAP_BACKEND_AI_PROMPT.md (or the IAP section) and implement POST /api/v1/iap/verify for iOS + Android IAP — verify with Apple/Google server-side, update user subscriptionTier/subscriptionStartDate/subscriptionEndDate/isSubscribed, idempotent on purchaseId, follow existing /api/v1 patterns.
```

---

## Reference (human readable)

Short spec: [IAP_BACKEND_INTEGRATION.md](./IAP_BACKEND_INTEGRATION.md)
