# IAP Backend — Minimal Guide

> **Backend dev / AI-তে prompt দিতে:** [`IAP_BACKEND_AI_PROMPT.md`](./IAP_BACKEND_AI_PROMPT.md) — পুরো block copy-paste করুন।

**App:** P2P Fit Tech AI  
**iOS bundle:** `com.p2pfittech.ai`  
**Android package:** `com.p2pfittech.ai`  
**Apple App ID:** `6757503524`

Mobile app IAP purchase করে → backend verify করে → user subscribed mark করে।

---

## Products

| Store product ID | Plan | Save as `subscriptionTier` |
|------------------|------|----------------------------|
| `month_1` | Monthly | `monthly` |
| `year_1` | Annual | `annual` |

---

## Flow (simple)

```
1. User pays in App Store / Google Play
2. Flutter sends proof to backend
3. Backend verifies with Apple / Google
4. Backend updates user subscription fields
5. Backend returns success → app unlocks
```

**Rule:** App unlock only after backend says OK. Do not trust the phone alone.

---

## Only 1 API needed to start

### `POST /api/v1/iap/verify`

**Auth:** `Authorization: Bearer <user_jwt>`

**Request:**

```json
{
  "platform": "ios",
  "productId": "year_1",
  "purchaseId": "1000000123456789",
  "verificationData": "<ios: signed JWS | android: purchase token>"
}
```

| Field | Values |
|-------|--------|
| `platform` | `ios` or `android` |
| `productId` | `month_1` or `year_1` |
| `purchaseId` | Store transaction id (for duplicate check) |
| `verificationData` | From mobile: `purchase.verificationData.serverVerificationData` |

**Success `200`:**

```json
{
  "success": true,
  "data": {
    "isSubscribed": true,
    "subscriptionTier": "annual",
    "subscriptionStartDate": "2026-07-21T00:00:00.000Z",
    "subscriptionEndDate": "2027-07-21T00:00:00.000Z"
  }
}
```

**Fail `402`:**

```json
{
  "success": false,
  "message": "Invalid purchase"
}
```

---

## Backend must update user (after verify OK)

Update these fields on the logged-in user:

| Field | Example |
|-------|---------|
| `subscriptionTier` | `monthly` or `annual` |
| `subscriptionStartDate` | ISO date |
| `subscriptionEndDate` | ISO date from store expiry |
| `isSubscribed` | `true` on login response |

App already reads these from:
- `POST /api/v1/auth/login` → `isSubscribed`
- `GET /api/v1/auth/me` → subscription fields

---

## How to verify (backend)

### iOS
- Use App Store Server API / verify the JWS in `verificationData`
- Check bundle id = `com.p2pfittech.ai`
- Check product id = `month_1` or `year_1`
- Read expiry date from Apple response

**Server env needed:**
- Apple API Key (`.p8`), Key ID, Issuer ID

### Android
- Call Google Play API with `verificationData` (purchase token)
- Package = `com.p2pfittech.ai`
- Check subscription is active + expiry date

**Server env needed:**
- Google service account JSON (Android Publisher API)

---

## Important rules

1. Same `purchaseId` দ twice hit করলে duplicate create করবেন না (idempotent).
2. One purchase another user account-এ link করা যাবে না → return `409`.
3. Verify fail হলে user subscribe mark করবেন না.
4. Trainer role (`role: trainer`) — subscribe check লাগে না, শুধু `user` role।

---

## Phase 2 (later — renewal/cancel)

প্রথমে উপরের 1টা API দিয়ে start করুন। পরে add করবেন:

- Apple webhook → renew / cancel / refund update
- Google webhook → same

Webhook ছাড়া first purchase কাজ করবে, কিন্তু auto-renew/cancel track হবে না।

---

## Test checklist

- [ ] Buy `month_1` → login-এ `isSubscribed: true`
- [ ] Buy `year_1` → `subscriptionTier: annual`
- [ ] Same purchase again → no duplicate / no error for same user
- [ ] Fake token → `402 Invalid purchase`
- [ ] `/auth/me` shows correct `subscriptionEndDate`

---

## Mobile (Flutter)

Calls verify **before** `completePurchase()`:

```
POST /api/v1/iap/verify
→ success? complete purchase + refresh profile + go home
→ fail? show error, do not unlock / do not complete purchase
```
