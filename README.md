# SALLIH | صلّح

A bilingual Flutter home-maintenance client for Android, iOS and web, with a separately deployed Node payment API.

واجهة عربية وإنجليزية لخدمات الصيانة، مع اختيار عنوان الخدمة من الخريطة ومسار دفع يتحقق منه الخادم.

## Status

- Arabic/English labels, Material localization delegates, RTL/LTR and persisted language/theme preferences.
- Responsive sign-in and registration screens; Supabase email/password authentication when configured. Demo exploration is explicitly labelled and cannot authorize payments.
- OpenStreetMap address picker, foreground location permissions, reported accuracy, manual selection and local address persistence.
- A **reference Stripe Checkout integration**, server-owned prices, customer ownership checks, signed webhooks, persistent receipts and checkout idempotency.
- Stripe is **not activated**: the merchant country, provider choice, account, hosting and credentials still need to be supplied. SAR is the current catalogue currency; confirm currency and final business prices before enabling live payments.
- The existing chat, support, technician assignment and scheduling are still demo features. They are not production integrations. Quote services cannot be paid until an authenticated provider/quote workflow is implemented.

This branch is implementation work for review, not a certified production release. No live charge or deployment has been performed.

## Layout

```text
lib/
  app/                  Application settings and navigation
  core/localization/    Central label catalog and locale-aware text
  core/network/         Authenticated HTTPS API client
  core/theme/           Light/dark Material themes
  data/models/          Domain models
  data/repositories/    Sample catalogue and demo state
  features/
    auth/               Supabase authentication and account screens
    catalog/            Service selection and order creation
    location/           Map picker, location service, address storage
    orders/             Customer order API and detail screens
    payments/           Hosted checkout and server confirmation
    wallet/             Address management (wallet funding unavailable)
    chat/, support/     Clearly labelled demo flows
  legacy/               Previous UI kept separately, not used by the app
server/
  src/                  HTTP API, authentication, SQLite, Stripe adapter
  test/                 Payment/ownership/signature regression tests
```

## Client development

The repository requires **Dart `^3.13.5`**. Its original `.metadata` revision maps to Flutter **3.47.6**. Use a compatible SDK; do not lower the constraint to force installation.

During this cloud session, the official Flutter release metadata and 3.47.6 Linux archive returned HTTP 404 after network access was available. There is no Flutter/Dart executable installed here. Flutter package resolution, analyzer, widget tests and platform builds therefore remain **unrun**. New package entries in `pubspec.yaml` require generating and reviewing an updated `pubspec.lock` with a compatible SDK. Dart syntax was independently checked, but that is not a Flutter build or type check.

With the compatible SDK installed, from the repository root:

```sh
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

For live authentication and the API, use a local ignored JSON file containing **only client-public configuration**:

```json
{
  "SUPABASE_URL": "https://YOUR_PROJECT.supabase.co",
  "SUPABASE_ANON_KEY": "YOUR_PUBLIC_ANON_KEY",
  "API_BASE_URL": "https://YOUR_API_HOST"
}
```

```sh
flutter run -d chrome --dart-define-from-file=config/client.local.json
flutter build web --release --dart-define-from-file=config/client.local.json
flutter build appbundle --release --dart-define-from-file=config/client.local.json
flutter build ios --release --dart-define-from-file=config/client.local.json
```

Never put Stripe secrets, webhook secrets or Supabase service-role keys in Flutter configuration. Client access tokens stay in memory and expire; sign in again after restarting the app or session expiry. For web hosted-checkout return, sign in again and open My Orders to check server-confirmed payment status. The return URL does not mark payment successful.

Android/iOS release signing, owned bundle identifiers and store provisioning are required before distribution. The existing Android release configuration still uses a debug signing key and must be replaced for a store release. iOS builds require macOS/Xcode; they cannot run in this Linux workspace. The manual Flutter workflow builds web, a debug Android APK and unsigned iOS once compatible SDK artifacts are available; it has not been run.

## Payment API

Requires Node **24+**. No third-party runtime packages are needed.

```sh
cd server
npm ci --ignore-scripts
npm test
cp .env.example .env
# Populate secure values outside source control.
node --env-file=.env src/server.js
```

See [deployment and payment activation](docs/deployment.md). With no authentication/payment configuration, `/health` returns `503 configuration_required`; starting a process alone is not payment readiness.

Validated in this cloud session: **16 payment API tests passed**, including ownership, trusted pricing, concurrent checkout, signature checks, duplicate events and persisted receipts. Stripe and Supabase calls in these tests use controlled fixtures. They do not establish live merchant access.

## Maps

Location permission is requested only after pressing “Use my current location”. Sensor accuracy depends on the device and environment; it is displayed rather than guaranteed. A point chosen manually is labelled separately. New addresses retain actual selected coordinates, not fixed Riyadh coordinates. Existing default addresses are sample data. Addresses are stored on the device, not synchronized across accounts/devices.

Web location needs HTTPS (or a supported local development origin). Map tiles need `tile.openstreetmap.org`; OpenStreetMap attribution remains visible. Follow the public tile service’s usage policy and move to a contracted tile provider before significant traffic. No bulk tile download or background location tracking is implemented.

## Validation and GitHub

```sh
cd server
npm test
```

`Payment API checks` runs on GitHub pushes/PRs. `Flutter platform validation` is manually triggered with a compatible SDK version. Flutter validation and lockfile regeneration remain required before merging or distributing this branch.
