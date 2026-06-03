import 'package:flutter/material.dart';

/// Responsive sizing helper for adapting UI to different screen widths.
///
/// Breakpoints:
/// - Very Small: <340px (e.g., 320px phones)
/// - Small: 340-399px (e.g., 360px phones)
/// - Normal: 400px+
class ResponsiveSizing {
  final double screenWidth;

  ResponsiveSizing(BuildContext context)
      : screenWidth = MediaQuery.of(context).size.width;

  /// Create from explicit width (useful for testing)
  ResponsiveSizing.fromWidth(this.screenWidth);

  // Breakpoint checks
  bool get isVerySmall => screenWidth < 340;
  bool get isSmall => screenWidth >= 340 && screenWidth < 400;
  bool get isNormal => screenWidth >= 400;

  // Helper to select value based on breakpoint
  T _select<T>(T verySmall, T small, T normal) {
    if (isVerySmall) return verySmall;
    if (isSmall) return small;
    return normal;
  }

  // Layout padding
  double get horizontalPadding => _select(12.0, 16.0, 20.0);

  // Bottom navigation
  double get bottomNavHeight => _select(60.0, 66.0, 72.0);
  double get bottomNavIconSize => _select(22.0, 24.0, 26.0);
  double get bottomNavPadding => _select(12.0, 16.0, 20.0);
  double get bottomNavLabelSize => _select(10.0, 11.0, 12.0);

  // Header section
  double get headerLogoSize => _select(28.0, 30.0, 32.0);
  double get headerTitleSize => _select(14.0, 15.0, 16.0);
  double get headerSubtitleSize => _select(10.0, 11.0, 12.0);
  double get headerLogoPadding => _select(6.0, 7.0, 8.0);

  // Search bar
  double get searchIconSize => _select(18.0, 20.0, 22.0);
  double get searchClearIconSize => _select(16.0, 18.0, 20.0);
  double get searchFontSize => _select(12.0, 13.0, 14.0);
  double get searchPadding => _select(12.0, 14.0, 16.0);
  double get searchBarHeight => horizontalPadding + (searchPadding * 2) + 20;

  // Stats cards
  double get statsCardHeight => _select(120.0, 140.0, 160.0);
  double get statsCardPadding => _select(12.0, 16.0, 20.0);
  double get statsIconContainerSize => _select(44.0, 50.0, 56.0);
  double get statsIconSize => _select(22.0, 25.0, 28.0);
  double get statsValueFontSize => _select(22.0, 24.0, 28.0);
  double get statsLabelFontSize => _select(11.0, 12.0, 13.0);
  double get statsChangeFontSize => _select(9.0, 10.0, 11.0);
  double get statsChangeIconSize => _select(12.0, 13.0, 14.0);
  double get statsMiniChartWidth => _select(50.0, 55.0, 60.0);

  // Category grid
  double get categoryAspectRatio => _select(2.6, 3.0, 3.4);
  double get gridSpacing => _select(8.0, 10.0, 12.0);

  // Category cards
  double get categoryCardPadding => _select(8.0, 10.0, 12.0);
  double get categoryIconContainerPadding => _select(7.0, 8.0, 10.0);
  double get categoryIconSize => _select(20.0, 22.0, 24.0);
  double get categoryLabelFontSize => _select(13.0, 14.0, 15.0);
  double get categorySubLabelFontSize => _select(9.0, 10.0, 11.0);
  double get categoryArrowSize => _select(12.0, 13.0, 14.0);

  // Section titles
  double get sectionTitleSize => _select(15.0, 16.0, 18.0);
  double get sectionIconSize => _select(18.0, 20.0, 22.0);
  double get groupTitleSize => _select(13.0, 14.0, 15.0);
  double get groupIconSize => _select(14.0, 16.0, 18.0);
  double get groupIconPadding => _select(4.0, 5.0, 6.0);

  // Page indicators
  double get pageIndicatorActiveWidth => _select(18.0, 20.0, 24.0);
  double get pageIndicatorHeight => _select(6.0, 7.0, 8.0);

  // Spacing
  double get sectionSpacing => _select(20.0, 24.0, 32.0);
  double get itemSpacing => _select(8.0, 10.0, 12.0);
}
