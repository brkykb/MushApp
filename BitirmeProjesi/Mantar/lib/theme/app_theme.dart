import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // DÜZELTME 1: "lightTheme" (Yazım hatası giderildi)
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,

    colorScheme: const ColorScheme(
      brightness: Brightness.light,

      primary: AppColors.primary,
      onPrimary: Colors.white,

      secondary: AppColors.secondary,
      // DÜZELTME 2: İkincil renk üstüne yeşil değil, Beyaz yazı
      onSecondary: Colors.white,

      tertiary: AppColors.accent,
      onTertiary: Colors.white,

      error: AppColors.error,
      onError: Colors.white,

      surface: AppColors.surface,
      // DÜZELTME 3: Kart üzerindeki genel yazılar Gri olsun (Okunabilirlik için)
      onSurface: AppColors.textPrimary,
    ),

    appBarTheme: AppBarTheme(
      // const kaldırıldı (GoogleFonts const değildir)
      backgroundColor: AppColors.primary,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      // DÜZELTME 4: AppBar başlığı da Poppins olsun
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),

      headlineMedium: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),

      titleMedium: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),

      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      ),

      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  );
}
