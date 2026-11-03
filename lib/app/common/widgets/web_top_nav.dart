import 'dart:math' as math;


import 'package:appwrite_boilerplate/app/controllers/localization_controller.dart';
import 'package:appwrite_boilerplate/app/resources/colors.dart';
import 'package:appwrite_boilerplate/app/resources/images.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:appwrite_boilerplate/app/resources/text_style.dart';
import 'package:appwrite_boilerplate/app/helper/dashboard_tab_bus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Shared web/desktop top navigation bar.
///
/// Layout: [Brand] [Home] [Notifications] ────── [Language] [Theme] | [Menu]
///
/// [selectedIndex] highlights the active destination (pass null on sub-pages so
/// nothing is highlighted). Destinations map to [DashboardTabs] indices.
class WebTopNav extends StatelessWidget implements PreferredSizeWidget {
  final int? selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onMenuTap;

  const WebTopNav({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onMenuTap,
  });

  /// Whether the web top-nav shell should be shown: the web platform at
  /// desktop width only. Mobile, tablets and narrow browser windows keep the
  /// app's regular mobile chrome (own app bars + bottom navigation).
  static bool isEnabled(BuildContext context) =>
      kIsWeb && MediaQuery.of(context).size.width >= wideBreakpoint;

  /// Width at which the app takes its desktop shape. Exposed so page bodies
  /// switch at the same width the chrome does.
  static const double wideBreakpoint = 900;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  /// Width of the bar's centred content band.
  ///
  /// Page bodies cap themselves to this so the logo and the first column of
  /// whatever is below it share a left edge. The bar's own background stays
  /// full-bleed; only its contents are held to the band.
  static const double maxContentWidth = 1200;

  /// Leading inset of the bar's contents inside [maxContentWidth].
  ///
  /// Pages must apply the same inset, not just the same cap: matching one
  /// without the other still leaves the columns and the logo a few pixels
  /// apart.
  static const double contentInset = 20;

  /// The inset used once the band is too narrow to carry labels.
  static const double _compactContentInset = 12;

  /// Below this the destinations drop their labels for icons + tooltips.
  static const double _labelBreakpoint = 1080;

  /// The bar's leading inset at a given band width.
  ///
  /// The bar tightens up when it can no longer fit its labels, so a page body
  /// that always used [contentInset] would drift 8px out of alignment in that
  /// range. Ask this instead of assuming.
  static double contentInsetFor(double bandWidth) =>
      bandWidth >= _labelBreakpoint ? contentInset : _compactContentInset;

  /// Inset a page body should apply *inside* [maxContentWidth].
  ///
  /// For bodies that centre their content in a `ConstrainedBox` sized to the
  /// band. Bodies that instead pad a full-width scroll surface want
  /// [bodySidePadding], which folds the letterbox gutter in.
  static double bandInsetFor(double screenWidth) =>
      contentInsetFor(math.min(screenWidth, maxContentWidth));

  /// Side padding a page body should use so its content lines up with the bar.
  ///
  /// Beyond the cap this is the letterbox gutter plus the bar's inset; inside
  /// it, just the inset. Continuous at the cap, so nothing jumps as the window
  /// crosses it. Below [wideBreakpoint] there is no bar to align to and
  /// [compactGutter] applies — pages differ there (e.g. 16 on lists, 20 on
  /// cards), so the caller says which.
  static double bodySidePadding(
    double screenWidth, {
    double compactGutter = 16,
  }) {
    if (screenWidth < wideBreakpoint) return compactGutter;
    final inset = contentInsetFor(math.min(screenWidth, maxContentWidth));
    return math.max(inset, (screenWidth - maxContentWidth) / 2 + inset);
  }

  /// Gap between neighbouring controls inside one zone.
  static const double _itemGap = 4;

