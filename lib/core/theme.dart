import 'package:flutter/material.dart';
import '../shared/models.dart';

/// Builds the app-wide dark theme from the active group's theme config.
ThemeData buildAppTheme(GroupThemeConfig cfg) {
  final scheme = ColorScheme.fromSeed(
    seedColor: cfg.primary,
    brightness: Brightness.dark,
    primary: cfg.primary,
    secondary: cfg.accent,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    fontFamily: cfg.fontFamily,
    scaffoldBackgroundColor: const Color(0xFF0D0D12),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: cfg.fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1A1A22),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: cfg.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1A1A22),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: cfg.primary, width: 2),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF14141A),
      indicatorColor: cfg.primary.withValues(alpha: 0.25),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
  );
}
