# CLAUDE.md

Guidance for working in this repository. Follow these conventions exactly.

## Project

`appwrite_boilerplate` — a production-ready Flutter starter (Android, iOS, web)
backed by **Appwrite**. Ships auth, profile, addresses with maps, push
notifications, translations (en/bn/ar + RTL), light/dark theme, maintenance /
force-update gates, and one **example feature** (`modules/example`) showing the
full data-flow pattern.

- **State management + DI:** GetX (`get`) — `GetBuilder`, not `Obx`
- **Routing:** `go_router` mounted via `GetMaterialApp.router`
- **Backend:** Appwrite (`appwrite` SDK) through a single `AppwriteService`
- **Maps:** `flutter_map` + LocationIQ (falls back to free OSM/Nominatim)
- **Push:** Firebase Messaging + `flutter_local_notifications`

## Commands

```bash
flutter pub get
flutter run
flutter analyze                       # must stay at "No issues found!"
flutter analyze lib/path/to/file.dart # analyze a single file after editing
flutter test
flutter build apk --release
./tool/build_web.sh                   # web build with version stamp
```

## Architecture — layered, feature-first

```
lib/
  main.dart                      # GetMaterialApp.router, connectivity overlay, cookie banner
  global.dart                    # Global.init(): Firebase, notifications, DI, web bootstrap
  app/
    appwrite/                    # AppwriteService (DB/auth/storage/functions) + AppwriteConfig (ids)
    controllers/                 # ALL controllers (GetxController) — business logic + state
    models/                      # fromJson/toJson/copyWith (snake_case keys = Appwrite columns)
    modules/<feature>/
      screens/                   # pages
      widgets/                   # widgets used by THIS feature
      domain/repository/         # <feature>_repo_interface.dart + <feature>_repository.dart
      domain/services/           # optional pure helpers
    common/widgets/              # cross-feature widgets (WebTopNav, WebFooter, AuthGate, CustomAppbar…)
    helper/
      dependencies.dart          # DI wiring (repos + controllers) + loads translations
      routes/app_router.dart     # GoRouter, RouteNames, AppRouter path constants
      dashboard_tab_bus.dart     # dashboard tab slugs (?tab=home|notifications|profile)
      session_manager.dart       # load/clear user-scoped data on login/logout
    resources/                   # constants (PROJECT CONFIG lives here), colors, text_style, theme, messages, images
assets/language/{en,bn,ar}.json  # translation key/value maps
```

**Data flow:** `View` → `Controller` → `RepoInterface` → `Repository` → `AppwriteService`.
Views never touch repositories or `AppwriteService` directly.

### Worked example — `modules/example` (items list)

1. **Model** `models/item_model.dart`.
2. **Interface** `modules/example/domain/repository/item_repo_interface.dart` — `Future<List<ItemModel>> getItems({String? cursor, int limit});`
3. **Repository** `item_repository.dart` — the only layer calling Appwrite; returns models, throws on failure:
   ```dart
   final res = await appwriteService.listTable(
     tableId: AppwriteConfig.itemsCollection,
     queries: [Query.orderDesc('\$createdAt'), Query.limit(limit),
               if (cursor != null) Query.cursorAfter(cursor)],
   );
   return res.rows.map((r) => ItemModel.fromJson(r.data)).toList();
   ```
4. **Controller** `controllers/item_controller.dart` — owns `isLoading / errorMessage / items / hasMore`, calls the interface, then `update()`.
5. **View** `modules/example/screens/item_list_screen.dart` — `GetBuilder<ItemController>`, calls `getItems()` in `initState`, `loadMore()` on scroll, renders state. Imports the controller only.

## MANDATORY rules

### 1. Translate every user-facing string
Add the key to **all of** `assets/language/en.json`, `bn.json`, `ar.json`, then `Text('my_key'.tr)`.
Keys are `snake_case`. Only debug `log()` text and proper nouns may stay literal.

### 2. Business logic lives in controllers
`controllers/<x>_controller.dart` (`extends GetxController implements GetxService`). Expose state via getters; mutate then `update()`.