  /// Gap between zones — wide enough that the eye reads them as separate
  /// groups rather than one undifferentiated row of icons.
  static const double _groupGap = 14;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: context.cardBackground,
      elevation: 0.5,
      shadowColor: isDark
          ? Colors.black.withValues(alpha: 0.4)
          : Colors.black.withValues(alpha: 0.08),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxContentWidth),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Labels only once there is genuinely room for them. The old
                // 720 threshold was set when the bar carried fewer controls;
                // with three destinations plus language and theme it packed
                // the row solid and squeezed the search field to a stub.
                // Below this, destinations fall back to icons + tooltips.
                final bool showLabels =
                    constraints.maxWidth >= _labelBreakpoint;
                return Padding(
                  padding: EdgeInsets.only(
                    left: contentInsetFor(constraints.maxWidth),
                  ),
                  child: SizedBox(
                    height: 64,
                    child: Row(
                      children: [
                        // Brand — capped so it never crowds the nav items.
                        // Clicking it goes Home from anywhere, like the Home
                        // destination; already on Home, it scrolls to top.
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 160),
                          child: Tooltip(
                            message: 'home'.tr,
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  onDestinationSelected(0);
                                  DashboardTabs.requestHomeScrollToTop();
                                },
                                child: ShaderMask(
                                  shaderCallback: (bounds) => ColorResource
                                      .primaryGradient
                                      .createShader(bounds),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        Images.logo,
                                        height: 28,
                                        cacheHeight: 30,
                                      ),
                                      const SizedBox(width: 8),

                                      Text(
                                        Constants.appName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: poppinsBold.copyWith(
                                          fontSize: Constants.fontSizeOverLarge,
                                          color: ColorResource.textWhite,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: _groupGap),

                        // ── Zone 1: destinations ──
                        // Indices match DashboardTabs.names.
                        _navItem(Icons.home_rounded, 'home'.tr, 0, showLabels),
                        _navItem(
                          Icons.notifications_rounded,
                          'notifications'.tr,
                          1,
                          showLabels,
                        ),

                        const Spacer(),

                        // ── Zone 3: preferences, then actions ──
                        const SizedBox(width: _groupGap),
                        _LanguageMenu(showLabel: showLabels),
                        _themeToggle(),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: _groupGap,
                            vertical: 16,
                          ),
                          child: VerticalDivider(
                            width: 1,
                            color: context.textLight.withValues(alpha: 0.25),
                          ),
                        ),
                        _menuButton(),
                        const SizedBox(width: _itemGap),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Light/dark theme switch. Rebuilds on [LocalizationController] so the icon
  /// and tooltip track the active theme; the label names the mode tapping
  /// switches *to*.
  Widget _themeToggle() {
    return GetBuilder<LocalizationController>(
      builder: (localizationController) {
        final isDark = localizationController.darkTheme;
        return Padding(
          padding: const EdgeInsets.only(left: _itemGap),
          child: Tooltip(
            message: isDark ? 'light_mode'.tr : 'dark_mode'.tr,
            child: InkWell(
              onTap: () {
                localizationController.toggleTheme();
              },
              borderRadius: BorderRadius.circular(Constants.radiusLarge),
              hoverColor: ColorResource.primaryDark.withValues(alpha: 0.06),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  size: 22,
                  color: ColorResource.textSecondary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _menuButton() {
    return Tooltip(
      message: 'menu'.tr,
      child: InkWell(
        onTap: onMenuTap,
        borderRadius: BorderRadius.circular(Constants.radiusLarge),
        hoverColor: ColorResource.primaryDark.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            Icons.menu_rounded,
            size: 22,
            color: ColorResource.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index, bool showLabel) {
    final isSelected = selectedIndex == index;
    final color = isSelected
        ? ColorResource.primaryDark
        : ColorResource.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(left: _itemGap),
      child: Tooltip(
        // Only when the label is hidden — a tooltip repeating a visible label
        // is noise, and an empty message still builds a Tooltip.
        message: showLabel ? '' : label,
        child: InkWell(
          onTap: () => onDestinationSelected(index),
          borderRadius: BorderRadius.circular(Constants.radiusLarge),
          hoverColor: ColorResource.primaryDark.withValues(alpha: 0.06),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: showLabel ? 14 : 10,
              vertical: 10,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 22),
                if (showLabel) ...[
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: (isSelected ? poppinsBold : poppinsMedium).copyWith(
                      fontSize: Constants.fontSizeDefault,
                      color: color,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Language switcher for the web header.
///
/// A [PopupMenuButton] rather than a hand-rolled overlay: it brings correct
/// anchoring, keyboard navigation, focus handling and outside-tap dismissal
/// for free — all things a bespoke dropdown in a header tends to get wrong.
///
/// The trigger shows the active language's flag plus its code (EN / BN / AR)
/// so the current state is readable without opening anything. The code is
/// dropped on narrow windows, where the header is already tight.
class _LanguageMenu extends StatelessWidget {
  final bool showLabel;

  const _LanguageMenu({required this.showLabel});

  static const double _flagWidth = 22;
  static const double _flagHeight = 16;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocalizationController>(
      builder: (localizationController) {
        final languages = Constants.languages;

        // Derived from the live locale rather than the controller's stored
        // index, so the trigger still reads correctly if the language was
        // restored from preferences rather than picked in this session.
        final currentCode = localizationController.locale.languageCode;
        final currentIndex = languages.indexWhere(
          (l) => l.languageCode == currentCode,
        );
        final selected = languages[currentIndex < 0 ? 0 : currentIndex];

        return Tooltip(
          message: 'select_language'.tr,
          child: PopupMenuButton<int>(
            tooltip: '',
            position: PopupMenuPosition.under,
            offset: const Offset(0, 8),
            color: context.cardBackground,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Constants.radiusLarge),
              side: BorderSide(color: context.textLight.withValues(alpha: 0.2)),
            ),
            onSelected: (index) =>
                _select(localizationController, index, languages[index]),
            itemBuilder: (context) => [
              for (var i = 0; i < languages.length; i++)
                PopupMenuItem<int>(
                  value: i,
                  child: _MenuRow(
                    language: languages[i],
                    isSelected:
                        languages[i].languageCode == selected.languageCode,
                  ),
                ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _flag(selected),
                  if (showLabel) ...[
                    const SizedBox(width: 6),
                    Text(
                      selected.languageCode.toUpperCase(),
                      style: poppinsMedium.copyWith(
                        fontSize: Constants.fontSizeSmall,
                        color: ColorResource.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(width: 2),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: ColorResource.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Mirrors the language screen's flow so both entry points behave the same:
  /// remember the index, then swap the locale (which also flips text direction
  /// for Arabic and persists the choice).
  void _select(
    LocalizationController controller,
    int index,
    LanguageModel language,
  ) {
    controller.setSelectLanguageIndex(index);
    controller.setLanguage(Locale(language.languageCode, language.countryCode));
  }

  static Widget _flag(LanguageModel language) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Image.asset(
        language.imageUrl,
        width: _flagWidth,
        height: _flagHeight,
        fit: BoxFit.cover,
        // Arabic ships with a placeholder world asset; any missing flag falls
        // back to a glyph rather than a broken-image box.
        errorBuilder: (context, error, _) => Icon(
          Icons.language_rounded,
          size: _flagWidth,
          color: ColorResource.textSecondary,
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final LanguageModel language;
  final bool isSelected;

  const _MenuRow({required this.language, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _LanguageMenu._flag(language),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            language.languageName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: (isSelected ? poppinsBold : poppinsRegular).copyWith(
              fontSize: Constants.fontSizeDefault,
              color: isSelected
                  ? ColorResource.primaryDark
                  : context.textPrimary,
            ),
          ),
        ),
        if (isSelected)
          const Icon(
            Icons.check_rounded,
            size: 18,
            color: ColorResource.primaryDark,
          ),
      ],
    );
  }
}
