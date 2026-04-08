import 'package:flutter/material.dart';

/// Unified BPS (Badan Pusat Statistik) Theme
///
/// This file contains all color definitions, text styles, and theme configurations
/// for the BPS Kota Semarang application to ensure consistency across all screens.

// ============================================
// PRIMARY COLOR PALETTE
// ============================================

/// Primary BPS Blue - Used for main branding, headers, primary actions
const Color bpsBlue = Color(0xFF2E99D6);

/// BPS Orange - Used for warnings, secondary highlights, economic indicators
const Color bpsOrange = Color(0xFFE88D34);

/// BPS Green - Used for success states, positive trends, social indicators
const Color bpsGreen = Color(0xFF7DBD42);

/// BPS Red - Used for errors, alerts, critical indicators
const Color bpsRed = Color(0xFFEF4444);

// ============================================
// NEUTRAL COLORS
// ============================================

/// Background color for screens
const Color bpsBackground = Color(0xFFF5F5F5);

/// Card background color
const Color bpsCardBg = Color(0xFFFFFFFF);

/// Primary text color (headings, important text)
const Color bpsTextPrimary = Color(0xFF333333);

/// Secondary text color (descriptions, labels)
const Color bpsTextSecondary = Color(0xFF808080);

/// Tertiary/label text color (hints, disabled)
const Color bpsTextLabel = Color(0xFFA0A0A0);

/// Border color for cards and inputs
const Color bpsBorder = Color(0xFFE0E0E0);

// ============================================
// GROUP-SPECIFIC COLORS
// ============================================

/// Color for Economic indicators group
const Color bpsEconomicColor = bpsBlue;

/// Color for Social indicators group
const Color bpsSocialColor = bpsGreen;

/// Color for Development indices group
const Color bpsDevelopmentColor = bpsOrange;

/// Map of group keys to their colors
final Map<String, Color> bpsGroupColors = {
  'Economic': bpsEconomicColor,
  'Social': bpsSocialColor,
  'Development': bpsDevelopmentColor,
};

/// Map of group keys to their light/background colors
final Map<String, Color> bpsGroupLightColors = {
  'Economic': bpsEconomicColor.withOpacity(0.1),
  'Social': bpsSocialColor.withOpacity(0.1),
  'Development': bpsDevelopmentColor.withOpacity(0.1),
};

// ============================================
// STAT CARD COLORS
// ============================================

/// Map of stat card types to their accent colors
final Map<String, Color> bpsStatCardColors = {
  'Penduduk': bpsBlue,
  'IPM': bpsGreen,
  'Kemiskinan': bpsOrange,
  'Inflasi': bpsRed,
  'Ekonomi': bpsBlue,
  'TenagaKerja': bpsGreen,
  'Pendidikan': bpsOrange,
  'SDGs': bpsBlue,
  'IPG': bpsGreen,
  'IDG': bpsOrange,
};

// ============================================
// CONTACT COLORS
// ============================================

/// Map of contact types to their colors
final Map<String, Color> bpsContactColors = {
  'Website': bpsBlue,
  'Email': bpsOrange,
  'Telepon': bpsGreen,
  'Alamat': bpsRed,
};

// ============================================
// THEME DATA
// ============================================

/// Main app theme
final ThemeData bpsTheme = ThemeData(
  useMaterial3: true,
  primaryColor: bpsBlue,
  scaffoldBackgroundColor: bpsBackground,
  colorScheme: ColorScheme.light(
    primary: bpsBlue,
    secondary: bpsOrange,
    surface: bpsCardBg,
    background: bpsBackground,
    error: bpsRed,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: bpsTextPrimary,
    onBackground: bpsTextPrimary,
    onError: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: bpsBlue,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
  ),
  cardTheme: CardThemeData(
    color: bpsCardBg,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: bpsCardBg,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: bpsBlue, width: 1.5),
    ),
    hintStyle: const TextStyle(color: bpsTextLabel),
    prefixIconColor: bpsBlue,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: bpsCardBg,
    selectedItemColor: bpsBlue,
    unselectedItemColor: bpsTextLabel,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: bpsBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      textStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: bpsBlue,
      textStyle: const TextStyle(
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: bpsBackground,
    selectedColor: bpsBlue.withOpacity(0.2),
    labelStyle: const TextStyle(color: bpsTextPrimary),
    secondaryLabelStyle: const TextStyle(color: bpsBlue),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  dividerTheme: const DividerThemeData(
    color: bpsBorder,
    thickness: 1,
    space: 1,
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: bpsTextPrimary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    contentTextStyle: const TextStyle(color: Colors.white),
  ),
);

// ============================================
// TEXT STYLES
// ============================================

class BPSTextStyles {
  static const TextStyle headerTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  static const TextStyle headerSubtitle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.white70,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: bpsTextPrimary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: bpsTextPrimary,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 11,
    color: bpsTextLabel,
  );

  static const TextStyle statValue = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: bpsTextPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle statLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: bpsTextSecondary,
  );

  static const TextStyle statChangePositive = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: bpsGreen,
  );

  static const TextStyle statChangeNegative = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: bpsOrange,
  );
}

// ============================================
// SHADOWS
// ============================================

class BPSShadows {
  static BoxShadow get cardShadow => BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 8,
        offset: const Offset(0, 2),
      );

  static BoxShadow get elevatedShadow => BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 20,
        offset: const Offset(0, 4),
      );

  static BoxShadow get headerShadow => BoxShadow(
        color: bpsBlue.withOpacity(0.2),
        blurRadius: 30,
        offset: const Offset(0, 10),
      );

  static BoxShadow get bottomNavShadow => BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 20,
        offset: const Offset(0, -4),
      );

  static BoxShadow statCardShadow(Color color) => BoxShadow(
        color: color.withOpacity(0.1),
        blurRadius: 15,
        offset: const Offset(0, 6),
      );
}

// ============================================
// DECORATIONS
// ============================================

class BPSDecorations {
  static BoxDecoration cardDecoration({Color? borderColor}) => BoxDecoration(
        color: bpsCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor ?? bpsBorder,
          width: 1.5,
        ),
        boxShadow: [BPSShadows.cardShadow],
      );

  static BoxDecoration statCardDecoration(Color accentColor) => BoxDecoration(
        color: bpsCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [BPSShadows.statCardShadow(accentColor)],
      );

  static BoxDecoration iconContainerDecoration(Color color) => BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      );

  static BoxDecoration groupIconContainerDecoration(Color color) =>
      BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      );
}
