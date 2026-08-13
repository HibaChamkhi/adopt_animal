# Payments — spike & integration plan (E2-6 / E4-3)

## Current state (MVP, shipped)
Checkout places an order with **Cash on Delivery** (`paymentMethod: 'cod'`) written
to the `orders` collection. This works today with no paid services and is the
right default for the Egyptian market, where COD dominates.

## The question
Add **online card payment** at checkout, in EGP, for users in Egypt.

## Options compared

| Option | Egypt/EGP support | Setup effort | Needs backend | Notes |
|---|---|---|---|---|
| **Paymob** | ✅ Native (EGP, local cards, wallets, installments via valU) | Medium | Yes (server to create payment key) | Best local coverage; Accept SDK for Flutter |
| **Fawry** | ✅ Native (Fawry pay codes, very common) | Medium | Yes | Great for unbanked users; reference-code flow |
| **Stripe** | ⚠️ Not officially in Egypt for receiving payouts | Low (great SDK) | Yes (PaymentIntent on server) | Excellent DX, but payout/entity restrictions locally |
| **PayPal** | ⚠️ Limited receiving in Egypt | Low | Yes | Cross-border only in practice |

## Recommendation
**Paymob** as the primary gateway (native EGP, cards + mobile wallets + installments),
with **Fawry** as a second method for cash/reference payments. Keep **COD** as the
always-available fallback. Use Stripe only if you later sell cross-border.

## Why this can't ship on the current setup
Every gateway requires a **server-side secret** to create the payment session — you
must never put a gateway secret key in the app. That server is either:
- a **Cloud Function** (needs the **Blaze** plan), or
- any small backend you host (Node/Dart/etc.).

So payments are **blocked on**: (1) a Paymob/Fawry merchant account, and (2) a
server to hold the secret and create payment intents.

## Integration steps (Paymob, when ready)
1. Create a Paymob merchant account → get **API key**, **Integration ID**, **iframe ID**.
2. Backend (Cloud Function) endpoint `createPayment`:
   - Auth step → get an auth token.
   - Order registration → get an `order_id`.
   - Payment key request (amount in **piasters** = EGP × 100, `order_id`, billing) → `payment_token`.
   - Return `payment_token` to the app.
3. App:
   ```yaml
   dependencies:
     # Paymob Accept Flutter SDK, or open the iframe URL in a WebView
     webview_flutter: ^4.x
   ```
   - Call your `createPayment` with the cart total.
   - Open the Paymob iframe (`https://accept.paymob.com/api/acceptance/iframes/<IFRAME_ID>?payment_token=<token>`) in a WebView.
   - On success callback, write the order with `paymentMethod: 'card'`, `status: 'paid'`.
4. Verify server-side via Paymob's **HMAC** webhook before marking an order paid —
   never trust the client callback alone.

## App-side changes needed
- Checkout: add a payment-method selector (COD / Card / Fawry).
- `OrderRepository.placeOrder`: accept `paymentMethod` + `status` (already stores these).
- New `PaymentService` calling the backend endpoint.

## Security / policy note
The app must never enter or store raw card numbers or gateway secret keys. The
card entry happens on the **gateway's own hosted page/iframe**, which is also what
keeps you out of PCI scope.
