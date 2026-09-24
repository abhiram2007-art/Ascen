import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

ThemeData get ascendDarkTheme {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.surface,
      primary: AppColors.cyan,
      secondary: AppColors.purple,
      tertiary: AppColors.gold,
      onSurface: Colors.white,
      onPrimary: AppColors.background,
    ).copyWith(),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.cyan,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface.withValues(alpha: 0.8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.cyan.withValues(alpha: 0.2), width: 1),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold),
      displayMedium: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold),
      displaySmall: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold),
      headlineLarge: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold),
      headlineMedium: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold),
      headlineSmall: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.w600),
      titleSmall: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.inter(color: Colors.white),
      bodyMedium: GoogleFonts.inter(color: Colors.white),
      bodySmall: GoogleFonts.inter(color: Colors.white70),
      labelLarge: GoogleFonts.inter(color: AppColors.cyan, fontWeight: FontWeight.w500),
      labelMedium: GoogleFonts.inter(color: Colors.white70),
      labelSmall: GoogleFonts.inter(color: Colors.white54),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.cyan.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.cyan),
      ),
      labelStyle: const TextStyle(color: Colors.grey),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.cyan,
        foregroundColor: AppColors.background,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 8,
        shadowColor: AppColors.cyan.withValues(alpha: 0.5),
      ),
    ),
  );
}
