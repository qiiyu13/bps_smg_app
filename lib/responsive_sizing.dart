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
  double get horizontalPadding => _select(12, 16, 20);

  // Bottom navigation
  double get bottomNavHeight => _select(60, 66, 72);
  double get bottomNavIconSize => _select(22, 24, 26);
  double get bottomNavPadding => _select(12, 16, 20);
  double get bottomNavLabelSize => _select(10, 11, 12);

  // Header section
  double get headerLogoSize => _select(28, 30, 32);
  double get headerTitleSize => _select(14, 15, 16);
  double get headerSubtitleSize => _select(10, 11, 12);
  double get headerLogoPadding => _select(6, 7, 8);

  // Search bar
  double get searchIconSize => _select(18, 20, 22);
  double get searchClearIconSize => _select(16, 18, 20);
  double get searchFontSize => _select(12, 13, 14);
  double get searchPadding => _select(12, 14, 16);
  double get searchBarHeight => horizontalPadding + (searchPadding * 2) + 20;

  // Stats cards
  double get statsCardHeight => _select(120, 140, 160);
  double get statsCardPadding => _select(12, 16, 20);
  double get statsIconContainerSize => _select(44, 50, 56);
  double get statsIconSize => _select(22, 25, 28);
  double get statsValueFontSize => _select(22, 24, 28);
  double get statsLabelFontSize => _select(11, 12, 13);
  double get statsChangeFontSize => _select(9, 10, 11);
  double get statsChangeIconSize => _select(12, 13, 14);
  double get statsMiniChartWidth => _select(50, 55, 60);

  // Category grid
  double get categoryAspectRatio => _select(2.6, 3, 3.4);
  double get gridSpacing => _select(8, 10, 12);

  // Category cards
  double get categoryCardPadding => _select(8, 10, 12);
  double get categoryIconContainerPadding => _select(7, 8, 10);
  double get categoryIconSize => _select(20, 22, 24);
  double get categoryLabelFontSize => _select(13, 14, 15);
  double get categorySubLabelFontSize => _select(9, 10, 11);
  double get categoryArrowSize => _select(12, 13, 14);

  // Section titles
  double get sectionTitleSize => _select(15, 16, 18);
  double get sectionIconSize => _select(18, 20, 22);
  double get groupTitleSize => _select(13, 14, 15);
  double get groupIconSize => _select(14, 16, 18);
  double get groupIconPadding => _select(4, 5, 6);

  // Page indicators
  double get pageIndicatorActiveWidth => _select(18, 20, 24);
  double get pageIndicatorHeight => _select(6, 7, 8);

  // Spacing
  double get sectionSpacing => _select(20, 24, 32);
  double get itemSpacing => _select(8, 10, 12);
}
