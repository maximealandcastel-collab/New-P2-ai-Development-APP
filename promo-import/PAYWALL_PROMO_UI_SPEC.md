# Paywall Promo Code UI — Spec for the Flutter App

The backend is fully ready for promo codes. The paywall screen in the Flutter
app needs a small addition so users can enter them. This is the exact flow to
implement:

## UI

On the paywall/subscription screen, under the Monthly ($20) / Annual ($50)
plan buttons, add:

- A link/button: **"Have a promo code?"**
- Tapping it reveals a text field (auto-uppercase, trim spaces) + **Apply** button
- After a valid code is applied, show the discounted/plan price and a
  "✓ Code applied: XXXX" chip with a remove (×) option

## API flow

### 1. Validate the code as soon as the user taps Apply

`POST /api/v1/promo/validate` (Bearer token required)

```json
{ "code": "P2PA-001W-27218" }
```

Success returns the code's plan (label, priceCents, durationDays). Show the
price from this response. Errors: invalid/inactive/already-used code → show
the error message inline under the field.

### 2a. Checkout with 50% discount (Stripe path)

If the user proceeds to normal checkout with a code applied, pass it along:

`POST /api/v1/payments/checkout/default`

```json
{ "tier": "monthly", "promoCode": "P2PA-001W-27218" }
```

The returned `paymentUrl` opens Stripe Checkout at 50% off
($10 monthly / $25 annual). Apple Pay shows automatically on iPhones.

### 2b. Full promo redemption (bypasses Stripe checkout)

If the code should grant its own plan directly (e.g. prepaid affiliate codes
sold at $9.99/1-month, website codes $19.99/2-months):

`POST /api/v1/promo/redeem` with the code (and purchase receipt when the
purchase is made through in-app purchase / RevenueCat). Access is granted
immediately for the code's duration.

## Notes

- Codes are one-use by default (`maxUses: 1`).
- All 60,001 active codes are in `promo-import/` and load with
  `npm run import:promo` (see `promo-import/README.md`).
