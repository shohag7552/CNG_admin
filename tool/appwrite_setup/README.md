# appwrite_setup — dev project schema script

Creates the buckets, tables, columns and indexes in the shared **dev** Appwrite
project. Lives in the admin app because the admin side owns configuration.
It is a separate Dart package (own `pubspec.yaml`), excluded from the admin
app's `flutter analyze`, and is never part of any app build.

- Project `6af42d370036f3d1cf4d` · database `6af42f2d0018ed2e149a` · endpoint `https://sgp.cloud.appwrite.io/v1`
- **Hard-coded to that project**: it refuses to run against any other one.
- **Idempotent and additive**: re-running skips what exists. It never deletes or alters a table, column or index. If a column's type later changes in `schema.dart`, change it in the console (or drop the table in dev) yourself.
- Schema source: [`lib/schema.dart`](lib/schema.dart). Meaning: `docs/database_schema.md`, `docs/security_rules.md`. Everything is PROPOSED and dev-only.

## 1. Preview (no network, no key)

```bash
cd admin/tool/appwrite_setup
dart pub get
dart run bin/setup.dart --dry-run
dart test            # checks the schema definition itself
```

## 2. Create an API key (dev project only)

Appwrite Console → project → **Overview → API keys → Create API key**.
- Name: `dev-schema-setup`, **expiration: 1 day**.
- Scopes: read **and** write for databases, tables, columns, indexes, and storage buckets (use the names the console shows; if the script fails with a "missing scope" message, add that scope).
- Delete the key when the script has succeeded.

## 3. Run it

```bash
export APPWRITE_API_KEY='paste-key-here'     # this shell only — never commit it
dart run bin/setup.dart
# optional: dart run bin/setup.dart --only=users,booking_requests
```

Exit code `0` = everything in place. Exit code `1` prints each problem. Please
send me that output: a failed **UNIQUE** index tells us the capability is not
available and the idempotency/confirmation design (C-24, system_design.md §4)
must change.

## 4. Manual steps the script cannot do

1. **Admin user:** Console → Auth → Users → create a user (email + password), then edit it and add the **label `admin`** (table permissions use `label:admin`).
2. **Auth:** Auth → Settings → make sure **Email/Password** is enabled (C-31).
3. **Platforms:** Android platforms for `com.cnggo.passenger`, `com.cnggo.driver`, `com.cnggo.admin` (done); add Web (`localhost` and the deployed admin host) and iOS when needed.
4. Seed single rows when you want the apps to read them: one `business_setup`, one `business_settings`, one `store_setup`, one `privacy_policy` row.

## What gets created

- Bucket: **`images` only** (avatars and driver verification photos; images only, 5 MB max). File access is per file: avatars read-any, driver documents owner-only (see D-11).
- Boilerplate tables: `users`, `business_setup`, `store_setup`, `privacy_policy`, `addresses`, `notifications`.
- Product tables: `driver_profiles`, `driver_documents`, `driver_locations`, `route_fare_templates`, `booking_requests`, `booking_dispatches`, `booking_offers`, `device_tokens`, `business_settings`, `conversations`, `messages`, `ratings`, `admin_audit_logs`.
- The `items` example table is intentionally **not** created.
- Row security is on for every table. Product tables are readable/writable only by the `api`/`admin` Functions (API key) plus row permissions those functions set.
