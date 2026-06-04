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

/// Purple accent - Used for chart series, IPG, IDG indicators
const Color bpsPurple = Color(0xFF7B1FA2);

/// Teal accent - Used for chart series, alternate indicators
const Color bpsTeal = Color(0xFF1ABC9C);

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
  fontFamily: 'Inter',
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
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontFamily: 'PlusJakartaSans'),
    displayMedium: TextStyle(fontFamily: 'PlusJakartaSans'),
    displaySmall: TextStyle(fontFamily: 'PlusJakartaSans'),
    headlineLarge: TextStyle(fontFamily: 'PlusJakartaSans'),
    headlineMedium: TextStyle(fontFamily: 'PlusJakartaSans'),
    headlineSmall: TextStyle(fontFamily: 'PlusJakartaSans'),
    titleLarge: TextStyle(fontFamily: 'PlusJakartaSans'),
    titleMedium: TextStyle(fontFamily: 'PlusJakartaSans'),
    titleSmall: TextStyle(fontFamily: 'PlusJakartaSans'),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: bpsBlue,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontFamily: 'PlusJakartaSans',
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
        fontFamily: 'PlusJakartaSans',
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: bpsBlue,
      textStyle: const TextStyle(
        fontFamily: 'PlusJakartaSans',
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
    fontFamily: 'PlusJakartaSans',
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
    fontFamily: 'PlusJakartaSans',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: bpsTextPrimary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: bpsTextPrimary,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 11,
    color: bpsTextLabel,
  );

  static const TextStyle statValue = TextStyle(
    fontFamily: 'PlusJakartaSans',
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

/// Slide-based page transition with parallax depth.
///
/// New page slides in from the right; the page beneath shifts slightly left,
/// creating a layered depth effect. No fade.
class ParallaxPageTransitionsBuilder extends PageTransitionsBuilder {
  const ParallaxPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final foregroundSlide = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.fastOutSlowIn,
    ));

    final backgroundSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.3, 0.0),
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.fastOutSlowIn,
    ));

    // Scrim: dim this page as it recedes behind a pushed page.
    final scrim = Tween<double>(begin: 0.0, end: 0.18).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.fastOutSlowIn,
    ));

    return SlideTransition(
      position: backgroundSlide,
      child: SlideTransition(
        position: foregroundSlide,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Leading-edge shadow — glued just left of the page. Off-screen at
            // rest (offset 0), only visible while the page slides over the one below.
            Positioned(
              top: 0,
              bottom: 0,
              left: -10,
              width: 10,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.transparent, Color(0x33000000)],
                  ),
                ),
              ),
            ),
            child,
            Positioned.fill(
              child: IgnorePointer(
                child: FadeTransition(
                  opacity: scrim,
                  child: const ColoredBox(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
