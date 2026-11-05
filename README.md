# Appwrite Boilerplate (Flutter)

Production-ready Flutter starter for Android, iOS and web:
**GetX** (state + DI + i18n) · **go_router** · **Appwrite** · **LocationIQ maps** · **FCM push** · light/dark theme · en / bn / ar (RTL).

## What's included

| Area | Where |
|---|---|
| Auth: sign-in, sign-up, forgot / reset password (link or email OTP), remember me | `modules/auth`, `controllers/auth_controller.dart` |
| Splash bootstrap, maintenance gate, force-update gate | `modules/splash`, `modules/maintenance`, `modules/update` |
| Dashboard shell: mobile bottom nav, desktop-web top nav + drawer + footer | `modules/dashboard`, `common/widgets/web_*` |
| Profile, edit profile, change password, delete account | `modules/profile` |
| Saved addresses with map picker + reverse geocoding (LocationIQ / OSM) | `modules/address` |
| In-app notifications + FCM push | `modules/notification`, `helper/notification_helper.dart` |
| Policies (about / terms / privacy, HTML), help & support, language picker | `modules/policies`, `modules/help_support`, `modules/language` |
| Offline overlay, cookie banner (web), deep links, share links | `main.dart`, `helper/share_helper.dart` |
| **Example feature** (paginated list, full 4-layer pattern) | `modules/example`, `controllers/item_controller.dart` |

Architecture and coding rules: see [CLAUDE.md](CLAUDE.md).

## Start a new project

1. **Copy** this folder and rename it.
2. **Identity**
   - `pubspec.yaml` → `name:` (then find/replace `package:appwrite_boilerplate/` across `lib/` and `test/`).
   - Bundle id `com.example.appwrite_boilerplate` → yours in `android/app/build.gradle.kts` (`namespace`, `applicationId`), the `MainActivity.kt` package + folder, `ios/Runner.xcodeproj/project.pbxproj` and `macos/Runner/Configs/AppInfo.xcconfig` (`PRODUCT_BUNDLE_IDENTIFIER`).
   - App name: `android:label` in `AndroidManifest.xml`, `CFBundleDisplayName` in `ios/Runner/Info.plist`, `web/index.html`, `web/manifest.json`.
   - Logo: `assets/images/logo.png`, launcher icons, `web/icons/`.
3. **Config** — edit the *PROJECT CONFIG* block at the top of `lib/app/resources/constants.dart`:
   `appName`, `appVersion`, `packageName`, `webBaseUrl`, `primaryColorValue` (whole palette derives from it), Appwrite `endpoint` / `projectId` / `databaseId` / `storageBucketId`, messaging ids, `locationIqKey`.
   Also set `projectId` in `appwrite.config.json`.
4. **Appwrite** — create the database, bucket and tables below; add **platforms** for Android, iOS and Web (the web hostname is required for password-recovery links).
5. **Firebase (push, optional)** — `flutterfire configure`, add `google-services.json` / `GoogleService-Info.plist`, then pass `options: DefaultFirebaseOptions.currentPlatform` to `Firebase.initializeApp()` in `lib/global.dart`. Until then push is simply disabled.
6. **Deep links** — replace the host in `AndroidManifest.xml` (`your-app.appwrite.network`), and update `web/.well-known/assetlinks.json` (SHA-256) and `apple-app-site-association` (Team ID + bundle id).
7. **Replace the example** — rename/delete `modules/example`, `ItemModel`, `ItemController`, and swap `ItemListScreen` for your home screen in `DashboardScreen._pages`.

## Appwrite tables

Permissions: give each table row-level security as your product needs; user-owned tables (`users`, `addresses`, `notifications`) should allow the owner only.

| Table id | Columns |
|---|---|
| `users` (row id = auth user id) | `name`, `email`, `phone`, `profile_image_url`, `role`, `is_active` |
| `business_setup` (single row) | `business_name`, `currency_symbol`, `store_location`, `store_latitude`, `store_longitude`, `is_maintenance_mode_on`, `is_email_otp_enabled`, `is_force_update_active`, `app_min_version`, `android_store_url`, `ios_store_url`, `copyright_text`, `cookies_text`, `location_iq_key` |
| `store_setup` (single row) | `store_name`, `description`, `address`, `city`, `state`, `zip_code`, `phone`, `email`, `website`, `facebook`, `instagram`, `twitter`, `logo_url`, `cover_url` |
| `addresses` | `user_id`, `name`, `phone`, `city`, `postal_code`, `latitude`, `longitude`, `is_default` (full list: `address_model.dart`) |
| `notifications` | `user_id`, `title`, `message`, `type`, `image_url`, `is_read`, `action_type` (`route` / `url` / `none`), `action_value` |
| `privacy_policy` (single row) | `about_us_html`, `terms_and_conditions_html`, `privacy_policy_html` |
| `items` (example) | `title`, `description` |

## LocationIQ

Maps use free OpenStreetMap tiles + Nominatim by default. Set a LocationIQ token in `Constants.locationIqKey`, or at runtime in `business_setup.location_iq_key` (wins, so you can rotate without a release). Tile URL, attribution and geocoding switch automatically (`SettingsController.mapTileUrl` / `usesLocationIq`).

## Translations

`assets/language/{en,bn,ar}.json`. Add/remove a language in `Constants.languages` (+ flag in `assets/images`). Every key must exist in all files.

## Commands

```bash
flutter pub get
flutter run
flutter analyze
flutter test
flutter build apk --release --split-per-abi
./tool/build_web.sh
```
# CNG_admin
