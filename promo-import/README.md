# Promo Code Import — P2P FitTech AI

These files contain every active promo code exported from the P2P website database
(30,000 website codes + 30,001 affiliate codes), formatted for this repo's
built-in importer (`src/scripts/importPromoCodes.ts`).

- `website-codes.txt`  — `P2PW-...` | Website  | $19.99 | 2 Months
- `affiliate-codes.txt` — `P2PA-...` | Affiliate | $9.99  | 1 Month

## How to load them into the app database

Run once on the server (or any machine with the production `DATABASE_URL`):

```bash
npm run import:promo -- ./promo-import/website-codes.txt WEB_BATCH_001
npm run import:promo -- ./promo-import/affiliate-codes.txt AFF_BATCH_001
```

Duplicates are skipped automatically, so re-running is safe.

## What the codes do once imported

- **At checkout (`POST /payments/checkout/default`):** passing a valid, active
  code in `promoCode` cuts the subscription price 50% ($20 → $10 monthly,
  $50 → $25 annual).
- **Full promo redemption (`POST /promo/validate` + `/promo/redeem`):** grants
  the code's own plan (price/duration stored on the code) through the promo
  flow, bypassing the standard checkout.
