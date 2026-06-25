import 'package:flutter/material.dart';

enum AppThemeChoice {
  lightBlue,
  darkGreen,
  custom;

  String get label => switch (this) {
        AppThemeChoice.lightBlue => 'Light (white & blue)',
        AppThemeChoice.darkGreen => 'Dark (black & green)',
        AppThemeChoice.custom => 'Custom',
      };

  static AppThemeChoice fromValue(String value) => AppThemeChoice.values
      .firstWhere((e) => e.name == value, orElse: () => AppThemeChoice.darkGreen);
}

class AppTheme {
  AppTheme._();

  static ThemeData themeFor(AppThemeChoice choice) => switch (choice) {
        AppThemeChoice.lightBlue => _build(_lightBlueScheme),
        AppThemeChoice.darkGreen => _build(_darkGreenScheme),
        AppThemeChoice.custom => _build(_lightBlueScheme),
      };

  /// Shared entry point for any [ColorScheme] (preset or custom-seeded) so
  /// every theme — built-in or user-chosen — goes through the same styling.
  static ThemeData themeForScheme(ColorScheme scheme) => _build(scheme);

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

  /// Re-hues [base] (a neutral on-surface/on-surface-variant color) toward
  /// [accent]'s hue while keeping [base]'s own lightness, so default text
  /// and icons visibly carry the chosen theme color without losing the
  /// light/dark contrast that makes them readable against [base]'s surface.
  static Color _tinted(Color base, Color accent) {
    final baseHsl = HSLColor.fromColor(base);
    final accentHsl = HSLColor.fromColor(accent);
    return baseHsl
        .withHue(accentHsl.hue)
        .withSaturation((baseHsl.saturation + accentHsl.saturation * 0.6).clamp(0.0, 1.0))
        .toColor();
  }

  static ThemeData _build(ColorScheme colorScheme) {
    final tintedOnSurface = _tinted(colorScheme.onSurface, colorScheme.primary);
    final tintedOnSurfaceVariant =
        _tinted(colorScheme.onSurfaceVariant, colorScheme.primary);

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: tintedOnSurface,
        iconTheme: IconThemeData(color: tintedOnSurface),
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: tintedOnSurface,
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
        labelStyle: TextStyle(color: tintedOnSurfaceVariant),
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
          TextStyle(fontSize: 12, color: tintedOnSurfaceVariant),
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

    return base.copyWith(
      textTheme: base.textTheme.apply(
          bodyColor: tintedOnSurface, displayColor: tintedOnSurface),
      iconTheme: base.iconTheme.copyWith(color: tintedOnSurface),
      primaryIconTheme: base.primaryIconTheme.copyWith(color: tintedOnSurface),
      listTileTheme: base.listTileTheme.copyWith(
          iconColor: tintedOnSurfaceVariant, textColor: tintedOnSurface),
    );
  }
}
