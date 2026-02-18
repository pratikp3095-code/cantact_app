import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF1A73E8);
  static const Color primaryDark = Color(0xFF1557B0);
  static const Color accentColor = Color(0xFF34A853);
  static const Color errorColor = Color(0xFFEA4335);
  static const Color surfaceColor = Color(0xFFF8F9FA);
  static const Color cardColor = Colors.white;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: accentColor,
        error: errorColor,
        surface: surfaceColor,
      ),
      textTheme: GoogleFonts.robotoTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: GoogleFonts.roboto(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF202124),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF5F6368)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 4,
        indicatorColor: primaryColor.withOpacity(0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            );
          }
          return GoogleFonts.roboto(
            fontSize: 12,
            color: const Color(0xFF5F6368),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryColor);
          }
          return const IconThemeData(color: Color(0xFF5F6368));
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F3F4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: Color(0xFF5F6368)),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE8EAED)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }

  static List<Color> avatarColors = [
    const Color(0xFF1A73E8),
    const Color(0xFF34A853),
    const Color(0xFFEA4335),
    const Color(0xFFFBBC04),
    const Color(0xFF9334E6),
    const Color(0xFF00BCD4),
    const Color(0xFFFF6D00),
    const Color(0xFF0097A7),
    const Color(0xFFE91E63),
    const Color(0xFF795548),
  ];

  static Color getAvatarColor(String name) {
    if (name.isEmpty) return avatarColors[0];
    final index = name.codeUnitAt(0) % avatarColors.length;
    return avatarColors[index];
  }
}
