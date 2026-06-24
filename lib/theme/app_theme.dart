import 'package:flutter/material.dart';

enum AppThemeChoice {
  lightBlue,
  darkGreen;

  String get label => switch (this) {
        AppThemeChoice.lightBlue => 'Light (white & blue)',
        AppThemeChoice.darkGreen => 'Dark (black & green)',
      };

  static AppThemeChoice fromValue(String value) => AppThemeChoice.values
      .firstWhere((e) => e.name == value, orElse: () => AppThemeChoice.darkGreen);
}

class AppTheme {
  AppTheme._();

  static ThemeData themeFor(AppThemeChoice choice) => switch (choice) {
        AppThemeChoice.lightBlue => _build(_lightBlueScheme),
        AppThemeChoice.darkGreen => _build(_darkGreenScheme),
      };

  static final ColorScheme _lightBlueScheme = ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.light,
  ).copyWith(
    surface: Colors.white,
    surfaceDim: const Color(0xFFF0F0F0),
    surfaceBright: Colors.white,
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: const Color(0xFFF6F6F6),
    surfaceContainer: const Color(0xFFF0F0F0),
    surfaceContainerHigh: const Color(0xFFEAEAEA),
    surfaceContainerHighest: const Color(0xFFE2E2E2),
  );

  static final ColorScheme _darkGreenScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF2E7D5B),
    brightness: Brightness.dark,
  ).copyWith(
    surface: Colors.black,
    surfaceDim: Colors.black,
    surfaceBright: const Color(0xFF2A2A2A),
    surfaceContainerLowest: Colors.black,
    surfaceContainerLow: const Color(0xFF0D0D0D),
    surfaceContainer: const Color(0xFF141414),
    surfaceContainerHigh: const Color(0xFF1C1C1C),
    surfaceContainerHighest: const Color(0xFF262626),
  );

  static ThemeData _build(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide.none,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHigh,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        elevation: 0,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      visualDensity: VisualDensity.standard,
    );
  }
}
