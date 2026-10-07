import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Brand Palette ---
  static const Color primary = Color(0xFF8F86EF);
  static const Color deepPrimary = Color(0xFF2817D9);
  static const Color secondaryPurple = Color(0xFF9470EB);
  static const Color darkPurple = Color(0xFF21129B);
  static const Color mutedText = Color(0xFFB1BBC5);
  static const Color secondaryPurpleGray = Color(0xFF5E5892);

  // --- Light Liquid Glass Palette ---
  // Soft warm white-lavender base that makes glass stand out
  static const Color backgroundLight = Color(0xFFE8EAF6);
  static const Color surfaceLight = Colors.white;
  static const Color textLight = Color(0xFF1A1A3E);
  static const Color mutedTextLight = Color(0xFF6B7280);

  // --- Dark Liquid Glass Palette ---
  // Deep space indigo — rich enough for glass to pop against
  static const Color backgroundDark = Color(0xFF0F0F23);
  static const Color midDark = Color(0xFF16163A);
  static const Color surfaceDark = Color(0xFF1E1E4E);
  static const Color textDark = Color(0xFFF0F0FF);
  static const Color mutedTextDark = Color(0xFF8E8EAA);

  // --- Gradients ---
  static const LinearGradient lightBgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFD1D8FF), // soft periwinkle
      Color(0xFFE8D5FF), // soft lavender
      Color(0xFFC5DCF5), // soft sky
    ],
  );

  static const LinearGradient darkBgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0D0D2B), // near-black indigo
      Color(0xFF1A0B3B), // deep violet
      Color(0xFF0B1F3F), // deep midnight blue
    ],
  );

  // --- Glass Orb Accent (decorative blobs behind content) ---
  static const Color lightOrb1 = Color(0x558F86EF);
  static const Color lightOrb2 = Color(0x339470EB);
  static const Color darkOrb1 = Color(0x448F86EF);
  static const Color darkOrb2 = Color(0x332817D9);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: Colors.transparent,
      cardColor: Colors.white.withAlpha(120),
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondaryPurple,
        surface: surfaceLight,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(color: textLight, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.inter(color: textLight, fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.inter(color: textLight, fontWeight: FontWeight.w700),
        headlineMedium: GoogleFonts.inter(color: textLight, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.inter(color: textLight, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.inter(color: textLight, fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.inter(color: textLight),
        bodyMedium: GoogleFonts.inter(color: mutedTextLight),
        labelSmall: GoogleFonts.inter(color: mutedTextLight, fontSize: 11),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textLight),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: Colors.transparent,
      cardColor: Colors.white.withAlpha(18),
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondaryPurple,
        surface: surfaceDark,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(color: textDark, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.inter(color: textDark, fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.inter(color: textDark, fontWeight: FontWeight.w700),
        headlineMedium: GoogleFonts.inter(color: textDark, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.inter(color: textDark, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.inter(color: textDark, fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.inter(color: textDark),
        bodyMedium: GoogleFonts.inter(color: mutedTextDark),
        labelSmall: GoogleFonts.inter(color: mutedTextDark, fontSize: 11),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
    );
  }
}