### 3. Appwrite calls live in repositories only
`modules/<feature>/domain/repository/<feature>_repository.dart` behind `<feature>_repo_interface.dart`. Controllers depend on the **interface**. Use `appwriteService.listTable / createRow / updateTable / getDocument / deleteRow / uploadImage / executeFunction` with `Query.*` and ids from `AppwriteConfig`. Never put an Appwrite API key in the app — privileged work goes through a Function (`executeFunction`).

### 4. Widgets go in the feature's `widgets/` folder
Only truly cross-feature widgets go in `common/widgets/`. Keep screens thin.

### 5. Use `Constants` for design values — never hardcode
Padding, margin, font size, radius, spacing come from `resources/constants.dart`:
`fontSizeExtraSmall…fontSizeOverLarge`, `paddingSizeExtraSmall…paddingSizeExtraLarge`,
`radiusSmall…radiusExtraLarge`, `spaceSection`, `bottomNavSpace`. Missing value → add a token.

### 6. Theme-aware colors — never a static color
- With a `BuildContext`: `context.textPrimary`, `context.textSecondary`, `context.scaffoldBackground`, `context.cardBackground` (`AppColorsX` in `resources/colors.dart`).
- Without one: `ColorResource.<color>` (non-reactive).
- Brand constants identical in both modes (`ColorResource.primaryDark`, `primaryGradient`, `error`, `textWhite`) are fine.
- The whole brand palette derives from `Constants.primaryColorValue`.

## Conventions

- **DI:** register in `helper/dependencies.dart` with `Get.lazyPut` — interface first, then controller. Resolve with `Get.find<T>()`.
- **Routing:** add a `GoRoute` in `app_router.dart` + a path constant in `AppRouter` + a name in `RouteNames`. Navigate with `context.pushNamed(RouteNames.x)` (detail pages) or `context.goNamed(...)` (replace stack). Detail routes take an id path param and hydrate via `_DeepLinkLoader` when `extra` is null.
- **Dashboard tabs:** `DashboardScreen._pages` ↔ `DashboardTabs.names` ↔ the bottom-nav items ↔ `WebTopNav` `_navItem`s — keep all four in the same order.
- **Web layout:** `WebTopNav.isEnabled(context)` (web ≥ 900px) → show `WebTopNav` app bar + `WebProfileDrawer` end-drawer + `WebFooter`; otherwise `CustomAppbar` + bottom nav. Cap content with `WebTopNav.maxContentWidth`.
- **Auth-only screens:** wrap the body in `AuthGate`; gate actions with `AuthFlow.openLogin(context)`. Guard user-scoped fetches with `isUserLoggedIn()`; register load/clear calls in `SessionManager`.
- **Text styles:** `poppinsRegular / poppinsMedium / poppinsBold` from `resources/text_style.dart`.
- **Models:** `fromJson` / `toJson` / `copyWith`; system fields `$id`, `$createdAt`.
- **Toasts:** `customToster('msg'.tr, isSuccess: bool)`.
- **Maps / LocationIQ:** read tile URL / attribution / key from `SettingsController` (`mapTileUrl`, `usesLocationIq`, `locationIqKey`); remote `business_setup.location_iq_key` overrides `Constants.locationIqKey`.
- **Remote config:** `SettingsController.businessSetup` (`business_setup` row) drives maintenance, force update, LocationIQ, cookie text.

## Adding a feature (recipe)

1. `models/<x>_model.dart` — `fromJson` / `toJson` / `copyWith`.
2. `modules/<x>/domain/repository/<x>_repo_interface.dart` + `<x>_repository.dart`.
3. Table id in `AppwriteConfig`.
4. `controllers/<x>_controller.dart` — depends on the interface.
5. `modules/<x>/screens/` + `modules/<x>/widgets/` — translated strings, `Constants`, theme colors.
6. Register repo + controller in `helper/dependencies.dart`.
7. Route in `app_router.dart` / `RouteNames` if navigable.
8. New strings in `en.json`, `bn.json` **and** `ar.json`.
9. `flutter analyze` → "No issues found!".
