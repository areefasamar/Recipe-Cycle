import 'package:flutter/material.dart';

/// All design tokens for Recipe Cycle live here.
/// Import this file and call AppTheme.light() to get the ThemeData.
abstract class AppTheme {
  // ── Brand colors ──────────────────────────────────────────────────
  static const Color primary     = Color(0xFF2E7D32); // forest green
  static const Color accent      = Color(0xFFFF8F3C); // warm orange
  static const Color background  = Color(0xFFFFF8EE); // cream
  static const Color surface     = Color(0xFFFFFFFF);
  static const Color cardSurface = Color(0xFFFFFDF7); // slightly warm white

  // ── Geometry ──────────────────────────────────────────────────────
  static const double cardRadius   = 24;
  static const double chipRadius   = 40; // fully-pill chips
  static const double buttonRadius = 16;

  // ── Spacing ───────────────────────────────────────────────────────
  static const double spaceXS = 4;
  static const double spaceS  = 8;
  static const double spaceM  = 16;
  static const double spaceL  = 24;
  static const double spaceXL = 32;

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: accent,
      background: background,
      surface: surface,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,

      // ── Typography ───────────────────────────────────────────────
      textTheme: const TextTheme(
        // Large screen headings
        displaySmall: TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        bodyLarge: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        labelLarge: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          letterSpacing: 0.2,
        ),
      ),

      // ── AppBar ───────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),

      // ── Cards ────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: Color(0xFFEDE8DF), width: 1),
        ),
        margin: const EdgeInsets.symmetric(
            horizontal: spaceM, vertical: spaceS),
      ),

      // ── Input fields ─────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1EDE4),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: spaceM, vertical: spaceM),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(chipRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(chipRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(chipRadius),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF9E9E9E),
          fontWeight: FontWeight.w400,
        ),
      ),

      // ── FilledButton ─────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: spaceXL, vertical: spaceM),
          elevation: 0,
        ),
      ),

      // ── ElevatedButton ───────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: surface,
          foregroundColor: primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
            side: const BorderSide(color: primary),
          ),
          textStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),

      // ── Chips ────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFEDE8DF),
        selectedColor: primary,
        labelStyle:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(chipRadius),
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: spaceS, vertical: spaceXS),
        side: BorderSide.none,
      ),

      // ── ExpansionTile ────────────────────────────────────────────
      expansionTileTheme: const ExpansionTileThemeData(
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        iconColor: primary,
        collapsedIconColor: primary,
        tilePadding: EdgeInsets.symmetric(
            horizontal: spaceM, vertical: spaceXS),
        childrenPadding:
            EdgeInsets.fromLTRB(spaceM, 0, spaceM, spaceM),
      ),

      // ── Divider ──────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: Color(0xFFEDE8DF),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
