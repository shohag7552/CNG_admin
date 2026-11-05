
import 'package:appwrite_boilerplate/app/resources/images.dart';

/// App-wide configuration.
///
/// **Do not import Flutter into this file.** Keeping it Flutter-free lets
/// plain-Dart tooling (seed scripts, server Functions) import the same ids.
/// That is why the brand colour is an `int`, wrapped in a `Color` in
/// `resources/colors.dart`.
class Constants {
  // ═════════════════════════════════════════════════════════════════════════
  //  PROJECT CONFIG — the only block you must edit for a new project.
  //  See README.md › "Start a new project".
  // ═════════════════════════════════════════════════════════════════════════

  static const String appName = 'CNG Go Admin';

  /// Keep in sync with `version:` in pubspec.yaml — drives force-update.
  static const String appVersion = "1.0.0";
  static const String packageName = 'com.example.appwrite_boilerplate';

  /// Deployed Flutter web build (share links, password-recovery links).
  static const String webBaseUrl = 'https://your-app.appwrite.network';

  /// Brand colour as an int (this file stays Flutter-free, see above).
  // Deep emerald: white text on it passes WCAG AA (≈5:1).
  static const int primaryColorValue = 0xFF0A7F58;

  // ── Appwrite ── (Console › Project › Settings)
  static const String endpoint = 'https://cloud.appwrite.io/v1';
  static const String projectId = 'YOUR_PROJECT_ID';
  static const String databaseId = 'YOUR_DATABASE_ID';
  // No Appwrite API key here: a key compiled into a client app can be
  // extracted by anyone. Server keys live only in Function environments.

  /// Alias of [databaseId], kept because callers use both spellings.
  static const String dbId = databaseId;

  /// Storage bucket for uploaded images (avatars, etc.).
  static const String storageBucketId = 'YOUR_BUCKET_ID';

  /// FCM push plumbing (Appwrite Messaging). Leave as-is until push is set up.
  static const String messagingProviderId = 'YOUR_FCM_PROVIDER_ID';
  static const String notificationFunctionId = 'YOUR_NOTIFICATION_FUNCTION_ID';

  /// Topic every user device subscribes to for broadcast pushes.
  static const String topicId = 'YOUR_BROADCAST_TOPIC_ID';

  // ── LocationIQ ── (https://my.locationiq.com › Access Tokens)
  /// Compile-time LocationIQ token. A non-empty `location_iq_key` in the
  /// `business_setup` row overrides it at runtime (rotate without a release).
  /// Empty in both places → free OpenStreetMap tiles + Nominatim geocoding.
  static const String locationIqKey = '';

  /// ── Maps ──────────────────────────────────────────────────────────────
  /// Every map in the app is configured here (see "Map setup" in the docs).

  /// Raster tile source; flutter_map fills in `{z}/{x}/{y}`. The default is
  /// OpenStreetMap's free community server, which is meant for light use —
  /// switch to your own provider (most take a `?key=` in this URL) before
  /// going live with real traffic.
  static const String mapTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Highest zoom level [mapTileUrl] serves. Zooming past it upscales the
  /// last level instead of showing blank tiles. OpenStreetMap: 19.
  static const int mapMaxNativeZoom = 19;

  /// Credit shown on every map. The tile/data licence requires it — change it
  /// together with [mapTileUrl], never remove it.
  static const String mapAttribution = '© OpenStreetMap contributors';
  static const String mapAttributionUrl = 'https://www.openstreetmap.org/copyright';

  /// Fallback map centre, used only when business setup has no location.
  static const double mapDefaultLatitude = 23.8103;
  static const double mapDefaultLongitude = 90.4125;

  /// Reverse geocoding (map position → address). Android/iOS use the phone's
  /// built-in geocoder; web, desktop and phones without one call this
  /// Nominatim-compatible server instead.
  static const String nominatimBaseUrl = 'https://nominatim.openstreetmap.org';

  /// Contact e-mail sent with Nominatim requests, as its usage policy asks.
  /// Optional — leave empty to omit.
  static const String nominatimEmail = '';

  /// LocationIQ replaces the free OpenStreetMap servers above (tiles and
  /// reverse geocoding) whenever a key is configured — see [locationIqKey].
  static const String locationIqBaseUrl = 'https://us1.locationiq.com/v1';
  static const String locationIqTileUrl =
      'https://{s}-tiles.locationiq.com/v3/streets/r/{z}/{x}/{y}.png';
  static const String locationIqAttribution =
      '© LocationIQ © OpenStreetMap contributors';
  static const String locationIqAttributionUrl =
      'https://locationiq.com/attribution';

