import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BduColors {
  static const Color primary = Color(0xFF25579A);
  static const Color secondary = Color(0xFF469C23);
  static const Color neutral900 = Color(0xFF111827);
  static const Color neutral600 = Color(0xFF4B5563);
  static const Color neutral100 = Color(0xFFF3F4F6);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
}

class BduTheme {
  static ThemeData get light {
    return ThemeData(
      primaryColor: BduColors.primary,
      colorScheme: ColorScheme.light(
        primary: BduColors.primary,
        secondary: BduColors.secondary,
        error: BduColors.error,
        surface: BduColors.neutral100,
      ),
      scaffoldBackgroundColor: BduColors.neutral100,
      fontFamily: GoogleFonts.montserrat().fontFamily,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          fontSize: 28,
          color: BduColors.neutral900,
        ),
        titleLarge: GoogleFonts.montserrat(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: BduColors.neutral900,
        ),
        bodyLarge: GoogleFonts.openSans(
          fontWeight: FontWeight.w400,
          fontSize: 16,
          color: BduColors.neutral600,
        ),
        bodyMedium: GoogleFonts.openSans(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: BduColors.neutral600,
        ),
        labelLarge: GoogleFonts.montserrat(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: BduColors.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: BduColors.primary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: const BorderSide(color: BduColors.primary),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        margin: const EdgeInsets.all(12),
        color: Colors.white,
        shadowColor: Colors.black12,
      ),
    );
  }
}
