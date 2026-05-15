import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MushTheme {
  static const primaryGreen = Color(0xFF1B3022);
  static const surfaceCream = Color(0xFFFCF9F4);
  static const accentToxic = Color(0xFFD97D54);
  static const coinGold = Color(0xFFD4AF37);
  static const cardBg = Colors.white;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: surfaceCream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        surface: surfaceCream,
        primary: primaryGreen,
        secondary: accentToxic,
        onPrimary: Colors.white,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
            fontSize: 32, fontWeight: FontWeight.bold, color: primaryGreen),
        headlineMedium: GoogleFonts.plusJakartaSans(
            fontSize: 24, fontWeight: FontWeight.bold, color: primaryGreen),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: primaryGreen,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