  static double fontSizeExtraSmall = 10;
  static double fontSizeSmall = 12;
  static double fontSizeDefault = 14;
  static double fontSizeLarge = 16;
  static double fontSizeExtraLarge = 18;
  static double fontSizeOverLarge = 24;

  static const double paddingSizeExtraSmall = 5.0;
  static const double paddingSizeSmall = 10.0;
  static const double paddingSizeDefault = 15.0;
  static const double paddingSizeLarge = 20.0;
  static const double paddingSizeExtraLarge = 25.0;

  static const double radiusSmall = 5.0;
  static const double radiusDefault = 10.0;
  static const double radiusLarge = 15.0;
  static const double radiusExtraLarge = 20.0;

  /// Corner radius of an elevated card surface — matches the radius
  /// [CustomClickableWidget] paints, so nested content can clip to it exactly.
  static const double radiusCard = radiusLarge + 4;

  /// Minimum comfortable tap target for controls embedded in dense layouts
  /// (cards, list tiles). Keeps hit areas within accessibility limits.
  static const double minTapTarget = 40.0;

  /// Diameter of the tinted circle behind a status/result icon (empty states,
  /// auth outcome panels).
  static const double iconCircleSize = 88.0;

  /// Width/height of the brand logo on the splash screen.
  static const double splashLogoSize = 150.0;

  /// Icon glyph size inside [iconCircleSize].
  static const double iconSizeLarge = 44.0;

  /// Vertical gap between home sections.
  static const double spaceSection = 28.0;

  /// Bottom clearance so scrollable content / bottom bars are not hidden
  /// behind the floating bottom navigation bar.
  static const double bottomNavSpace = 90.0;

  // ── Booking UI tokens (shared with the customer app) ──
  static const double radiusSheet = 28.0;
  static const double avatarSize = 48.0;
  static const double mapPinSize = 40.0;
  static const double routeDotSize = 10.0;
  static const double sheetMaxHeightFactor = 0.62;

  /// Fare rules shown in the UI (BDT, whole numbers). The backend re-validates.
  static const int fareStep = 10;
  static const int minFare = 20;
  static const int maxFare = 5000;

  /// Demo value; replaced by `business_settings.bookingExpirySeconds`.
  static const int bookingExpirySeconds = 90;

  // ── Admin layout tokens ──
  static const double sidebarWidth = 248.0;
  static const double topBarHeight = 64.0;
  static const double adminMaxContentWidth = 1280.0;
  static const double tableRowHeight = 56.0;
  static const double tableHeaderHeight = 44.0;
  static const double statCardMinWidth = 200.0;
  static const double chartHeight = 160.0;
  static const double mapHeight = 260.0;
  static const double documentBoxHeight = 140.0;
  static const double dialogMaxWidth = 460.0;
  static const double filterFieldWidth = 220.0;
  static const double searchFieldWidth = 320.0;
  static const int pageSize = 8;
  static const double skeletonRowHeight = 44.0;
  static const double timelineDotSize = 12.0;
  static const double settingsFormMaxWidth = 720.0;
  static const double sidePanelWidth = 380.0;
  static const double chipVerticalPadding = 3.0;

  static List<LanguageModel> languages = [
    LanguageModel(imageUrl: Images.english, languageName: 'English', countryCode: 'US', languageCode: 'en'),
    LanguageModel(imageUrl: Images.bengali, languageName: 'Bengali', countryCode: 'BN', languageCode: 'bn'),
    LanguageModel(imageUrl: Images.arabic, languageName: 'العربية', countryCode: 'SA', languageCode: 'ar'),
  ];

  /// Shared Preferences Keys
  static const String countryCode = 'country_code';
  static const String languageCode = 'language_code';
  static const String theme = 'theme';

  /// "Remember me" on the sign-in form. These deliberately survive a logout —
  /// clearing them is only triggered by the user unticking the box.
  static const String rememberMe = 'remember_me';
  static const String rememberedEmail = 'remembered_email';
  static const String rememberedPassword = 'remembered_password';
}

class LanguageModel {
  String imageUrl;
  String languageName;
  String languageCode;
  String countryCode;

  LanguageModel({required this.imageUrl, required this.languageName, required this.countryCode, required this.languageCode});
}