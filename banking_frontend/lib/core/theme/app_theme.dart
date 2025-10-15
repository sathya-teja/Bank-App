// lib/core/theme/app_theme.dart
// Fixed to use CardThemeData where required by this Flutter SDK version.
// Uses ColorScheme.fromSeed for consistent light/dark palettes and Montserrat typography.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary brand/accent colors (seed). Keep these stable.
  static const Color primary = Color(0xFF0D1B2A); // deep navy (brand)
  static const Color accent = Color(0xFF1B998B);  // teal accent (seed)

  // Light-specific extras (kept for reference)
  static const Color lightBackground = Color(0xFFF7F9FC);
}

class AppTheme {
  // Common text theme builder using Montserrat and the given colorScheme.
  static TextTheme _textThemeFrom(ColorScheme scheme, TextTheme base) {
    final baseGoogle = GoogleFonts.montserratTextTheme(base);

    // Apply colors from color scheme to ensure readable text in both modes.
    return baseGoogle.copyWith(
      displayLarge: baseGoogle.displayLarge?.copyWith(color: scheme.onBackground),
      displayMedium: baseGoogle.displayMedium?.copyWith(color: scheme.onBackground),
      displaySmall: baseGoogle.displaySmall?.copyWith(color: scheme.onBackground),
      headlineLarge: baseGoogle.headlineLarge?.copyWith(color: scheme.onBackground),
      headlineMedium: baseGoogle.headlineMedium?.copyWith(color: scheme.onBackground),
      headlineSmall: baseGoogle.headlineSmall?.copyWith(color: scheme.onBackground),
      titleLarge: baseGoogle.titleLarge?.copyWith(color: scheme.onBackground),
      titleMedium: baseGoogle.titleMedium?.copyWith(color: scheme.onBackground),
      titleSmall: baseGoogle.titleSmall?.copyWith(color: scheme.onBackground),
      bodyLarge: baseGoogle.bodyLarge?.copyWith(color: scheme.onBackground),
      bodyMedium: baseGoogle.bodyMedium?.copyWith(color: scheme.onBackground),
      bodySmall: baseGoogle.bodySmall?.copyWith(color: scheme.onBackground),
      labelLarge: baseGoogle.labelLarge?.copyWith(color: scheme.onPrimary),
      labelSmall: baseGoogle.labelSmall?.copyWith(color: scheme.onPrimary),
    );
  }

  static ThemeData get lightTheme {
    // Create a light ColorScheme using accent as the seed color.
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.light,
      // Optionally you can override some colors here if desired:
      // primary: AppColors.primary,
    );

    final ThemeData base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
    );

    return base.copyWith(
      // Scaffold & surfaces
      scaffoldBackgroundColor: colorScheme.background,
      canvasColor: colorScheme.background,
      // Text
      textTheme: _textThemeFrom(colorScheme, base.textTheme),
      // AppBar
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
      ),
      // Cards (use CardThemeData for compatibility)
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceVariant,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.outline)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.primary, width: 1.5)),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.8)),
      ),
      // Elevated buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
      ),
      // Text buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colorScheme.primary, textStyle: GoogleFonts.montserrat()),
      ),
      // Icon theme
      iconTheme: IconThemeData(color: colorScheme.onBackground),
      // Floating action button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      // Bottom navigation / navigation bars
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
      ),
      // Divider color
      dividerColor: colorScheme.outline,
      // Apply the colorScheme to material widgets that read colorScheme by default
      colorScheme: colorScheme,
    );
  }

  static ThemeData get darkTheme {
    // Create a dark ColorScheme (seeded from accent) to get good palette for dark mode.
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.dark,
    );

    final ThemeData base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
    );

    return base.copyWith(
      scaffoldBackgroundColor: colorScheme.background,
      canvasColor: colorScheme.background,
      textTheme: _textThemeFrom(colorScheme, base.textTheme),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.primary.withOpacity(0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceVariant,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.outline)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.primary, width: 1.5)),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.9)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colorScheme.primary, textStyle: GoogleFonts.montserrat()),
      ),
      iconTheme: IconThemeData(color: colorScheme.onBackground),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
      ),
      dividerColor: colorScheme.outline,
      colorScheme: colorScheme,
    );
  }
}
