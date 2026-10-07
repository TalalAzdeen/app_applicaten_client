# Deployment and real payment activation

## Required decisions

Confirm the merchant country, legal entity, payment provider, settlement currency and service prices. Stripe Checkout is the current reference adapter, not a claim of Stripe availability for a Saudi merchant. If the selected account uses Moyasar, Tap or another provider, replace the hosted-checkout adapter, signature verifier and Flutter checkout host allowlist together, then validate against that provider's official API and sandbox.

## Authentication and server

1. Create/configure a Supabase project with email/password authentication, email confirmation and password policy. Use its **public anon key**, never a service-role key, for the authentication requests in this project. The server validates each access token through Supabase `/auth/v1/user`; customer IDs supplied in HTTP bodies are ignored.
2. Deploy `server/` using Node 24 behind an HTTPS reverse proxy. It binds to loopback by default. Configure TLS termination, inbound request limits, a shared rate limiter if required, and explicit allowed web origins. Do not expose the loopback development listener directly.
3. Set `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`, `CHECKOUT_RETURN_URL`, `PAYMENT_MODE`, `ALLOWED_ORIGINS`, and a persistent `DATABASE_PATH` in secure deployment settings. Start using `PAYMENT_MODE=test` and matching test keys. Never paste secret values into chat or commit `.env`.
4. Use one API process/replica for this SQLite implementation. Back up the database and WAL consistently and test restoring them. Move to a transactional shared database and distributed checkout locking before scaling to multiple replicas. A per-customer rate limit is provided in-process; ingress protection is also required.
5. Set the client-public configuration described in the README, build and host the web client on HTTPS. Configure mobile signing and real package/bundle IDs separately.

## Checkout and confirmation

- `POST /orders` accepts a known service ID, description and real address. The server owns prices and currency. Fixed-price services can be charged; range/inspection services remain unpayable. No client-selected amount is trusted.
- `GET /orders` and `GET /orders/:id` return only the authenticated customer's records.
- `POST /checkout` accepts **only an order ID** for pricing purposes. Stripe hosted checkout handles card data. The per-order idempotency key is persisted and reused after network failures; open sessions are reused. Completed checkout waits for webhook confirmation. Expired sessions can be renewed.
- Configure a Stripe webhook for `checkout.session.completed` and `checkout.session.async_payment_succeeded` at `https://YOUR_API_HOST/webhooks/stripe`.
- The webhook verifies HMAC over the **raw request body**, checks the timestamp, live/test mode, paid/completed state, recorded session, order metadata, owner, amount and currency before marking paid. Duplicate events do not duplicate receipts. A returned or cancelled browser URL never marks paid.
- Payment does not imply maintenance completion, a warranty, VAT invoice issuance, wallet funding or cashback. Receipts are ledger records; a downloadable tax invoice is not implemented. Refunds, disputes, provider settlement reconciliation, staff quoting and service fulfilment require additional business workflows before a complete production service.

## Sandbox acceptance

Before switching to live mode, exercise authentication and real sandbox requests, not just fixtures:

1. Register, confirm email, sign in on Android/iOS/web, and create a fixed-price order using a saved real address.
2. Start checkout twice and confirm the same open session is reused. Complete a provider test-card payment (including authentication/3DS where supported).
3. Return to the app and verify the webhook-confirmed paid state. Close/restart the app, sign in again and confirm the persisted order/receipt.
4. Test payment cancellation, decline, webhook retry, asynchronous payment, duplicate webhook, expired checkout and interrupted network.
5. Test a second user cannot read or pay the first user's order; test client amount/currency manipulation and invalid coordinates.
6. Run location denial, permanent denial, disabled service, inaccurate sensor results, manual selection and tile network failure on each target platform.
7. Run Flutter analysis, widget tests and the three platform builds; regenerate and review `pubspec.lock`.

Only activate live mode after the selected merchant account and these acceptance checks are verified. No sandbox/live charge, public deployment or store submission occurred in this task.

## Network destinations

Development requires GitHub, pub.dev/package archives and Flutter official storage. Maps require `tile.openstreetmap.org` and attribution links use `www.openstreetmap.org`. The reference backend needs `api.stripe.com` plus the exact Supabase project hostname. GitHub API operations may require adding `api.github.com` to cloud network settings; native Git access already uses platform authentication. Do not replace an unknown network allowlist or request a personal token merely because GitHub API access is blocked.
